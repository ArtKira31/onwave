/**
 * Сид для разработки (ONW-20).
 *
 * Идемпотентен: площадки и события адресуются по паре (source, externalId),
 * поэтому повторный запуск обновляет, а не плодит дубли. Те же поля заложены
 * под будущий импорт из внешних источников.
 *
 * Данные намеренно «неудобные»: описания разной длины, события без обложки,
 * многосеансовые, в разных таймзонах и в статусах, которых лента не должна
 * показывать. Карточка должна ломаться на разработке, а не у пользователя.
 */
import { PrismaClient, type EventStatus, type Prisma } from '@prisma/client';

const prisma = new PrismaClient();
const SOURCE = 'seed';

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

const VENUES = [
  { key: 'tbilisi-concert-hall', city: 'tbilisi', name: 'Тбилисский концертный зал', address: 'Мелика Гандилавы, 1' },
  { key: 'fabrika', city: 'tbilisi', name: 'Fabrika', address: 'Егнате Ниношвили, 8' },
  { key: 'mtatsminda', city: 'tbilisi', name: 'Парк Мтацминда', address: 'Мтацминда Плато' },
  { key: 'dom-omladine', city: 'belgrade', name: 'Дом омладине', address: 'Македонска, 22' },
  { key: 'kombank-dvorana', city: 'belgrade', name: 'Kombank дворана', address: 'Теразије, 41' },
];

const SHORT = 'Коротко и всё.';
const LONG =
  'Очень длинное описание, которое нужно, чтобы карточка и экран события ' +
  'ломались на разработке, а не у пользователя. Здесь несколько предложений ' +
  'подряд без переносов, потом список, потом снова текст. Вечер начнётся с ' +
  'разогрева, продолжится основной программой и закончится диджей-сетом. ' +
  'Вход по браслетам, которые выдают на входе, возврат билетов за сутки. ' +
  'Парковки рядом нет, приезжайте на метро. Если идёт дождь, площадка ' +
  'переносится под навес, о чём сообщим в день события.';

/** Часы от «сейчас». Отрицательные — прошедшие сеансы. */
interface EventSeed {
  key: string;
  city: string;
  venue: string;
  category: string;
  title: string;
  description: string | null;
  status: EventStatus;
  offsets: number[];
  cover: string | null;
  ticketUrl?: string;
}

