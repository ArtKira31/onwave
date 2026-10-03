import { resolvePreset } from './date-presets';

describe('пресеты дат', () => {
  it('считает «сегодня» по таймзоне города, а не сервера', () => {
    const tbilisi = resolvePreset('today', 'Asia/Tbilisi');
    const belgrade = resolvePreset('today', 'Europe/Belgrade');

    // Конец дня наступает в разное время: между зонами два часа разницы.
    expect(tbilisi.to.getTime()).not.toBe(belgrade.to.getTime());
    expect(belgrade.to.getTime() - tbilisi.to.getTime()).toBe(2 * 3600_000);
  });

  it('не отдаёт прошлое: нижняя граница «сегодня» — текущий момент', () => {
    const { from, to } = resolvePreset('today', 'Asia/Tbilisi');
    expect(from.getTime()).toBeLessThanOrEqual(Date.now() + 1000);
    expect(from.getTime()).toBeGreaterThan(Date.now() - 5000);
    expect(to.getTime()).toBeGreaterThan(from.getTime());
  });

  it('«завтра» начинается с начала суток, а не с текущего часа', () => {
    const today = resolvePreset('today', 'Asia/Tbilisi');
    const tomorrow = resolvePreset('tomorrow', 'Asia/Tbilisi');
    expect(tomorrow.from.getTime()).toBeGreaterThanOrEqual(today.to.getTime() - 1000);
  });

  it('расширяет окно от today к week и month', () => {
    const zone = 'Asia/Tbilisi';
    const day = resolvePreset('today', zone).to.getTime();
    const week = resolvePreset('week', zone).to.getTime();
    const month = resolvePreset('month', zone).to.getTime();
    expect(week).toBeGreaterThan(day);
    expect(month).toBeGreaterThan(week);
  });

  it('падает на некорректной таймзоне, а не молча считает по UTC', () => {
    expect(() => resolvePreset('today', 'Нет/Такой')).toThrow();
  });
});
