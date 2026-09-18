/**
 * Сид для разработки (ONW-20).
 * Идемпотентен: повторный запуск не плодит дубли.
 *
 * Сейчас засеивает справочники (города, категории) — они нужны сразу.
 * События, площадки и картинки добавляются в рамках ONW-20.
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const CITIES = [
  { slug: 'tbilisi', name: 'Тбилиси', timezone: 'Asia/Tbilisi', lat: 41.7151, lon: 44.8271, popularity: 100 },
  // Второй город намеренно в другой таймзоне — так сразу видно ошибки с «сегодня».
  { slug: 'belgrade', name: 'Белград', timezone: 'Europe/Belgrade', lat: 44.7866, lon: 20.4489, popularity: 90 },
];

const CATEGORIES = [
  { slug: 'concerts', nameKey: 'category.concerts', sortOrder: 10 },
  { slug: 'theatre', nameKey: 'category.theatre', sortOrder: 20 },
  { slug: 'exhibitions', nameKey: 'category.exhibitions', sortOrder: 30 },
  { slug: 'sport', nameKey: 'category.sport', sortOrder: 40 },
  { slug: 'parties', nameKey: 'category.parties', sortOrder: 50 },
  { slug: 'kids', nameKey: 'category.kids', sortOrder: 60 },
  { slug: 'education', nameKey: 'category.education', sortOrder: 70 },
  { slug: 'other', nameKey: 'category.other', sortOrder: 99 },
];

async function main(): Promise<void> {
  for (const city of CITIES) {
    await prisma.city.upsert({ where: { slug: city.slug }, update: city, create: city });
  }
  for (const category of CATEGORIES) {
    await prisma.category.upsert({
      where: { slug: category.slug },
      update: category,
      create: category,
    });
  }
  // TODO(ONW-20): площадки и 20–30 событий с реальными обложками,
  // разбросом по датам, многосеансовыми и в статусах pending/rejected.
  console.log(`Сид готов: городов ${CITIES.length}, категорий ${CATEGORIES.length}`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
