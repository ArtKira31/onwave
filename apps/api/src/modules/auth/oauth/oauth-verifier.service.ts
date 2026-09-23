import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
// Не default-импорт: в tsconfig включён allowSyntheticDefaultImports, но не
// esModuleInterop — default у CommonJS-модуля окажется undefined в рантайме,
// и типы об этом промолчат.
import * as jwt from 'jsonwebtoken';
import type { JwtHeader, VerifyErrors } from 'jsonwebtoken';
import { JwksClient } from 'jwks-rsa';
import { AppException } from '../../../common/errors/app.exception';
import { ErrorCode } from '../../../common/errors/error-codes';
import { PROVIDERS, type OAuthProvider } from './oauth.config';
import type { Env } from '../../../common/config/env';

export interface VerifiedIdentity {
  /** Стабильный идентификатор у провайдера. Опора аккаунта — он, а не email. */
  subject: string;
  email: string | null;
  emailVerified: boolean;
  name: string | null;
  avatarUrl: string | null;
}

interface IdTokenClaims {
  sub: string;
  email?: string;
  email_verified?: boolean | string;
  name?: string;
  picture?: string;
}

@Injectable()
export class OAuthVerifierService {
  private readonly logger = new Logger(OAuthVerifierService.name);
  private readonly clients = new Map<OAuthProvider, JwksClient>();

  constructor(private readonly config: ConfigService<Env, true>) {}

  /**
   * Проверяет id_token провайдера: подпись по JWKS, issuer и audience.
   *
   * Audience проверять обязательно. Без неё токен, выписанный для чужого
   * приложения тем же Google, пройдёт как свой — и любой владелец Google-клиента
   * сможет войти в Onwave под произвольным аккаунтом.
   */
  async verify(provider: OAuthProvider, idToken: string): Promise<VerifiedIdentity> {
    const { issuers, audienceEnv } = PROVIDERS[provider];
    const audience = this.audience(audienceEnv);

    if (audience.length === 0) {
      // Пустой список означал бы «принимаем любой audience» — молча пускать
      // всех из-за незаполненного конфига нельзя.
      this.logger.error(`${audienceEnv} не задан: вход через ${provider} невозможен`);
      throw unauthorized('Провайдер не настроен');
    }

    const claims = await new Promise<IdTokenClaims>((resolve, reject) => {
      jwt.verify(
        idToken,
        (header, callback) => this.resolveKey(provider, header, callback),
        {
          // Непустоту audience проверили выше; jsonwebtoken требует именно
          // непустой кортеж, отсюда сужение.
          audience: audience as [string, ...string[]],
          issuer: issuers as [string, ...string[]],
          algorithms: ['RS256'],
        },
        (error: VerifyErrors | null, decoded: unknown) =>
          error ? reject(error) : resolve(decoded as IdTokenClaims),
      );
    }).catch((error: Error) => {
      this.logger.warn(`Невалидный id_token ${provider}: ${error.message}`);
      throw unauthorized('Токен провайдера недействителен');
    });

    return {
      subject: claims.sub,
      email: claims.email ?? null,
      // Google отдаёт булево, Apple — строку «true». Приводим руками, потому что
      // привязка к существующему аккаунту по неверифицированному email —
      // это захват чужой учётки.
      emailVerified: claims.email_verified === true || claims.email_verified === 'true',
      name: claims.name ?? null,
      avatarUrl: claims.picture ?? null,
    };
  }

  private resolveKey(
    provider: OAuthProvider,
    header: JwtHeader,
    callback: (error: Error | null, key?: string) => void,
  ): void {
    void this.client(provider)
      .getSigningKey(header.kid)
      .then((key) => callback(null, key.getPublicKey()))
      .catch((error: Error) => callback(error));
  }

  private client(provider: OAuthProvider): JwksClient {
    let client = this.clients.get(provider);
    if (!client) {
      client = new JwksClient({
        jwksUri: PROVIDERS[provider].jwksUri,
        // Ключи кэшируются: без этого каждый вход — поход к провайдеру,
        // а он на это отвечает лимитами.
        cache: true,
        cacheMaxAge: 12 * 60 * 60 * 1000,
        rateLimit: true,
        jwksRequestsPerMinute: 10,
        timeout: 5000,
      });
      this.clients.set(provider, client);
    }
    return client;
  }

  private audience(envKey: ProviderAudienceKey): string[] {
    return this.config
      .get(envKey, { infer: true })
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean);
  }
}

type ProviderAudienceKey = 'GOOGLE_CLIENT_IDS' | 'APPLE_CLIENT_IDS';

function unauthorized(message: string): AppException {
  return new AppException(ErrorCode.INVALID_OAUTH_TOKEN, message, HttpStatus.UNAUTHORIZED);
}
