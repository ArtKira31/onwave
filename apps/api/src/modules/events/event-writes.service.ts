import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import type { Event, EventStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RedisService } from '../../common/redis/redis.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { AbilityFactory, Action } from '../auth/rbac/ability.factory';
import { EventStatusService } from './event-status.service';
import type { AccessTokenPayload } from '../auth/token.service';
import type { EventDraftInput } from './dto/event-draft.input';

/** Ключ идемпотентности живёт сутки: дольше повтор того же запроса не осмыслен. */
const IDEMPOTENCY_TTL_SECONDS = 24 * 60 * 60;

@Injectable()
export class EventWritesService {
  private readonly logger = new Logger(EventWritesService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
    private readonly abilities: AbilityFactory,
    private readonly status: EventStatusService,
  ) {}

  /**
   * Создание черновика (ONW-30).
   *
   * Идемпотентность по ключу от клиента: двойной тап по кнопке на плохой сети
   * не должен порождать два события. Повтор с тем же ключом возвращает то же
   * событие, а не создаёт новое.
   */
  async create(
    user: AccessTokenPayload,
    input: EventDraftInput,
    idempotencyKey?: string,
  ): Promise<Event> {
    if (idempotencyKey) {
      const existingId = await this.redis.client
        .get(this.idempotencyKey(user.sub, idempotencyKey))
        .catch(() => null);
      if (existingId) {
        const existing = await this.prisma.event.findUnique({ where: { id: existingId } });
        if (existing) return existing;
      }
    }

    const cityId = await this.resolveCity(input);
    const categoryId = await this.resolveCategory(input.categorySlug);

    const event = await this.prisma.event.create({
      data: {
        status: 'draft',
        authorId: user.sub,
        cityId,
        categoryId,
        title: input.title ?? '',
        description: input.description ?? null,
        venueId: input.venueId ?? null,
        rawAddress: input.rawAddress ?? null,
        ticketUrl: input.ticketUrl ?? null,
        coverId: input.coverAssetId ?? null,
        priceFrom: input.priceFrom ?? null,
      },
    });

    if (input.galleryAssetIds?.length) {
      await this.attachGallery(event.id, user.sub, input.galleryAssetIds);
    }

    if (input.sessions?.length) {
      await this.replaceSessions(event.id, input.sessions);
    }

    if (idempotencyKey) {
      await this.redis.client
        .set(this.idempotencyKey(user.sub, idempotencyKey), event.id, 'EX', IDEMPOTENCY_TTL_SECONDS)
        .catch(() => undefined);
    }

    return this.reload(event.id);
  }

  /** Частичное обновление: форма сохраняется по шагам, целиком её никто не шлёт. */
  async update(user: AccessTokenPayload, id: string, input: EventDraftInput): Promise<Event> {
    const event = await this.loadOwned(user, id);

    const data: Prisma.EventUpdateInput = {};
    if (input.title !== undefined) data.title = input.title;
    if (input.description !== undefined) data.description = input.description;
    if (input.rawAddress !== undefined) data.rawAddress = input.rawAddress;
    if (input.ticketUrl !== undefined) data.ticketUrl = input.ticketUrl;
    if (input.venueId !== undefined) data.venue = { connect: { id: input.venueId } };
    if (input.coverAssetId !== undefined) data.cover = { connect: { id: input.coverAssetId } };
    if (input.priceFrom !== undefined) data.priceFrom = input.priceFrom;
    if (input.categorySlug !== undefined) {
      const categoryId = await this.resolveCategory(input.categorySlug);
      if (categoryId) data.category = { connect: { id: categoryId } };
    }
    if (input.cityId !== undefined) data.city = { connect: { id: input.cityId } };

    await this.prisma.event.update({ where: { id }, data });

    if (input.sessions !== undefined) {
      await this.replaceSessions(id, input.sessions);
    }

    if (input.galleryAssetIds !== undefined) {
      await this.attachGallery(id, user.sub, input.galleryAssetIds);
    }

    // Правка опубликованного возвращает его на модерацию: иначе через
    // редактирование можно протащить в ленту что угодно после одобрения.
    if (event.status === 'published') {
      await this.transition(event, 'pending', user.sub, 'Изменено автором после публикации');
    }

    return this.reload(id);
  }

  /**
   * Отправка на модерацию. Только здесь включается полная валидация: до этого
   * момента черновик имеет право быть каким угодно неполным.
   */
  async submit(user: AccessTokenPayload, id: string): Promise<Event> {
    const event = await this.loadOwned(user, id);
    await this.assertReadyToPublish(event);

    // organizer верифицирован, его событиям очередь не нужна.
    const target: EventStatus = user.role === 'organizer' || user.role === 'admin'
      ? 'published'
      : 'pending';

    await this.transition(event, target, user.sub);
    return this.reload(id);
  }

  // --- внутреннее ---

  private async transition(
    event: Event,
    to: EventStatus,
    actorId: string,
    reason?: string,
  ): Promise<void> {
    this.status.assertAllowed(event.status, to);

    await this.prisma.$transaction([
      this.prisma.event.update({
        where: { id: event.id },
        data: {
          status: to,
          publishedAt: to === 'published' ? new Date() : event.publishedAt,
          rejectionReason: to === 'rejected' ? event.rejectionReason : null,
        },
      }),
      this.prisma.moderationAction.create({
        data: this.status.journalEntry({
          eventId: event.id,
          from: event.status,
          to,
          actorId,
          reason,
        }),
      }),
    ]);
  }

