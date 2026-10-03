import { Inject, Injectable, Logger, type OnModuleDestroy, type OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Redis } from 'ioredis';
import type { Env } from '../config/env';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  readonly client: Redis;

  constructor(@Inject(ConfigService) config: ConfigService<Env, true>) {
    this.client = new Redis(config.get('REDIS_URL', { infer: true }), {
      // Подключаемся явно в onModuleInit, чтобы недоступный Redis не ронял
      // процесс на старте: приложение должно подняться и честно ответить
      // в readiness, а не уйти в цикл перезапусков.
      lazyConnect: true,
      maxRetriesPerRequest: 2,
      retryStrategy: (attempt) => Math.min(attempt * 200, 3000),
    });

    this.client.on('error', (error: Error) => {
      // Без обработчика ioredis роняет процесс необработанным 'error'.
      this.logger.warn(`Redis недоступен: ${error.message}`);
    });
  }

  async onModuleInit(): Promise<void> {
    try {
      await this.client.connect();
    } catch (error) {
      this.logger.warn(
        `Не удалось подключиться к Redis на старте: ${(error as Error).message}. ` +
          'Приложение поднимется, readiness будет отдавать 503.',
      );
    }
  }

  async onModuleDestroy(): Promise<void> {
    await this.client.quit().catch(() => this.client.disconnect());
  }

  /** Для readiness-пробы: живой ответ, а не просто состояние сокета. */
  async ping(): Promise<boolean> {
    try {
      return (await this.client.ping()) === 'PONG';
    } catch {
      return false;
    }
  }
}
