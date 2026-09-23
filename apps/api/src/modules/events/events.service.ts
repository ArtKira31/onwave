import { HttpStatus, Injectable } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { CitiesService } from '../cities/cities.service';
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
  ) {}

  /**
   * Лента (ONW-28).
   *
   * Инвариант: `Event.startsAt` — время **ближайшего будущего** сеанса. Лента
   * сортируется и фильтруется по нему, иначе каждый запрос тянул бы агрегат по
   * сеансам и индекс `(cityId, status, startsAt)` был бы бесполезен. Поле
   * пересчитывается при правке сеансов и фоновой задачей, когда сеанс проходит.
   */
  async list(query: ListEventsQuery): Promise<EventCardPageDto> {
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

    return {
      items: items.map(EventCardDto.from),
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
  async getById(id: string): Promise<EventDetailDto> {
    const event = (await this.prisma.event.findFirst({
      where: { id, status: 'published', deletedAt: null },
      include: DETAIL_RELATIONS,
    })) as EventWithDetailRelations | null;

    if (!event) {
      throw new AppException(
        ErrorCode.EVENT_NOT_FOUND,
        'Событие не найдено',
        HttpStatus.NOT_FOUND,
      );
    }

    return EventDetailDto.from(event, new Date());
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