  private async assertReadyToPublish(event: Event): Promise<void> {
    const problems: string[] = [];

    if (!event.title || event.title.trim().length < 3) problems.push('Нужен заголовок');
    if (!event.description || event.description.trim().length < 10) {
      problems.push('Нужно описание не короче 10 символов');
    }
    if (!event.coverId) problems.push('Нужна обложка');
    if (!event.venueId && !event.rawAddress) problems.push('Нужна площадка или адрес');
    if (!event.categoryId) problems.push('Нужна категория');

    const upcoming = await this.prisma.eventSession.count({
      where: { eventId: event.id, startsAt: { gt: new Date() } },
    });
    if (upcoming === 0) problems.push('Нужен хотя бы один будущий сеанс');

    if (problems.length > 0) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Событие не готово к публикации',
        HttpStatus.BAD_REQUEST,
        { problems },
      );
    }
  }

  private async loadOwned(user: AccessTokenPayload, id: string): Promise<Event> {
    const event = await this.prisma.event.findFirst({ where: { id, deletedAt: null } });

    if (!event) {
      throw new AppException(ErrorCode.EVENT_NOT_FOUND, 'Событие не найдено', HttpStatus.NOT_FOUND);
    }

    const ability = this.abilities.forUser(user);
    if (!ability.can(Action.Update, { ...event, __caslSubjectType__: 'Event' })) {
      throw new AppException(
        ErrorCode.FORBIDDEN,
        'Нельзя редактировать это событие',
        HttpStatus.FORBIDDEN,
      );
    }

    return event;
  }

  /**
   * К событию привязываются только подтверждённые ассеты этого же пользователя:
   * иначе по чужому id можно прицепить к своему событию чужую картинку.
   */
  private async attachGallery(eventId: string, ownerId: string, assetIds: string[]): Promise<void> {
    await this.prisma.mediaAsset.updateMany({
      where: { eventId, NOT: { id: { in: assetIds } } },
      data: { eventId: null },
    });

    if (assetIds.length === 0) return;

    const attached = await this.prisma.mediaAsset.updateMany({
      where: { id: { in: assetIds }, ownerId, isConfirmed: true },
      data: { eventId },
    });

    if (attached.count !== assetIds.length) {
      this.logger.warn(
        { eventId, requested: assetIds.length, attached: attached.count },
        'Часть ассетов не привязана: чужие или неподтверждённые',
      );
    }
  }

  /**
   * Сеансы заменяются целиком: частичное редактирование списка дат превращается
   * в сверку «что добавили, что убрали» на клиенте, и рассинхрон там неизбежен.
   * Заодно пересчитывается денормализованный Event.startsAt.
   */
  private async replaceSessions(
    eventId: string,
    sessions: { startsAt: string; endsAt?: string }[],
  ): Promise<void> {
    await this.prisma.eventSession.deleteMany({ where: { eventId } });

    if (sessions.length > 0) {
      await this.prisma.eventSession.createMany({
        data: sessions.map((s) => ({
          eventId,
          startsAt: new Date(s.startsAt),
          endsAt: s.endsAt ? new Date(s.endsAt) : null,
        })),
      });
    }

    await this.recomputeStartsAt(eventId);
  }

  /** Инвариант: Event.startsAt — ближайший будущий сеанс, иначе последний прошедший. */
  private async recomputeStartsAt(eventId: string): Promise<void> {
    const now = new Date();
    const upcoming = await this.prisma.eventSession.findFirst({
      where: { eventId, startsAt: { gt: now } },
      orderBy: { startsAt: 'asc' },
    });
    const fallback = upcoming
      ? null
      : await this.prisma.eventSession.findFirst({
          where: { eventId },
          orderBy: { startsAt: 'desc' },
        });

    await this.prisma.event.update({
      where: { id: eventId },
      data: { startsAt: upcoming?.startsAt ?? fallback?.startsAt ?? null },
    });
  }

  private async resolveCity(input: EventDraftInput): Promise<string> {
    if (input.cityId) return input.cityId;

    if (input.venueId) {
      const venue = await this.prisma.venue.findUnique({ where: { id: input.venueId } });
      if (venue) return venue.cityId;
    }

    // Геокодинг (ONW-36) научится определять город по адресу; до тех пор
    // клиент обязан прислать его явно.
    throw new AppException(
      ErrorCode.VALIDATION_FAILED,
      'Нужно указать город или площадку',
      HttpStatus.BAD_REQUEST,
    );
  }

  private async resolveCategory(slug?: string): Promise<string | null> {
    if (!slug) return null;
    const category = await this.prisma.category.findUnique({ where: { slug } });
    if (!category) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        `Категория «${slug}» не найдена`,
        HttpStatus.BAD_REQUEST,
      );
    }
    return category.id;
  }

  private async reload(id: string): Promise<Event> {
    const event = await this.prisma.event.findUniqueOrThrow({ where: { id } });
    return event;
  }

  private idempotencyKey(userId: string, key: string): string {
    return `idem:event:${userId}:${key}`;
  }
}
