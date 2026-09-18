import { Controller, Get } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiExcludeController } from '@nestjs/swagger';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { Env } from '../../common/config/env';

/**
 * ONW-18.
 * /health       — liveness, без похода в зависимости.
 * /health/ready — readiness, 503 если недоступна любая зависимость.
 */
@ApiExcludeController()
@Controller('health')
export class HealthController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService<Env, true>,
  ) {}

  @Get()
  live(): { status: 'ok'; version: string } {
    return { status: 'ok', version: this.config.get('APP_VERSION', { infer: true }) };
  }

  @Get('ready')
  async ready(): Promise<{ status: string; checks: Record<string, boolean>; version: string }> {
    const checks: Record<string, boolean> = {
      database: await this.check(() => this.prisma.$queryRaw`SELECT 1`),
      // TODO(ONW-18): redis и доступность бакета, когда появятся их модули.
    };
    const ok = Object.values(checks).every(Boolean);
    return {
      status: ok ? 'ok' : 'degraded',
      checks,
      version: this.config.get('APP_VERSION', { infer: true }),
    };
  }

  private async check(fn: () => Promise<unknown>): Promise<boolean> {
    try {
      await fn();
      return true;
    } catch {
      return false;
    }
  }
}
