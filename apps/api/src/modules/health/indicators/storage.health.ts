import { Injectable } from '@nestjs/common';
import { HealthIndicatorService, type HealthIndicatorResult } from '@nestjs/terminus';
import { S3Service } from '../../../common/storage/s3.service';

@Injectable()
export class StorageHealthIndicator {
  constructor(
    private readonly health: HealthIndicatorService,
    private readonly s3: S3Service,
  ) {}

  /**
   * Спрашивает сам бакет через S3-клиент, а не просто дёргает порт.
   * До ONW-34 клиента в проекте не было и проверялась достижимость HTTP;
   * теперь проверяется то, чем пользуется приложение.
   */
  async pingCheck(key: string): Promise<HealthIndicatorResult> {
    const session = this.health.check(key);
    return (await this.s3.isReachable())
      ? session.up()
      : session.down('Бакет недоступен');
  }
}
