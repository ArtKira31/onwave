import { Injectable } from '@nestjs/common';
import { HealthIndicatorService, type HealthIndicatorResult } from '@nestjs/terminus';
import { RedisService } from '../../../common/redis/redis.service';

@Injectable()
export class RedisHealthIndicator {
  constructor(
    private readonly health: HealthIndicatorService,
    private readonly redis: RedisService,
  ) {}

  async pingCheck(key: string): Promise<HealthIndicatorResult> {
    const session = this.health.check(key);
    return (await this.redis.ping()) ? session.up() : session.down('Redis не отвечает на PING');
  }
}
