import { HttpStatus, Injectable } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { cursorFilter, decodeCursor, encodeCursor } from '../../common/pagination/cursor';
import { BlocksService } from '../safety/blocks.service';
import {
  EventCardDto,
  type EventCardPageDto,
  type EventWithCardRelations,
} from '../events/dto/event.dto';

const CARD_RELATIONS = {
  category: true,
  venue: true,
  cover: true,
  _count: { select: { sessions: true } },
} satisfies Prisma.EventInclude;

export interface ListFavoritesQuery {
  cursor?: string;
  limit: number;
  scope: 'upcoming' | 'past';
}

@Injectable()
export class FavoritesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly blocks: BlocksService,
  ) {}

  /**
   * Идемпотентно: составной ключ (userId, eventId) сам защищает от дублей,
   * поэтому повторный вызов не ошибка и проверок не требует.
   */
  async add(userId: string, eventId: string): Promise<void> {
    const event = await this.prisma.event.findFirst({
      where: { id: eventId, status: 'published', deletedAt: null },
      select: { id: true },
    });

    if (!event) {
      throw new AppException(
        ErrorCode.EVENT_NOT_FOUND,
        'Событие не найдено',
        HttpStatus.NOT_FOUND,
      );
    }

    await this.prisma.favorite.upsert({
      where: { userId_eventId: { userId, eventId } },
      update: {},
      create: { userId, eventId },
    });
  }

  /** Тоже идемпотентно: удаление отсутствующей записи — не ошибка. */
  async remove(userId: string, eventId: string): Promise<void> {
    await this.prisma.favorite.deleteMany({ where: { userId, eventId } });
  }

  /**
   * Прошедшие события отделены от будущих: список, где вперемешку концерт
   * завтра и концерт прошлой весной, бесполезен.
   */
  async list(userId: string, query: ListFavoritesQuery): Promise<EventCardPageDto> {
    const now = new Date();
    const upcoming = query.scope === 'upcoming';
    // Заблокировал автора — его события уходят и из избранного, даже если
    // были отмечены раньше.
    const hidden = await this.blocks.hiddenAuthorIds(userId);

    const where: Prisma.EventWhereInput = {
      favorites: { some: { userId } },
      deletedAt: null,
      startsAt: upcoming ? { gte: now } : { lt: now },
      ...(hidden.length ? { authorId: { notIn: hidden } } : {}),
      ...(query.cursor ? cursorFilter(decodeCursor(query.cursor)) : {}),
    };

    const rows = (await this.prisma.event.findMany({
      where,
      include: CARD_RELATIONS,
      // Будущее — ближайшее первым, прошлое — недавнее первым.
      orderBy: upcoming ? [{ startsAt: 'asc' }, { id: 'asc' }] : [{ startsAt: 'desc' }, { id: 'asc' }],
      take: query.limit + 1,
    })) as EventWithCardRelations[];

    const hasMore = rows.length > query.limit;
    const items = hasMore ? rows.slice(0, query.limit) : rows;
    const last = items.at(-1);

    return {
      // Всё в этом списке в избранном по определению — лишний запрос не нужен.
      items: items.map((event) => EventCardDto.from(event, true)),
      nextCursor:
        hasMore && last?.startsAt
          ? encodeCursor({ startsAt: last.startsAt.toISOString(), id: last.id })
          : null,
    };
  }

  /** Флаги для ленты и карточки: один запрос на страницу, а не на событие. */
  async favoriteIds(userId: string | undefined, eventIds: string[]): Promise<Set<string>> {
    if (!userId || eventIds.length === 0) return new Set();
    const rows = await this.prisma.favorite.findMany({
      where: { userId, eventId: { in: eventIds } },
      select: { eventId: true },
    });
    return new Set(rows.map((row) => row.eventId));
  }
}
