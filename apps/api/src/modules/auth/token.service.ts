import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService, type JwtSignOptions } from '@nestjs/jwt';
import { createHash, randomBytes, randomUUID } from 'node:crypto';
import type { User } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { parseDuration } from '../../common/time/duration';
import type { Env } from '../../common/config/env';

export interface AccessTokenPayload {
  sub: string;
  role: User['role'];
  isGuest: boolean;
  /** Нужен, чтобы «выход с этого устройства» знал, какую сессию гасить. */
  deviceId: string | null;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

@Injectable()
export class TokenService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService<Env, true>,
  ) {}

  /**
   * Выдаёт пару токенов и заводит новую цепочку ротации.
   *
   * `familyId` — та самая цепочка: все refresh-токены, выданные один за другим
   * на одном устройстве, делят её. Если всплывает уже использованный токен из
   * цепочки, это признак кражи, и отзывается вся цепочка целиком.
   */
  async issuePair(
    user: User,
    deviceId: string | null,
    familyId: string = randomUUID(),
  ): Promise<TokenPair> {
    const accessTtl = this.config.get('JWT_ACCESS_TTL', { infer: true });
    const refreshTtl = this.config.get('JWT_REFRESH_TTL', { infer: true });

    const payload: AccessTokenPayload = {
      sub: user.id,
      role: user.role,
      isGuest: user.isGuest,
      deviceId,
    };

    const accessToken = await this.jwt.signAsync(payload, {
      secret: this.config.get('JWT_ACCESS_SECRET', { infer: true }),
      // Тип expiresIn у jsonwebtoken — не string, а его собственный литеральный
      // union («15m», «2h»...). Значение приходит из конфига и провалидировано
      // parseDuration ниже, поэтому сужаем тип здесь.
      expiresIn: accessTtl as JwtSignOptions['expiresIn'],
    });

    // Refresh — не JWT, а случайная строка: он одноразовый и всё равно
    // проверяется по базе, а подписывать то, что и так требует запроса,
    // смысла нет. Зато в базе лежит только хэш.
    const refreshToken = randomBytes(48).toString('base64url');
    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: hash(refreshToken),
        deviceId,
        familyId,
        expiresAt: new Date(Date.now() + parseDuration(refreshTtl)),
      },
    });

    return { accessToken, refreshToken, expiresIn: parseDuration(accessTtl) / 1000 };
  }

  verifyAccessToken(token: string): Promise<AccessTokenPayload> {
    return this.jwt.verifyAsync<AccessTokenPayload>(token, {
      secret: this.config.get('JWT_ACCESS_SECRET', { infer: true }),
    });
  }

  findRefreshToken(token: string) {
    return this.prisma.refreshToken.findUnique({
      where: { tokenHash: hash(token) },
      include: { user: true },
    });
  }

  revoke(id: string): Promise<unknown> {
    return this.prisma.refreshToken.update({
      where: { id },
      data: { revokedAt: new Date() },
    });
  }

  /** Переиспользование одноразового токена — признак кражи: гасим всю цепочку. */
  revokeFamily(familyId: string): Promise<unknown> {
    return this.prisma.refreshToken.updateMany({
      where: { familyId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  /** Гасит сессии одного устройства: остальные продолжают работать. */
  revokeForDevice(userId: string, deviceId: string): Promise<unknown> {
    return this.prisma.refreshToken.updateMany({
      where: { userId, deviceId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  revokeAllForUser(userId: string): Promise<unknown> {
    return this.prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }
}

function hash(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}
