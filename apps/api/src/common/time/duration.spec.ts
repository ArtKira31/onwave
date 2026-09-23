import { parseDuration } from './duration';

describe('parseDuration', () => {
  it.each([
    ['15m', 900_000],
    ['24h', 86_400_000],
    ['30d', 2_592_000_000],
    ['45s', 45_000],
  ])('разбирает %s', (value, expected) => {
    expect(parseDuration(value)).toBe(expected);
  });

  it.each(['', '15', 'm', '15min', '-5m', '15 m', 'полчаса'])(
    'падает на «%s», а не подставляет ноль',
    (value) => {
      // Молчаливый ноль означал бы мгновенно истекающие токены,
      // и искали бы это долго.
      expect(() => parseDuration(value)).toThrow(/Некорректная длительность/);
    },
  );
});
