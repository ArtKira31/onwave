import { Global, Module } from '@nestjs/common';
import { RedisService } from './redis.service';

/** Глобальный: клиент нужен auth (ONW-22), rate limit (ONW-33) и очередям (ONW-35). */
@Global()
@Module({
  providers: [RedisService],
  exports: [RedisService],
})
export class RedisModule {}
