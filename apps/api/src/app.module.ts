import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { BullModule } from '@nestjs/bullmq';
import { ScheduleModule } from '@nestjs/schedule';
import { ConfigModule } from './common/config/config.module';
import { PrismaModule } from './common/prisma/prisma.module';
import { RedisModule } from './common/redis/redis.module';
import { StorageModule } from './common/storage/storage.module';
import { RequestIdMiddleware, REQUEST_ID_HEADER } from './common/http/request-id.middleware';
import { HealthModule } from './modules/health/health.module';
import { CitiesModule } from './modules/cities/cities.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { EventsModule } from './modules/events/events.module';
import { AuthModule } from './modules/auth/auth.module';
import { FavoritesModule } from './modules/favorites/favorites.module';
import { MediaModule } from './modules/media/media.module';
import { SafetyModule } from './modules/safety/safety.module';

/**
 * BullMQ принимает параметры соединения, а не URL, поэтому разбираем REDIS_URL
 * здесь: держать в конфиге два представления одного и того же — заявка на то,
 * что однажды они разойдутся.
 */
function redisConnection(): { host: string; port: number; password?: string; db?: number } {
  const url = new URL(process.env.REDIS_URL ?? 'redis://localhost:6379');
  const db = url.pathname.replace('/', '');
  return {
    host: url.hostname,
    port: Number(url.port || 6379),
    ...(url.password ? { password: url.password } : {}),
    ...(db ? { db: Number(db) } : {}),
  };
}

@Module({
  imports: [
    ConfigModule,
    LoggerModule.forRoot({
      pinoHttp: {
        level: process.env.LOG_LEVEL ?? 'info',
        // В dev — человекочитаемый вывод, в проде — JSON (ONW-16).
        transport:
          process.env.NODE_ENV === 'development'
            ? { target: 'pino-pretty', options: { singleLine: true } }
            : undefined,
        customProps: (req) => ({ requestId: req.headers[REQUEST_ID_HEADER] }),
        // Пробы не должны забивать логи (ONW-18).
        autoLogging: { ignore: (req) => req.url?.startsWith('/health') ?? false },
        redact: ['req.headers.authorization', 'req.headers.cookie'],
      },
    }),
    PrismaModule,
    RedisModule,
    StorageModule,
    ScheduleModule.forRoot(),
    BullModule.forRoot({ connection: redisConnection() }),
    HealthModule,
    AuthModule,
    CitiesModule,
    CategoriesModule,
    EventsModule,
    FavoritesModule,
    MediaModule,
    SafetyModule,
    // Дальше: MediaModule (ONW-34),
    // ModerationModule (ONW-32), ReportsModule (ONW-38).
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(RequestIdMiddleware).forRoutes('*');
  }
}
