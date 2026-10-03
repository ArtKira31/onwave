import { EventStatusService } from './event-status.service';
import { AppException } from '../../common/errors/app.exception';
import type { EventStatus } from '@prisma/client';

const service = new EventStatusService();
const ALL: EventStatus[] = ['draft', 'pending', 'published', 'rejected', 'hidden'];

const ALLOWED: [EventStatus, EventStatus][] = [
  ['draft', 'pending'],
  ['draft', 'published'],
  ['pending', 'published'],
  ['pending', 'rejected'],
  ['published', 'pending'],
  ['published', 'hidden'],
  ['rejected', 'pending'],
  ['hidden', 'published'],
  ['hidden', 'pending'],
];

describe('переходы жизненного цикла', () => {
  it.each(ALLOWED)('разрешает %s → %s', (from, to) => {
    expect(() => service.assertAllowed(from, to)).not.toThrow();
  });

  it('отбивает всё, чего нет в матрице', () => {
    const forbidden = ALL.flatMap((from) =>
      ALL.filter(
        (to) => from !== to && !ALLOWED.some(([f, t]) => f === from && t === to),
      ).map((to) => [from, to] as const),
    );

    // Матрица закрытая: разрешено только перечисленное, остальное — 409.
    expect(forbidden.length).toBeGreaterThan(0);
    for (const [from, to] of forbidden) {
      expect(() => service.assertAllowed(from, to)).toThrow(AppException);
    }
  });

  it('переход в тот же статус не ошибка', () => {
    // Повторное сохранение черновика не должно падать на ровном месте.
    for (const status of ALL) {
      expect(() => service.assertAllowed(status, status)).not.toThrow();
    }
  });

  it('в ошибке перечисляет, что было можно', () => {
    try {
      service.assertAllowed('draft', 'rejected');
      fail('ожидалось исключение');
    } catch (error) {
      expect((error as AppException).details).toEqual({
        from: 'draft',
        to: 'rejected',
        allowed: ['pending', 'published'],
      });
    }
  });

  it('пишет в журнал, кто и почему сменил статус', () => {
    const entry = service.journalEntry({
      eventId: 'e1',
      from: 'pending',
      to: 'rejected',
      actorId: 'mod-1',
      reason: 'Нет адреса',
    });

    expect(entry).toMatchObject({
      event: { connect: { id: 'e1' } },
      moderator: { connect: { id: 'mod-1' } },
      fromStatus: 'pending',
      toStatus: 'rejected',
      reason: 'Нет адреса',
    });
  });
});
