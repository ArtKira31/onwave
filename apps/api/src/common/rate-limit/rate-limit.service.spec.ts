import { RateLimitService } from './rate-limit.service';
import { AppException } from '../errors/app.exception';
import { ErrorCode } from '../errors/error-codes';
import type { RedisService } from '../redis/redis.service';

function make(used: number | Error) {
  const client = {
    incrby: jest.fn(used instanceof Error ? () => Promise.reject(used) : () => Promise.resolve(used)),
    expire: jest.fn().mockResolvedValue(1),
    ttl: jest.fn().mockResolvedValue(3600),
  };
  return {
    service: new RateLimitService({ client } as unknown as RedisService),
    client,
  };
}

const options = { scope: 'event-submit', subject: 'user-1', limit: 3, windowSeconds: 86_400 };

describe('RateLimitService', () => {
  it('пропускает, пока лимит не выбран', async () => {
    const { service } = make(3);
    await expect(service.consume(options)).resolves.toBeUndefined();
  });

  it('отбивает на превышении', async () => {
    const { service } = make(4);
    await expect(service.consume(options)).rejects.toThrow(AppException);
  });

  it('отдаёт код RATE_LIMITED и время до сброса', async () => {
    // По коду мобилка показывает понятное сообщение, а не общую ошибку,
    // по retryAfter — когда можно повторить.
    const { service } = make(9);
    await expect(service.consume(options)).rejects.toMatchObject({
      code: ErrorCode.RATE_LIMITED,
      details: { scope: 'event-submit', limit: 3, retryAfter: 3600 },
    });
  });

  it('ставит TTL только на первом запросе окна', async () => {
    // Иначе окно продлевалось бы каждым запросом и никогда не истекало.
    const { service, client } = make(1);
    await service.consume(options);
    expect(client.expire).toHaveBeenCalledWith(expect.any(String), 86_400);

    const second = make(2);
    await second.service.consume(options);
    expect(second.client.expire).not.toHaveBeenCalled();
  });

  it('учитывает вес запроса для лимита на объём', async () => {
    const { service, client } = make(1000);
    await service.consume({ ...options, scope: 'media-bytes', limit: 5000, cost: 1000 });
    expect(client.incrby).toHaveBeenCalledWith(expect.any(String), 1000);
  });

  it('при недоступном Redis пропускает запрос, а не роняет его', async () => {
    // Лимиты — защита от злого умысла, а не часть бизнес-логики. Ронять из-за
    // них публикацию события хуже, чем на время пропустить лишний запрос.
    const { service } = make(new Error('Connection is closed'));
    await expect(service.consume(options)).resolves.toBeUndefined();
  });
});