const EVENTS: EventSeed[] = [
  { key: 'jazz-night', city: 'tbilisi', venue: 'tbilisi-concert-hall', category: 'concerts', title: 'Джазовый вечер: трио Гиорги Микеладзе', description: LONG, status: 'published', offsets: [4], cover: '1', ticketUrl: 'https://example.com/tickets/jazz' },
  { key: 'hamlet', city: 'tbilisi', venue: 'tbilisi-concert-hall', category: 'theatre', title: 'Гамлет', description: 'Классическая постановка в трёх актах.', status: 'published', offsets: [26, 50, 74], cover: '2' },
  { key: 'photo-expo', city: 'tbilisi', venue: 'fabrika', category: 'exhibitions', title: 'Выставка уличной фотографии', description: null, status: 'published', offsets: [8, 32], cover: '3' },
  { key: 'techno-fabrika', city: 'tbilisi', venue: 'fabrika', category: 'parties', title: 'Techno at Fabrika', description: SHORT, status: 'published', offsets: [10], cover: null },
  { key: 'kids-theatre', city: 'tbilisi', venue: 'fabrika', category: 'kids', title: 'Спектакль для детей: Как ёжик потерял иголки', description: 'Для зрителей от трёх лет, продолжительность 45 минут без антракта.', status: 'published', offsets: [30], cover: '4' },
  { key: 'mtatsminda-run', city: 'tbilisi', venue: 'mtatsminda', category: 'sport', title: 'Забег на Мтацминду', description: SHORT, status: 'published', offsets: [54], cover: '5' },
  { key: 'flutter-meetup', city: 'tbilisi', venue: 'fabrika', category: 'education', title: 'Flutter-митап: состояние экосистемы', description: 'Три доклада и афтепати. Вход свободный по регистрации.', status: 'published', offsets: [76], cover: '6' },
  { key: 'wine-tasting', city: 'tbilisi', venue: 'fabrika', category: 'other', title: 'Дегустация квеври', description: LONG, status: 'published', offsets: [100, 268], cover: '7' },
  { key: 'opera-gala', city: 'tbilisi', venue: 'tbilisi-concert-hall', category: 'concerts', title: 'Гала-концерт оперной музыки', description: 'Арии Верди и Пуччини в исполнении солистов театра.', status: 'published', offsets: [150], cover: '8' },
  { key: 'street-food', city: 'tbilisi', venue: 'mtatsminda', category: 'other', title: 'Фестиваль уличной еды', description: SHORT, status: 'published', offsets: [200, 224, 248], cover: '9' },
  { key: 'standup-tbilisi', city: 'tbilisi', venue: 'fabrika', category: 'other', title: 'Стендап: открытый микрофон', description: null, status: 'published', offsets: [12], cover: null },
  { key: 'film-club', city: 'tbilisi', venue: 'fabrika', category: 'other', title: 'Киноклуб: немое кино с тапёром', description: 'Показ с живым фортепианным сопровождением.', status: 'published', offsets: [400], cover: '10' },

  { key: 'belgrade-rock', city: 'belgrade', venue: 'dom-omladine', category: 'concerts', title: 'Rock night в Доме омладине', description: LONG, status: 'published', offsets: [6], cover: '11', ticketUrl: 'https://example.com/tickets/rock' },
  { key: 'belgrade-ballet', city: 'belgrade', venue: 'kombank-dvorana', category: 'theatre', title: 'Балет «Щелкунчик»', description: 'Два состава, разные даты.', status: 'published', offsets: [28, 52], cover: '12' },
  { key: 'belgrade-expo', city: 'belgrade', venue: 'dom-omladine', category: 'exhibitions', title: 'Современная сербская живопись', description: null, status: 'published', offsets: [14], cover: '13' },
  { key: 'belgrade-derby', city: 'belgrade', venue: 'kombank-dvorana', category: 'sport', title: 'Баскетбольное дерби', description: SHORT, status: 'published', offsets: [72], cover: '14' },
  { key: 'belgrade-party', city: 'belgrade', venue: 'dom-omladine', category: 'parties', title: 'Ночь балканского бита', description: 'До последнего гостя.', status: 'published', offsets: [34], cover: null },
  { key: 'belgrade-kids', city: 'belgrade', venue: 'kombank-dvorana', category: 'kids', title: 'Цирковое представление', description: SHORT, status: 'published', offsets: [120, 144], cover: '15' },
  { key: 'belgrade-lecture', city: 'belgrade', venue: 'dom-omladine', category: 'education', title: 'Лекция: история города в архитектуре', description: LONG, status: 'published', offsets: [180], cover: '16' },
  { key: 'belgrade-jazz', city: 'belgrade', venue: 'kombank-dvorana', category: 'concerts', title: 'Jazz weekend', description: null, status: 'published', offsets: [300, 324], cover: '17' },

  // Прошедшее: опубликовано, но в ленте его быть не должно.
  { key: 'past-concert', city: 'tbilisi', venue: 'tbilisi-concert-hall', category: 'concerts', title: 'Прошедший концерт', description: SHORT, status: 'published', offsets: [-48], cover: '18' },
  // Событие с прошедшим и будущим сеансами: в ленте должно быть, по будущему.
  { key: 'mixed-sessions', city: 'tbilisi', venue: 'fabrika', category: 'exhibitions', title: 'Выставка с прошедшим вернисажем', description: 'Вернисаж уже прошёл, выставка продолжается.', status: 'published', offsets: [-24, 60], cover: '19' },
  // Статусы, которых лента показывать не должна.
  { key: 'pending-event', city: 'tbilisi', venue: 'fabrika', category: 'parties', title: 'Событие на модерации', description: SHORT, status: 'pending', offsets: [20], cover: '20' },
  { key: 'rejected-event', city: 'tbilisi', venue: 'fabrika', category: 'other', title: 'Отклонённое событие', description: SHORT, status: 'rejected', offsets: [22], cover: null },
  { key: 'draft-event', city: 'belgrade', venue: 'dom-omladine', category: 'other', title: 'Черновик автора', description: null, status: 'draft', offsets: [40], cover: null },
  { key: 'hidden-event', city: 'belgrade', venue: 'dom-omladine', category: 'parties', title: 'Скрытое по жалобе', description: SHORT, status: 'hidden', offsets: [44], cover: null },
];

