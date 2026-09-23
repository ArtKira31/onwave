import { HttpStatus, Injectable } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { CitiesService } from '../cities/cities.service';
import { FavoritesService } from '../favorites/favorites.service';
import { AbilityFactory, Action } from '../auth/rbac/ability.factory';
import type { AccessTokenPayload } from '../auth/token.service';
import { cursorFilter, decodeCursor, encodeCursor } from '../../common/pagination/cursor';
import { resolvePreset } from './date-presets';
import type { ListEventsQuery } from './dto/list-events.query';
import {
  EventCardDto,
  EventDetailDto,
  type EventCardPageDto,
  type EventWithCardRelations,
  type EventWithDetailRelations,
} from './dto/event.dto';

const CARD_RELATIONS = {
  category: true,
  venue: true,
  cover: true,
  _count: { select: { sessions: true } },
} satisfies Prisma.EventInclude;

const DETAIL_RELATIONS = {
  category: true,
  venue: true,
  cover: true,
  author: true,
  city: true,
  sessions: { orderBy: { startsAt: 'asc' } },
} satisfies Prisma.EventInclude;

@Injectable()
export class EventsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly cities: CitiesService,
    private readonly favorites: FavoritesService,
    private readonly abilities: AbilityFactory,
  ) {}

  /**
   * Лента (ONW-28).
   *
   * Инвариант: `Event.startsAt` — время **ближайшего будущего** сеанса. Лента
   * сортируется и фильтруется по нему, иначе каждый запрос тянул бы агрегат по
   * сеансам и индекс `(cityId, status, startsAt)` был бы бесполезен. Поле
   * пересчитывается при правке сеансов и фоновой задачей, когда сеанс проходит.
   */
  async list(query: ListEventsQuery, viewerId?: string): Promise<EventCardPageDto> {
    const city = await this.cities.resolve(query.city);
    const now = new Date();

    if (query.preset && (query.dateFrom || query.dateTo)) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Параметр preset взаимоисключим с dateFrom и dateTo',
        HttpStatus.BAD_REQUEST,
      );
    }

    const window = this.resolveWindow(query, city.timezone, now);

    const where: Prisma.EventWhereInput = {
      cityId: city.id,
      status: 'published',
      deletedAt: null,
      // Событие без будущих сеансов в ленте не место, даже если оно опубликовано.
      startsAt: { gte: window.from, ...(window.to ? { lte: window.to } : {}) },
      ...(query.category?.length ? { category: { slug: { in: query.category } } } : {}),
      ...(query.query ? this.searchFilter(query.query) : {}),
      ...(query.cursor ? cursorFilter(decodeCursor(query.cursor)) : {}),
    };

    // Берём на одну строку больше запрошенного: так наличие следующей страницы
    // определяется без отдельного count, который на живой ленте всё равно
    // устареет к моменту ответа.
    const rows = (await this.prisma.event.findMany({
      where,
      include: CARD_RELATIONS,
      orderBy: [{ startsAt: 'asc' }, { id: 'asc' }],
      take: query.limit + 1,
    })) as EventWithCardRelations[];

    const hasMore = rows.length > query.limit;
    const items = hasMore ? rows.slice(0, query.limit) : rows;
    const last = items.at(-1);

    // Один запрос на страницу вместо одного на событие.
    const favorited = await this.favorites.favoriteIds(
      viewerId,
      items.map((event) => event.id),
    );

    return {
      items: items.map((event) => EventCardDto.from(event, favorited.has(event.id))),
      nextCursor:
        hasMore && last?.startsAt
          ? encodeCursor({ startsAt: last.startsAt.toISOString(), id: last.id })
          : null,
    };
  }

  /**
   * Карточка события (ONW-29).
   *
   * Неопубликованное отдаёт 404, а не 403: существование чужого черновика не
   * подтверждается. Разграничение автор/модератор появится вместе с ONW-25 —
   * пока доступ есть только к published.
   */
  async getById(id: string, viewer?: AccessTokenPayload): Promise<EventDetailDto> {
    const event = (await this.prisma.event.findFirst({
      where: { id, deletedAt: null },
      include: DETAIL_RELATIONS,
    })) as EventWithDetailRelations | null;

    // Неопубликованное видят автор и модератор; остальные получают 404, а не
    // 403: существование чужого черновика не подтверждается.
    const ability = this.abilities.forUser(viewer);
    if (!event || !ability.can(Action.Read, { ...event, __caslSubjectType__: 'Event' })) {
      throw new AppException(
        ErrorCode.EVENT_NOT_FOUND,
        'Событие не найдено',
        HttpStatus.NOT_FOUND,
      );
    }

    const favorited = await this.favorites.favoriteIds(viewer?.sub, [event.id]);
    return EventDetailDto.from(event, new Date(), viewer?.sub, favorited.has(event.id));
  }

  /**
   * «Мои события» (ONW-58): автор должен понимать, почему его событие не видно
   * в ленте, поэтому статус и причина отказа приходят здесь, а не только в ленте.
   */
  async listMine(
    userId: string,
    query: { cursor?: string; limit: number; status?: string[] },
  ): Promise<EventCardPageDto> {
    const where: Prisma.EventWhereInput = {
      authorId: userId,
      deletedAt: null,
      ...(query.status?.length ? { status: { in: query.status as never } } : {}),
      ...(query.cursor ? cursorFilter(decodeCursor(query.cursor)) : {}),
    };

    const rows = (await this.prisma.event.findMany({
      where,
      include: CARD_RELATIONS,
      orderBy: [{ startsAt: 'desc' }, { id: 'asc' }],
      take: query.limit + 1,
    })) as EventWithCardRelations[];

    const hasMore = rows.length > query.limit;
    const items = hasMore ? rows.slice(0, query.limit) : rows;
    const last = items.at(-1);
    const favorited = await this.favorites.favoriteIds(userId, items.map((e) => e.id));

    return {
      items: items.map((event) => ({
        ...EventCardDto.from(event, favorited.has(event.id)),
        rejectionReason: event.rejectionReason,
      })),
      nextCursor:
        hasMore && last?.startsAt
          ? encodeCursor({ startsAt: last.startsAt.toISOString(), id: last.id })
          : null,
    };
  }

  private resolveWindow(
    query: ListEventsQuery,
    timezone: string,
    now: Date,
  ): { from: Date; to?: Date } {
    if (query.preset) {
      const { from, to } = resolvePreset(query.preset, timezone);
      return { from, to };
    }

    const from = query.dateFrom ? new Date(query.dateFrom) : now;
    return {
      // Просить события в прошлом бессмысленно: нижняя граница не раньше «сейчас».
      from: from < now ? now : from,
      to: query.dateTo ? new Date(query.dateTo) : undefined,
    };
  }

  /**
   * Пока это ILIKE, а не полнотекстовый поиск: на сидовых объёмах разницы нет,
   * а честный FTS требует tsvector-колонки с триггером и отдельной миграции.
   * Заводить их до того, как появится реальный контент, — преждевременно.
   */
  private searchFilter(term: string): Prisma.EventWhereInput {
    return {
      OR: [
        { title: { contains: term, mode: 'insensitive' } },
        { description: { contains: term, mode: 'insensitive' } },
      ],
    };
  }
}
