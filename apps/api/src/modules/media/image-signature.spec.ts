import { sniffImageMime } from './image-signature';

const bytes = (...values: number[]): Buffer => Buffer.from(values);

const heic = (brand: string): Buffer =>
  Buffer.concat([
    bytes(0, 0, 0, 0x18),
    Buffer.from('ftyp', 'latin1'),
    Buffer.from(brand, 'latin1'),
    Buffer.alloc(16),
  ]);

describe('определение типа изображения по содержимому', () => {
  it('узнаёт JPEG', () => {
    expect(sniffImageMime(bytes(0xff, 0xd8, 0xff, 0xe0, 0, 0))).toBe('image/jpeg');
  });

  it('узнаёт PNG', () => {
    expect(sniffImageMime(bytes(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0))).toBe(
      'image/png',
    );
  });

  it.each(['heic', 'heix', 'mif1'])('узнаёт HEIC с брендом %s', (brand) => {
    expect(sniffImageMime(heic(brand))).toBe('image/heic');
  });

  it('не принимает ISO-BMFF чужого бренда', () => {
    // mp4 — такой же контейнер, но это видео, а не фотография.
    expect(sniffImageMime(heic('isom'))).toBeNull();
  });

  it.each([
    ['исполняемый ELF', bytes(0x7f, 0x45, 0x4c, 0x46, 0, 0, 0, 0, 0, 0, 0, 0)],
    ['PDF', Buffer.from('%PDF-1.7 и дальше что-то', 'latin1')],
    ['ZIP', bytes(0x50, 0x4b, 0x03, 0x04, 0, 0, 0, 0, 0, 0, 0, 0)],
    ['SVG с скриптом', Buffer.from('<svg onload="alert(1)">', 'latin1')],
    ['просто текст', Buffer.from('это точно не картинка', 'utf8')],
  ])('отвергает %s', (_name, buffer) => {
    // Клиент сам формирует Content-Type, поэтому верить можно только байтам.
    expect(sniffImageMime(buffer)).toBeNull();
  });

  it('не падает на обрезанном буфере', () => {
    expect(sniffImageMime(Buffer.alloc(0))).toBeNull();
    expect(sniffImageMime(bytes(0xff, 0xd8))).toBeNull();
    expect(sniffImageMime(bytes(0x89, 0x50))).toBeNull();
  });
});
