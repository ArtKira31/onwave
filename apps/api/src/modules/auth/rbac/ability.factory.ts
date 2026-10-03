import { Injectable } from '@nestjs/common';
import { AbilityBuilder, createMongoAbility, type MongoAbility } from '@casl/ability';
import type { Event, UserRole } from '@prisma/client';
import type { AccessTokenPayload } from '../token.service';

export const Action = {
  Create: 'create',
  Read: 'read',
  Update: 'update',
  Delete: 'delete',
  /** Решения модератора: approve, reject, скрытие по жалобе. */
  Moderate: 'moderate',
  Manage: 'manage',
} as const;
export type Action = (typeof Action)[keyof typeof Action];

export type SubjectName = 'Event' | 'Report' | 'User' | 'all';
export type AppAbility = MongoAbility<[Action, SubjectName | Record<string, unknown>]>;

/** Автор может править свой черновик и отклонённое; опубликованное — с повторной модерацией. */
const AUTHOR_EDITABLE: Event['status'][] = ['draft', 'rejected', 'published'];

@Injectable()
export class AbilityFactory {
  /**
   * Права описаны в одном месте, а не разбросаны по контроллерам `if`.
   *
   * Гард проверяет право на маршрут, сервис — владение конкретным объектом:
   * «может создавать события» и «может править вот это событие» — разные
   * вопросы, и второй без объекта не задать.
   */
  forUser(user?: AccessTokenPayload): AppAbility {
    const { can, build } = new AbilityBuilder<AppAbility>(createMongoAbility);

    // Гость и вообще любой запрос: опубликованное читают все.
    can(Action.Read, 'Event', { status: 'published' });

    if (!user) return build();

    if (!user.isGuest) {
      can(Action.Create, 'Event');
      can(Action.Create, 'Report');
      // Своё событие видно автору в любом статусе, включая черновик.
      can(Action.Read, 'Event', { authorId: user.sub });
      can(Action.Update, 'Event', { authorId: user.sub, status: { $in: AUTHOR_EDITABLE } });
      can(Action.Delete, 'Event', { authorId: user.sub });
    }

    if (isAtLeast(user.role, 'moderator')) {
      can(Action.Read, 'Event');
      can(Action.Moderate, 'Event');
      can(Action.Read, 'Report');
    }

    if (user.role === 'admin') {
      can(Action.Manage, 'all');
    }

    return build();
  }
}

const ORDER: UserRole[] = ['user', 'organizer', 'moderator', 'admin'];

export function isAtLeast(role: UserRole, minimum: UserRole): boolean {
  return ORDER.indexOf(role) >= ORDER.indexOf(minimum);
}
