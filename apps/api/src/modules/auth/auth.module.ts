import { Global, Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { APP_GUARD } from '@nestjs/core';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { TokenService } from './token.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { OAuthVerifierService } from './oauth/oauth-verifier.service';
import { AbilityFactory } from './rbac/ability.factory';
import { AbilitiesGuard } from './rbac/abilities.guard';

/**
 * Гард регистрируется глобально: по умолчанию закрыто всё, открывается
 * точечно декоратором @Public(). Обратный порядок означал бы, что новый
 * эндпоинт можно забыть защитить.
 */
@Global()
@Module({
  imports: [JwtModule.register({})],
  controllers: [AuthController],
  providers: [
    AuthService,
    TokenService,
    OAuthVerifierService,
    AbilityFactory,
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    // Порядок важен: сначала разбирается токен, потом проверяются права.
    { provide: APP_GUARD, useClass: AbilitiesGuard },
  ],
  exports: [TokenService, AbilityFactory],
})
export class AuthModule {}
