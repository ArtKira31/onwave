import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import type { User } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { TokenService, type TokenPair } from './token.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly tokens: TokenService,
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
