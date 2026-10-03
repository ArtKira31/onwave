import { SetMetadata } from '@nestjs/common';
import type { Action, SubjectName } from './ability.factory';

export const REQUIRED_ABILITY = 'requiredAbility';

export interface RequiredAbility {
  action: Action;
  subject: SubjectName;
}

/**
 * Право на уровне маршрута: «может ли этот пользователь вообще такое делать».
 * Владение конкретным объектом проверяется в сервисе — там, где объект есть.
 */
export const RequireAbility = (action: Action, subject: SubjectName): MethodDecorator =>
  SetMetadata(REQUIRED_ABILITY, { action, subject });
