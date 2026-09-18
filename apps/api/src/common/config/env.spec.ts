import { validateEnv } from './env';

const valid = {
  DATABASE_URL: 'postgresql://onwave:onwave@localhost:5432/onwave',
  REDIS_URL: 'redis://localhost:6379',
  S3_ENDPOINT: 'http://localhost:9000',
  S3_REGION: 'us-east-1',
  S3_BUCKET: 'onwave-media',
  S3_ACCESS_KEY: 'onwave',
  S3_SECRET_KEY: 'onwave123',
  JWT_ACCESS_SECRET: 'dev-access-secret-change-me',
  JWT_REFRESH_SECRET: 'dev-refresh-secret-change-me',
};

describe('validateEnv', () => {
  it('подставляет дефолты для необязательных переменных', () => {
    const env = validateEnv(valid);
    expect(env.PORT).toBe(3000);
    expect(env.NODE_ENV).toBe('development');
  });

  it('падает, если обязательной переменной нет', () => {
    const { DATABASE_URL: _omitted, ...withoutDb } = valid;
    expect(() => validateEnv(withoutDb)).toThrow(/DATABASE_URL/);
  });
});
