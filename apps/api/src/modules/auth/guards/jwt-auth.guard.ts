import { HttpStatus, Injectable, type CanActivate, type ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { Request } from 'express';
import { AppException } from '../../../common/errors/app.exception';
import { ErrorCode } from '../../../common/errors/error-codes';
import { IS_PUBLIC } from '../decorators/public.decorator';
import { TokenService, type AccessTokenPayload } from '../token.service';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly tokens: TokenService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC, [
      context.getHandler(),
      context.getClass(),
    ]);

    const request = context.switchToHttp().getRequest<Request & { user?: AccessTokenPayload }>();
    const token = extractBearer(request);

    // На публичном маршруте токен необязателен, но если он есть — разбираем:
    // лента отдаёт isFavorite, и для этого ей нужно знать, кто спрашивает.
    if (!token) {
      if (isPublic) return true;
      throw unauthorized('Требуется авторизация');
    }

    try {
      request.user = await this.tokens.verifyAccessToken(token);
      return true;
    } catch {
      if (isPublic) return true;
      throw unauthorized('Токен недействителен или истёк');
    }
  }
}

function extractBearer(request: Request): string | null {
  const header = request.header('authorization');
  if (!header) return null;
  const [scheme, value] = header.split(' ');
  return scheme?.toLowerCase() === 'bearer' && value ? value : null;
}

function unauthorized(message: string): AppException {
  return new AppException(ErrorCode.UNAUTHORIZED, message, HttpStatus.UNAUTHORIZED);
}
