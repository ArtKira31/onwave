import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HealthIndicatorService, type HealthIndicatorResult } from '@nestjs/terminus';
import type { Env } from '../../../common/config/env';

const TIMEOUT_MS = 2000;

@Injectable()
export class StorageHealthIndicator {
  constructor(
    private readonly health: HealthIndicatorService,
    private readonly config: ConfigService<Env, true>,
  ) {}

  /**
   * Проверяет достижимость хранилища, а не права на бакет.
   *
   * S3-совместимые сервисы на HEAD бакета отвечают 200, 403 или 404 в
   * зависимости от политики — любой из этих ответов означает, что сервис жив.
   * Полная проверка доступа (запись и чтение объекта) появится вместе с
   * ONW-34, когда в проекте будет S3-клиент: тянуть SDK ради пробы рано.
   */
  async pingCheck(key: string): Promise<HealthIndicatorResult> {
    const session = this.health.check(key);
    const endpoint = this.config.get('S3_ENDPOINT', { infer: true });
    const bucket = this.config.get('S3_BUCKET', { infer: true });

    try {
      const response = await fetch(`${endpoint.replace(/\/$/, '')}/${bucket}`, {
        method: 'HEAD',
        signal: AbortSignal.timeout(TIMEOUT_MS),
      });

      // 5xx — сервис есть, но сломан. Всё остальное означает, что он отвечает.
      return response.status >= 500
        ? session.down({ status_code: response.status })
        : session.up();
    } catch (error) {
      return session.down((error as Error).message);
    }
  }
}
