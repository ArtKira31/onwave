import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';
import { AppException } from '../errors/app.exception';
import { ErrorCode } from '../errors/error-codes';

export interface LimitOptions {
  /** Что ограничиваем: часть ключа, по ней же читаются логи. */
  scope: string;
  /** Кого ограничиваем: id пользователя или адрес. */
  subject: string;
  limit: number;
  windowSeconds: number;
  /** Насколько запрос «тяжёлый» — для лимита на байты. */
  cost?: number;
}

@Injectable()
export class RateLimitService {
  private readonly logger = new Logger(RateLimitService.name);

  constructor(private readonly redis: RedisService) {}

  /**
   * Счётчик в фиксированном окне (ONW-33).
   *
   * Скользящее окно точнее, но дороже и сложнее; для защиты от спама хватает
   * фиксированного: на границе окна можно получить двойной лимит, и это
   * приемлемо, когда речь о трёх событиях в сутки, а не о биллинге.
   *
   * Недоступность Redis не блокирует пользователя: лимиты — защита от злого
   * умысла, а не часть бизнес-логики, и ронять из-за них публикацию события
   * хуже, чем на время пропустить лишний запрос.
   */
  async consume(options: LimitOptions): Promise<void> {
    const { scope, subject, limit, windowSeconds, cost = 1 } = options;
    const key = `rl:${scope}:${subject}:${this.window(windowSeconds)}`;

    let used: number;
    try {
      used = await this.redis.client.incrby(key, cost);
      if (used === cost) {
        await this.redis.client.expire(key, windowSeconds);
      }
    } catch (error) {
      this.logger.warn(`Лимит ${scope} не проверен, Redis недоступен: ${(error as Error).message}`);
      return;
    }

    if (used > limit) {
      const retryAfter = await this.redis.client.ttl(key).catch(() => windowSeconds);
      throw new AppException(
        ErrorCode.RATE_LIMITED,
        'Слишком часто. Попробуйте позже.',
        HttpStatus.TOO_MANY_REQUESTS,
        { scope, limit, retryAfter: retryAfter > 0 ? retryAfter : windowSeconds },
      );
    }
  }

  /** Окно привязано к сетке времени, а не к первому запросу: ключи предсказуемы. */
  private window(windowSeconds: number): number {
    return Math.floor(Date.now() / 1000 / windowSeconds);
  }
}
