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
export interface PageCursor {
  /** Значение поля сортировки. Какого именно — решает вызывающий. */
  at: string;
  id: string;
}

export function encodeCursor(cursor: PageCursor): string {
  return Buffer.from(JSON.stringify(cursor), 'utf8').toString('base64url');
}

export function decodeCursor(raw: string): PageCursor {
  let parsed: unknown;
  try {
    parsed = JSON.parse(Buffer.from(raw, 'base64url').toString('utf8'));
  } catch {
    throw invalidCursor();
  }

  if (
    typeof parsed !== 'object' ||
    parsed === null ||
    typeof (parsed as PageCursor).id !== 'string' ||
    typeof (parsed as PageCursor).at !== 'string' ||
    Number.isNaN(Date.parse((parsed as PageCursor).at))
  ) {
    throw invalidCursor();
  }

  return parsed as PageCursor;
}

function invalidCursor(): AppException {
  return new AppException(
    ErrorCode.VALIDATION_FAILED,
    'Курсор повреждён. Запросите первую страницу без параметра cursor.',
    HttpStatus.BAD_REQUEST,
  );
}

/**
 * Сортировка всегда идёт по паре (поле, id), поэтому и курсор по ней же.
 * Одного поля мало: у строк с одинаковым значением порядок был бы
 * недетерминированным, и они терялись бы на границе страниц.
 *
 * `field` — по какому полю сортируем: `startsAt` у ленты, `createdAt` у
 * очереди модерации. `direction` — в какую сторону идёт обход.
 */
export function cursorFilter(
  cursor: PageCursor,
  field: 'startsAt' | 'createdAt' = 'startsAt',
  direction: 'asc' | 'desc' = 'asc',
): Record<string, unknown> {
  const at = new Date(cursor.at);
  const op = direction === 'asc' ? 'gt' : 'lt';
  return {
    OR: [{ [field]: { [op]: at } }, { [field]: at, id: { gt: cursor.id } }],
  };
}
