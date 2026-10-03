import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC = 'isPublic';

/**
 * Открывает маршрут без токена.
 *
 * Гард включён глобально: по умолчанию всё закрыто, и новый эндпоинт нельзя
 * забыть защитить — можно только осознанно открыть.
 */
export const Public = (): MethodDecorator & ClassDecorator => SetMetadata(IS_PUBLIC, true);
