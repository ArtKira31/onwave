import { OAuthVerifierService } from './oauth-verifier.service';
import { AppException } from '../../../common/errors/app.exception';
import { ErrorCode } from '../../../common/errors/error-codes';
import type { ConfigService } from '@nestjs/config';

function make(audiences: Record<string, string>) {
  const config = {
    get: (key: string) => audiences[key] ?? '',
  } as unknown as ConfigService<never, true>;
  return new OAuthVerifierService(config);
}

describe('OAuthVerifierService', () => {
  it('отказывает, если список audience пуст, а не принимает любой токен', async () => {
    // Пустой список в jsonwebtoken означает «не проверять audience». Молча
    // пускать всех из-за незаполненного конфига нельзя: токен, выписанный
    // для чужого приложения, прошёл бы как свой.
    const service = make({ GOOGLE_CLIENT_IDS: '' });
    await expect(service.verify('google', 'whatever')).rejects.toThrow(AppException);
  });

  it('отдаёт код INVALID_OAUTH_TOKEN, по которому мобилка различает причину', async () => {
    const service = make({ APPLE_CLIENT_IDS: '   ' });
    await expect(service.verify('apple', 'whatever')).rejects.toMatchObject({
      code: ErrorCode.INVALID_OAUTH_TOKEN,
    });
  });

  it('не пропускает заведомо битый токен при настроенном audience', async () => {
    const service = make({ GOOGLE_CLIENT_IDS: 'client-ios,client-android' });
    await expect(service.verify('google', 'not.a.jwt')).rejects.toThrow(AppException);
  });
});
