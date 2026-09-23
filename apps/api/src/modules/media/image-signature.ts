export const ALLOWED_MIME = ['image/jpeg', 'image/png', 'image/heic'] as const;
export type AllowedMime = (typeof ALLOWED_MIME)[number];

/** Достаточно первых байт: сигнатура у всех трёх форматов в начале файла. */
export const SIGNATURE_BYTES = 32;

const HEIF_BRANDS = ['heic', 'heix', 'hevc', 'hevx', 'mif1', 'msf1'];

/**
 * Определяет тип по содержимому, а не по заголовку и не по расширению (ONW-34).
 *
 * Клиент может объявить `image/jpeg` и прислать что угодно: заголовок
 * Content-Type он же и формирует. Единственное, чему можно верить, — байты.
 */
export function sniffImageMime(head: Buffer): AllowedMime | null {
  if (head.length >= 3 && head[0] === 0xff && head[1] === 0xd8 && head[2] === 0xff) {
    return 'image/jpeg';
  }

  const png = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  if (head.length >= 8 && png.every((byte, i) => head[i] === byte)) {
    return 'image/png';
  }

  // HEIC — контейнер ISO-BMFF: байты 4..8 это «ftyp», дальше бренд.
  if (head.length >= 12 && head.subarray(4, 8).toString('latin1') === 'ftyp') {
    const brand = head.subarray(8, 12).toString('latin1');
    if (HEIF_BRANDS.includes(brand)) return 'image/heic';
  }

  return null;
}
