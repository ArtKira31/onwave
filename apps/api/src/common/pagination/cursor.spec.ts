import { cursorFilter, decodeCursor, encodeCursor } from './cursor';
import { AppException } from '../errors/app.exception';

describe('курсор ленты', () => {
  const cursor = { at: '2026-10-01T18:00:00.000Z', id: 'e1b9c0de-0000-4000-8000-000000000001' };

  it('пережинает кодирование и декодирование без потерь', () => {
    expect(decodeCursor(encodeCursor(cursor))).toEqual(cursor);
  });

  it('не выглядит как читаемые данные — клиент не должен его разбирать', () => {
    expect(encodeCursor(cursor)).not.toContain(cursor.id);
  });

  it.each([
    ['мусор', 'не-base64!!'],
    ['валидный base64 не с тем содержимым', Buffer.from('{"a":1}').toString('base64url')],
    ['некорректная дата', Buffer.from(JSON.stringify({ at: 'вчера', id: 'x' })).toString('base64url')],
  ])('отбивает повреждённый курсор: %s', (_название, raw) => {
    expect(() => decodeCursor(raw)).toThrow(AppException);
  });

  it('умеет сортировку по другому полю и в обратную сторону', () => {
    // Очередь модерации идёт по createdAt, а «мои события» — по убыванию.
    const byCreated = cursorFilter(cursor, 'createdAt', 'desc') as { OR: Record<string, unknown>[] };
    expect(byCreated.OR[0]).toEqual({ createdAt: { lt: new Date(cursor.at) } });
  });

  it('сравнивает по паре (startsAt, id), а не только по времени', () => {
    // Иначе события, начинающиеся в одну и ту же секунду, терялись бы
    // на границе страниц или дублировались.
    const filter = cursorFilter(cursor) as { OR: Record<string, unknown>[] };
    expect(filter.OR).toHaveLength(2);
    expect(filter.OR[0]).toEqual({ startsAt: { gt: new Date(cursor.at) } });
    expect(filter.OR[1]).toEqual({ startsAt: new Date(cursor.at), id: { gt: cursor.id } });
  });
});
