import { Controller, Get } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiExcludeController } from '@nestjs/swagger';
import {
  HealthCheck,
  HealthCheckService,
  PrismaHealthIndicator,
  type HealthCheckResult,
} from '@nestjs/terminus';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RedisHealthIndicator } from './indicators/redis.health';
import { StorageHealthIndicator } from './indicators/storage.health';
import type { Env } from '../../common/config/env';
import { Public } from '../auth/decorators/public.decorator';

@ApiExcludeController()
@Public()
@Controller('health')
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly prismaIndicator: PrismaHealthIndicator,
    private readonly redisIndicator: RedisHealthIndicator,
    private readonly storageIndicator: StorageHealthIndicator,
    private readonly prisma: PrismaService,
    private readonly config: ConfigService<Env, true>,
  ) {}

  /** Liveness (ONW-18): пока процесс жив — 200. В зависимости не ходит. */
  @Get()
  live(): { status: 'ok'; version: string; gitSha: string } {
    return {
      status: 'ok',
      version: this.config.get('APP_VERSION', { infer: true }),
      gitSha: this.config.get('GIT_SHA', { infer: true }),
    };
  }

  /**
   * Readiness (ONW-18): 503, если недоступна любая зависимость.
   *
   * Проба обязана падать. Readiness, который всегда отвечает 200, хуже
   * отсутствующего: платформа деплоя считает инстанс исправным и шлёт в него
   * трафик, когда база уже лежит. Код ответа здесь ставит сам terminus —
   * он бросает ServiceUnavailableException, если хоть один индикатор down.
   */
  @Get('ready')
  @HealthCheck()
  ready(): Promise<HealthCheckResult> {
    return this.health.check([
      () => this.prismaIndicator.pingCheck('database', this.prisma),
      () => this.redisIndicator.pingCheck('redis'),
      () => this.storageIndicator.pingCheck('storage'),
    ]);
  }
}
