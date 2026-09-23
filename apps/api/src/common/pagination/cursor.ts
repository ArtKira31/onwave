import { AppException } from '../errors/app.exception';
import { ErrorCode } from '../errors/error-codes';
import { HttpStatus } from '@nestjs/common';

/**
 * ONW-28: курсорная пагинация, не offset.
 *
 * Лента постоянно меняется: пока пользователь листает, кто-то публикует новое
 * событие. При offset это сдвигает окно и на следующей странице он видит дубли
 * и пропуски. Курсор опирается на значения последней строки, поэтому сдвиг
 * ничего не ломает.
 *
 * Курсор непрозрачен для клиента: формат — деталь реализации, base64 здесь не
 * шифрование, а способ отбить желание его разбирать и конструировать.
 */
export interface FeedCursor {
  startsAt: string;
  id: string;
}

export function encodeCursor(cursor: FeedCursor): string {
  return Buffer.from(JSON.stringify(cursor), 'utf8').toString('base64url');
}

export function decodeCursor(raw: string): FeedCursor {
  let parsed: unknown;
  try {
    parsed = JSON.parse(Buffer.from(raw, 'base64url').toString('utf8'));
  } catch {
    throw invalidCursor();
  }

  if (
    typeof parsed !== 'object' ||
    parsed === null ||
    typeof (parsed as FeedCursor).id !== 'string' ||
    typeof (parsed as FeedCursor).startsAt !== 'string' ||
    Number.isNaN(Date.parse((parsed as FeedCursor).startsAt))
  ) {
    throw invalidCursor();
  }

  return parsed as FeedCursor;
}

function invalidCursor(): AppException {
  return new AppException(
    ErrorCode.VALIDATION_FAILED,
    'Курсор повреждён. Запросите первую страницу без параметра cursor.',
    HttpStatus.BAD_REQUEST,
  );
}

/**
 * Сортировка ленты — по паре (startsAt, id), поэтому и курсор по ней же.
 * Одного startsAt мало: у событий в один и тот же час порядок был бы
 * недетерминированным, и строки на границе страниц терялись бы.
 */
export function cursorFilter(cursor: FeedCursor): {
  OR: [{ startsAt: { gt: Date } }, { startsAt: Date; id: { gt: string } }];
} {
  const startsAt = new Date(cursor.startsAt);
  return {
    OR: [{ startsAt: { gt: startsAt } }, { startsAt, id: { gt: cursor.id } }],
  };
}
