import { DateTime } from 'luxon';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { HttpStatus } from '@nestjs/common';

export type DatePreset = 'today' | 'tomorrow' | 'weekend' | 'week' | 'month';

export interface DateRange {
  from: Date;
  to: Date;
}

/**
 * Пресеты считаются по таймзоне **города**, а не устройства и не сервера.
 *
 * Человек в аэропорту Стамбула, смотрящий афишу Тбилиси, должен видеть
 * тбилисское «сегодня». Если считать по времени телефона, он получит чужой
 * день — и это будет выглядеть как пропавшие события, а не как разница часовых
 * поясов.
 */
export function resolvePreset(preset: DatePreset, timezone: string): DateRange {
  const now = DateTime.now().setZone(timezone);
  if (!now.isValid) {
    throw new AppException(
      ErrorCode.INTERNAL,
      `У города некорректная таймзона: ${timezone}`,
      HttpStatus.INTERNAL_SERVER_ERROR,
    );
  }

  switch (preset) {
    case 'today':
      return range(now, now.endOf('day'));

    case 'tomorrow': {
      const tomorrow = now.plus({ days: 1 });
      return range(tomorrow.startOf('day'), tomorrow.endOf('day'));
    }

    case 'weekend': {
      // Суббота и воскресенье текущей недели. Если сегодня уже выходной —
      // считаем от текущего момента, а не от начала субботы: показывать
      // концерт, который начался три часа назад, смысла нет.
      const saturday = now.set({ weekday: 6 }).startOf('day');
      const sunday = now.set({ weekday: 7 }).endOf('day');
      return range(saturday < now ? now : saturday, sunday);
    }

    case 'week':
      return range(now, now.plus({ days: 7 }).endOf('day'));

    case 'month':
      return range(now, now.plus({ months: 1 }).endOf('day'));
  }
}

function range(from: DateTime, to: DateTime): DateRange {
  return { from: from.toUTC().toJSDate(), to: to.toUTC().toJSDate() };
}
