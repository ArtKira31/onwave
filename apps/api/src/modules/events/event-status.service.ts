import { HttpStatus, Injectable } from '@nestjs/common';
import type { EventStatus, Prisma } from '@prisma/client';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';

/**
 * Допустимые переходы (ONW-31). Всё, чего здесь нет, — ошибка, а не «ну ладно».
 *
 * Матрица живёт в одном месте, и сменить статус в обход этого сервиса нельзя:
 * иначе через полгода найдётся контроллер, который ставит `published` напрямую.
 */
const TRANSITIONS: Record<EventStatus, EventStatus[]> = {
  // organizer публикуется сразу, остальные — через очередь.
  draft: ['pending', 'published'],
  pending: ['published', 'rejected'],
  // Правка опубликованного возвращает его на модерацию; hidden — по жалобе.
  published: ['pending', 'hidden'],
  rejected: ['pending'],
  // Модератор может вернуть скрытое или отправить на повторный разбор.
  hidden: ['published', 'pending'],
};

export interface TransitionOptions {
  eventId: string;
  from: EventStatus;
  to: EventStatus;
  /**
   * Кто инициировал. Поле в схеме называется `moderatorId`, но действие может
   * исходить и от автора (отправка на модерацию, правка) — это журнал
   * переходов, а не только решений модератора.
   */
  actorId: string;
  reason?: string | null;
}

@Injectable()
export class EventStatusService {
  assertAllowed(from: EventStatus, to: EventStatus): void {
    if (from === to) return;
    if (!TRANSITIONS[from].includes(to)) {
      throw new AppException(
        ErrorCode.INVALID_STATE_TRANSITION,
        `Переход ${from} → ${to} недопустим`,
        HttpStatus.CONFLICT,
        { from, to, allowed: TRANSITIONS[from] },
      );
    }
  }

  /**
   * Запись в журнал. Нужна для внутренних разборов и для ответа проверяющему
   * Apple на вопрос, как обрабатываются жалобы: без неё «мы реагируем в течение
   * 24 часов» ничем не подтверждается.
   */
  journalEntry(options: TransitionOptions): Prisma.ModerationActionCreateInput {
    return {
      event: { connect: { id: options.eventId } },
      moderator: { connect: { id: options.actorId } },
      fromStatus: options.from,
      toStatus: options.to,
      reason: options.reason ?? null,
    };
  }

  allowedFrom(status: EventStatus): EventStatus[] {
    return TRANSITIONS[status];
  }
}
