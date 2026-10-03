import { HttpStatus, Injectable, type CanActivate, type ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AppException } from '../../../common/errors/app.exception';
import { ErrorCode } from '../../../common/errors/error-codes';
import { AbilityFactory } from './ability.factory';
import { REQUIRED_ABILITY, type RequiredAbility } from './require-ability.decorator';
import type { AccessTokenPayload } from '../token.service';

@Injectable()
export class AbilitiesGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly abilities: AbilityFactory,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.get<RequiredAbility | undefined>(
      REQUIRED_ABILITY,
      context.getHandler(),
    );
    if (!required) return true;

    const request = context
      .switchToHttp()
      .getRequest<{ user?: AccessTokenPayload }>();
    const ability = this.abilities.forUser(request.user);

    if (!ability.can(required.action, required.subject)) {
      // Именно 403, а не 404 и не 500: маршрут существует, прав не хватает.
      throw new AppException(
        ErrorCode.FORBIDDEN,
        'Недостаточно прав для этой операции',
        HttpStatus.FORBIDDEN,
      );
    }

    return true;
  }
}
