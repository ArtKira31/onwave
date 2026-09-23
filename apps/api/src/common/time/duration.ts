const UNITS: Record<string, number> = {
  s: 1000,
  m: 60_000,
  h: 3_600_000,
  d: 86_400_000,
};

/**
 * Разбирает «15m», «30d» в миллисекунды.
 *
 * jsonwebtoken понимает такие строки сам, но срок жизни refresh-токена нужен
 * ещё и нам — чтобы положить expiresAt в базу. Держать одно значение в двух
 * форматах в конфиге — заявка на то, что они разойдутся.
 */
export function parseDuration(value: string): number {
  const match = /^(\d+)([smhd])$/.exec(value.trim());
  if (!match) {
    throw new Error(`Некорректная длительность: «${value}». Ожидается формат 15m, 24h, 30d.`);
  }
  return Number(match[1]) * UNITS[match[2]];
}
