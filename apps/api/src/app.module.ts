import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { ConfigModule } from './common/config/config.module';
import { PrismaModule } from './common/prisma/prisma.module';
import { RedisModule } from './common/redis/redis.module';
import { RequestIdMiddleware, REQUEST_ID_HEADER } from './common/http/request-id.middleware';
import { HealthModule } from './modules/health/health.module';
import { CitiesModule } from './modules/cities/cities.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { EventsModule } from './modules/events/events.module';
import { AuthModule } from './modules/auth/auth.module';

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
    HealthModule,
    AuthModule,
    CitiesModule,
    CategoriesModule,
    EventsModule,
    // Дальше: MediaModule (ONW-34),
    // ModerationModule (ONW-32), ReportsModule (ONW-38).
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(RequestIdMiddleware).forRoutes('*');
  }
}
