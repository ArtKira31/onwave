import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RedisService } from '../../common/redis/redis.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { cursorFilter, decodeCursor, encodeCursor } from '../../common/pagination/cursor';
import { EventStatusService } from '../events/event-status.service';
import type { AccessTokenPayload } from '../auth/token.service';
import type { ListQueueQuery, RejectEventRequest } from './dto/moderation.dto';

/** Держим решение за модератором на пару минут: дольше он его не обдумывает. */
const LOCK_TTL_SECONDS = 120;

@Injectable()
export class ModerationService {
  private readonly logger = new Logger(ModerationService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
    private readonly status: EventStatusService,
  ) {}

  /**
   * Очередь (ONW-32). Сортировка по возрасту — самое старое первым.
   *
   * Apple требует реакции на жалобу в течение 24 часов, поэтому возраст
   * записи отдаётся явным полем: модератор должен видеть, что горит, не
   * вычитая даты в уме.
   */
  async queue(query: ListQueueQuery) {
    const now = Date.now();

    if (query.kind === 'reports') {
      const where: Prisma.ReportWhereInput = {
        status: 'open',
        ...(query.cursor ? cursorFilter(decodeCursor(query.cursor), 'createdAt') : {}),
      };
      const rows = await this.prisma.report.findMany({
        where,
        orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
        take: query.limit + 1,
      });
      return this.page(rows, query.limit, now, 'report');
    }

    const where: Prisma.EventWhereInput = {
      status: 'pending',
      deletedAt: null,
      ...(query.cursor ? cursorFilter(decodeCursor(query.cursor), 'createdAt') : {}),
    };
    const rows = await this.prisma.event.findMany({
      where,
      include: { author: true, category: true, venue: true, cover: true, sessions: true, city: true },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
      take: query.limit + 1,
    });
    return this.page(rows, query.limit, now, 'pending_event');
  }

  async approve(moderator: AccessTokenPayload, eventId: string) {
    return this.decide(moderator, eventId, 'published');
  }

  async reject(moderator: AccessTokenPayload, eventId: string, input: RejectEventRequest) {
    return this.decide(moderator, eventId, 'rejected', input);
  }

  /**
   * Решение под замком: два модератора не должны разбирать одно событие.
   *
   * Замок в Redis защищает от параллельной работы, а проверка статуса — от
   * гонки: даже если замок протух, второй переход из уже не-pending отобьётся
   * матрицей переходов. Одного замка мало, одной проверки статуса — тоже:
   * первая экономит чужое время, вторая гарантирует корректность.
   */
  private async decide(
    moderator: AccessTokenPayload,
    eventId: string,
    to: 'published' | 'rejected',
    input?: RejectEventRequest,
  ) {
    await this.acquireLock(eventId, moderator.sub);

    try {
      const event = await this.prisma.event.findFirst({
        where: { id: eventId, deletedAt: null },
      });
      if (!event) {
        throw new AppException(
          ErrorCode.EVENT_NOT_FOUND,
          'Событие не найдено',
          HttpStatus.NOT_FOUND,
        );
      }

      // Решение принимается только по тому, что действительно на модерации.
      // assertAllowed пропускает переход в тот же статус — это сделано ради
      // повторного сохранения черновика, но модерацию так обходить нельзя:
      // одобрить уже одобренное значит переписать publishedAt и добавить в
      // журнал решение, которого не было.
      if (event.status !== 'pending') {
        throw new AppException(
          ErrorCode.INVALID_STATE_TRANSITION,
          `Событие не на модерации (статус ${event.status})`,
          HttpStatus.CONFLICT,
          { status: event.status },
        );
      }

      this.status.assertAllowed(event.status, to);

      const reason = input ? [input.reason, input.comment].filter(Boolean).join(': ') : null;

      await this.prisma.$transaction([
        this.prisma.event.update({
          where: { id: eventId },
          data: {
            status: to,
            publishedAt: to === 'published' ? new Date() : event.publishedAt,
            rejectionReason: to === 'rejected' ? reason : null,
          },
        }),
        this.prisma.moderationAction.create({
          data: this.status.journalEntry({
            eventId,
            from: event.status,
            to,
            actorId: moderator.sub,
            reason,
          }),
        }),
        // Решение по событию закрывает и жалобы на него: разбирать их
        // по отдельности после того, как контент обработан, незачем.
        this.prisma.report.updateMany({
          where: { targetType: 'event', targetId: eventId, status: 'open' },
          data: { status: 'resolved', resolvedAt: new Date() },
        }),
      ]);

      this.logger.log({ eventId, moderatorId: moderator.sub, to }, 'Решение модератора');

      return this.prisma.event.findUniqueOrThrow({ where: { id: eventId } });
    } finally {
      await this.releaseLock(eventId, moderator.sub);
    }
  }

  private async acquireLock(eventId: string, moderatorId: string): Promise<void> {
    const key = this.lockKey(eventId);
    let acquired: string | null;
    try {
      acquired = await this.redis.client.set(key, moderatorId, 'EX', LOCK_TTL_SECONDS, 'NX');
    } catch (error) {
      // Redis лёг — пропускаем: корректность всё равно держится на статусе.
      this.logger.warn(`Замок модерации не взят: ${(error as Error).message}`);
      return;
    }

    if (acquired) return;

    const holder = await this.redis.client.get(key).catch(() => null);
    if (holder === moderatorId) return;

    throw new AppException(
      ErrorCode.FORBIDDEN,
      'Это событие сейчас разбирает другой модератор',
      HttpStatus.CONFLICT,
      { lockedBy: holder },
    );
  }

  private async releaseLock(eventId: string, moderatorId: string): Promise<void> {
    const key = this.lockKey(eventId);
    const holder = await this.redis.client.get(key).catch(() => null);
    // Снимаем только свой замок: чужой мог быть взят после протухания нашего.
    if (holder === moderatorId) {
      await this.redis.client.del(key).catch(() => undefined);
    }
  }

  private lockKey(eventId: string): string {
    return `moderation:lock:${eventId}`;
  }

  private async page<T extends { id: string; createdAt: Date }>(
    rows: T[],
    limit: number,
    now: number,
    kind: 'pending_event' | 'report',
  ) {
    const hasMore = rows.length > limit;
    const items = hasMore ? rows.slice(0, limit) : rows;
    const last = items.at(-1);

    const enriched = await Promise.all(
      items.map(async (row) => ({
        kind,
        createdAt: row.createdAt.toISOString(),
        ageHours: Math.round(((now - row.createdAt.getTime()) / 3_600_000) * 10) / 10,
        lockedBy: kind === 'pending_event' ? await this.lockHolder(row.id) : null,
        ...(kind === 'pending_event'
          ? { event: row, reportCount: await this.reportCount(row.id) }
          : { report: row }),
      })),
    );

    return {
      items: enriched,
      nextCursor:
        hasMore && last ? encodeCursor({ at: last.createdAt.toISOString(), id: last.id }) : null,
    };
  }

  private lockHolder(eventId: string): Promise<string | null> {
    return this.redis.client.get(this.lockKey(eventId)).catch(() => null);
  }

  private reportCount(eventId: string): Promise<number> {
    return this.prisma.report.count({
      where: { targetType: 'event', targetId: eventId, status: 'open' },
    });
  }
}
