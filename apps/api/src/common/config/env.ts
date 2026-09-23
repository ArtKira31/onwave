import { z } from 'zod';

/**
 * ONW-16: приложение падает на старте при отсутствии или неверном формате
 * переменной, а не в рантайме через неделю.
 */
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  APP_VERSION: z.string().default('0.0.0'),
  /** Проставляется в CI при сборке: по нему видно, что крутится на стенде. */
  GIT_SHA: z.string().default('unknown'),

  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),

  S3_ENDPOINT: z.string().url(),
  S3_REGION: z.string().min(1),
  S3_BUCKET: z.string().min(1),
  S3_ACCESS_KEY: z.string().min(1),
  S3_SECRET_KEY: z.string().min(1),
  S3_FORCE_PATH_STYLE: z.coerce.boolean().default(true),
  /** База публичных ссылок: перед бакетом обычно стоит CDN. */
  S3_PUBLIC_URL: z.string().url().optional(),
  /** Потолок размера загрузки. Вшивается в presigned URL, а не проверяется после. */
  MEDIA_MAX_UPLOAD_BYTES: z.coerce.number().int().positive().default(10 * 1024 * 1024),
  MEDIA_UPLOAD_URL_TTL_SECONDS: z.coerce.number().int().positive().default(300),

  JWT_ACCESS_SECRET: z.string().min(16),
  JWT_REFRESH_SECRET: z.string().min(16),
  JWT_ACCESS_TTL: z.string().default('15m'),
  JWT_REFRESH_TTL: z.string().default('30d'),

  /**
   * Допустимые audience провайдеров — по одному client id на платформу,
   * через запятую. Токен, выписанный для чужого приложения, обязан
   * отбиваться: иначе любой, у кого есть Google-клиент, входит в Onwave
   * под чужим аккаунтом.
   */
  GOOGLE_CLIENT_IDS: z.string().default(''),
  APPLE_CLIENT_IDS: z.string().default(''),

  SENTRY_DSN: z.string().optional(),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),

  SWAGGER_USER: z.string().default('onwave'),
  SWAGGER_PASSWORD: z.string().default('onwave'),

  GEO_PROVIDER: z.enum(['nominatim', 'google', 'yandex']).default('nominatim'),
  GEO_API_KEY: z.string().optional(),
});

export type Env = z.infer<typeof envSchema>;

export function validateEnv(raw: Record<string, unknown>): Env {
  const parsed = envSchema.safeParse(raw);
  if (!parsed.success) {
    const details = parsed.error.issues
      .map((issue) => `  ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');
    throw new Error(`Неверная конфигурация окружения:\n${details}`);
  }
  return parsed.data;
}
