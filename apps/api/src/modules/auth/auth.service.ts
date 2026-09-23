import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import type { User } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { TokenService, type TokenPair } from './token.service';
import { OAuthVerifierService } from './oauth/oauth-verifier.service';
import type { OAuthProvider } from './oauth/oauth.config';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly tokens: TokenService,
    private readonly oauth: OAuthVerifierService,
  ) {}

  /**
   * Гостевая сессия (ONW-21).
   *
   * Приложение работает без регистрации: человек, которого заставили
   * зарегистрироваться на входе, чаще всего просто уходит. Аккаунт нужен
   * только для избранного, создания событий и жалоб.
   *
   * Повторный запрос с тем же device-id возвращает ту же учётку — иначе при
   * каждом перезапуске приложения в базе появлялся бы новый пользователь.
   */
  async createGuestSession(deviceId: string): Promise<TokenPair & { user: User }> {
    const user = await this.prisma.user.upsert({
      where: { deviceId },
      update: {},
      create: { deviceId, isGuest: true, role: 'user' },
    });

    const pair = await this.tokens.issuePair(user, deviceId);
    return { ...pair, user };
  }


  /**
   * Вход через Google (ONW-23) или Apple (ONW-24).
   *
   * Аккаунт опирается на `sub` провайдера, а не на email: у Google email можно
   * сменить, а Apple при private relay отдаёт подставной адрес или не отдаёт
   * ничего. Email используется только для связывания с существующей учёткой и
   * только верифицированный — иначе это захват чужого аккаунта по незанятому
   * адресу.
   */
  async loginWithOAuth(
    provider: OAuthProvider,
    idToken: string,
    deviceId: string,
    fullName?: string | null,
  ): Promise<TokenPair & { user: User }> {
    const identity = await this.oauth.verify(provider, idToken);
    const subField = provider === 'google' ? 'googleSub' : 'appleSub';

    let user = await this.prisma.user.findFirst({
      where: { [subField]: identity.subject, deletedAt: null },
    });

    if (!user && identity.email && identity.emailVerified) {
      // Связывание: человек уже заходил другим способом с тем же адресом.
      const byEmail = await this.prisma.user.findFirst({
        where: { email: identity.email, isGuest: false, deletedAt: null },
      });
      if (byEmail) {
        user = await this.prisma.user.update({
          where: { id: byEmail.id },
          data: { [subField]: identity.subject },
        });
      }
    }

    if (!user) {
      user = await this.upgradeGuestOrCreate(deviceId, subField, identity, fullName);
    } else {
      await this.absorbGuest(user, deviceId);
      // Apple отдаёт имя только при первом входе. Если тогда не сохранили —
      // второго шанса не будет, поэтому дописываем при первой возможности.
      if (!user.displayName && fullName) {
        user = await this.prisma.user.update({
          where: { id: user.id },
          data: { displayName: fullName },
        });
      }
    }

    const pair = await this.tokens.issuePair(user, deviceId);
    return { ...pair, user };
  }

  /** Превращает гостя этого устройства в полноценного пользователя, не теряя его данные. */
  private async upgradeGuestOrCreate(
    deviceId: string,
    subField: 'googleSub' | 'appleSub',
    identity: { subject: string; email: string | null; name: string | null; avatarUrl: string | null },
    fullName?: string | null,
  ): Promise<User> {
    const guest = await this.prisma.user.findFirst({
      where: { deviceId, isGuest: true, deletedAt: null },
    });

    const data = {
      [subField]: identity.subject,
      email: identity.email,
      displayName: fullName ?? identity.name,
      avatarUrl: identity.avatarUrl,
      isGuest: false,
    };

    if (guest) {
      return this.prisma.user.update({ where: { id: guest.id }, data });
    }
    return this.prisma.user.create({ data: { ...data, deviceId, role: 'user' } });
  }

  /**
   * Пользователь уже существовал, но на этом устройстве успел накопиться гость.
   *
   * Переносим его избранное и освобождаем device-id: иначе всё, что человек
   * отметил до логина, для него исчезает — а это ровно тот момент, когда он
   * решил завести аккаунт.
   */
  private async absorbGuest(user: User, deviceId: string): Promise<void> {
    const guest = await this.prisma.user.findFirst({
      where: { deviceId, isGuest: true, deletedAt: null, NOT: { id: user.id } },
    });
    if (!guest) return;

    const favorites = await this.prisma.favorite.findMany({ where: { userId: guest.id } });
    if (favorites.length > 0) {
      await this.prisma.favorite.createMany({
        data: favorites.map((f) => ({ userId: user.id, eventId: f.eventId })),
        skipDuplicates: true,
      });
    }

    // device-id уникален на пользователя, поэтому гостя нужно от него отвязать.
    await this.prisma.user.update({
      where: { id: guest.id },
      data: { deviceId: null, deletedAt: new Date() },
    });

    this.logger.log(
      { guestId: guest.id, userId: user.id, favorites: favorites.length },
      'Гостевая учётка поглощена при логине',
    );
  }

  /**
   * Ротация (ONW-22).
   *
   * Refresh одноразовый: при обмене выдаётся новый, старый гасится. Если
   * приходит уже погашенный токен, вариантов два — либо его украли и
   * воспользовались, либо им пользуются параллельно с легальным клиентом.
   * Оба случая означают, что цепочке доверять нельзя, поэтому гасится вся.
   */
  async refresh(refreshToken: string): Promise<TokenPair & { user: User }> {
    const stored = await this.tokens.findRefreshToken(refreshToken);

    if (!stored) {
      throw unauthorized('Refresh-токен недействителен');
    }

    if (stored.revokedAt) {
      await this.tokens.revokeFamily(stored.familyId);
      this.logger.warn(
        { userId: stored.userId, familyId: stored.familyId },
        'Переиспользование refresh-токена: цепочка отозвана',
      );
      throw unauthorized('Сессия отозвана. Войдите заново.');
    }

    if (stored.expiresAt < new Date()) {
      throw unauthorized('Refresh-токен истёк');
    }

    await this.tokens.revoke(stored.id);
    const pair = await this.tokens.issuePair(stored.user, stored.deviceId, stored.familyId);
    return { ...pair, user: stored.user };
  }

  /**
   * Гасит сессии текущего устройства, остальные живут дальше.
   *
   * Опирается на device-id из access-токена, а не на refresh в теле: клиент
   * и так присылает bearer, а заставлять его доставать refresh ради выхода —
   * лишний повод этому refresh утечь в лог.
   */
  async logout(userId: string, deviceId: string | null): Promise<void> {
    if (deviceId) {
      await this.tokens.revokeForDevice(userId, deviceId);
      return;
    }
    // Сессии без device-id развести невозможно — гасим все.
    await this.tokens.revokeAllForUser(userId);
  }

  async logoutAll(userId: string): Promise<void> {
    await this.tokens.revokeAllForUser(userId);
  }
}

function unauthorized(message: string): AppException {
  return new AppException(ErrorCode.UNAUTHORIZED, message, HttpStatus.UNAUTHORIZED);
}