function hours(n: number): Date {
  return new Date(Date.now() + n * 3600_000);
}

/** Обложки — настоящие картинки разных пропорций, часть событий без них. */
function coverVariants(seed: string): Prisma.InputJsonValue {
  const base = `https://picsum.photos/seed/onwave-${seed}`;
  return { thumb: `${base}/320/240`, medium: `${base}/800/600`, large: `${base}/1600/1200` };
}

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

  const cities = new Map((await prisma.city.findMany()).map((c) => [c.slug, c]));
  const categories = new Map((await prisma.category.findMany()).map((c) => [c.slug, c]));

  const author = await prisma.user.upsert({
    where: { email: 'seed@onwave.app' },
    update: {},
    create: {
      email: 'seed@onwave.app',
      displayName: 'Сидовый автор',
      isGuest: false,
      role: 'organizer',
      acceptedTermsVersion: '1.0',
      acceptedTermsAt: new Date(),
    },
  });

  for (const venue of VENUES) {
    const city = cities.get(venue.city)!;
    const data = {
      cityId: city.id,
      name: venue.name,
      address: venue.address,
      timezone: city.timezone,
      lat: city.lat,
      lon: city.lon,
      source: SOURCE,
      externalId: venue.key,
    };
    await prisma.venue.upsert({
      where: { source_externalId: { source: SOURCE, externalId: venue.key } },
      update: data,
      create: data,
    });
  }

  const venues = new Map(
    (await prisma.venue.findMany({ where: { source: SOURCE } })).map((v) => [v.externalId!, v]),
  );

  for (const seed of EVENTS) {
    const city = cities.get(seed.city)!;
    const starts = seed.offsets.map(hours).sort((a, b) => a.getTime() - b.getTime());
    const now = new Date();
    // Инвариант Event.startsAt — ближайший БУДУЩИЙ сеанс. Если будущих нет,
    // берём последний прошедший: лента такое событие всё равно отфильтрует,
    // а карточка по прямой ссылке должна открываться.
    const upcoming = starts.filter((d) => d > now);
    const startsAt = upcoming[0] ?? starts.at(-1)!;

    let coverId: string | null = null;
    if (seed.cover) {
      const storageKey = `seed/${seed.key}/cover.jpg`;
      const asset = await prisma.mediaAsset.upsert({
        where: { storageKey },
        update: { variants: coverVariants(seed.cover) },
        create: {
          ownerId: author.id,
          storageKey,
          mimeType: 'image/jpeg',
          isConfirmed: true,
          width: 1600,
          height: 1200,
          variants: coverVariants(seed.cover),
        },
      });
      coverId = asset.id;
    }

    const data = {
      status: seed.status,
      authorId: author.id,
      cityId: city.id,
      venueId: venues.get(seed.venue)!.id,
      categoryId: categories.get(seed.category)!.id,
      title: seed.title,
      description: seed.description,
      ticketUrl: seed.ticketUrl ?? null,
      coverId,
      startsAt,
      publishedAt: seed.status === 'published' ? new Date() : null,
      rejectionReason: seed.status === 'rejected' ? 'Недостаточно информации о месте' : null,
      source: SOURCE,
      externalId: seed.key,
    };

    const event = await prisma.event.upsert({
      where: { source_externalId: { source: SOURCE, externalId: seed.key } },
      update: data,
      create: data,
    });

    // Сеансы пересоздаём: их время задано смещением от «сейчас», поэтому при
    // повторном запуске оно должно съезжать вместе с текущим моментом.
    await prisma.eventSession.deleteMany({ where: { eventId: event.id } });
    await prisma.eventSession.createMany({
      data: starts.map((startsAt) => ({
        eventId: event.id,
        startsAt,
        endsAt: new Date(startsAt.getTime() + 2 * 3600_000),
      })),
    });
  }

  const published = EVENTS.filter((e) => e.status === 'published').length;
  console.log(
    `Сид готов: городов ${CITIES.length}, категорий ${CATEGORIES.length}, ` +
      `площадок ${VENUES.length}, событий ${EVENTS.length} (published ${published})`,
  );
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(() => void prisma.$disconnect());
