import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import type { Category, City, Event, EventSession, MediaAsset, User, Venue } from '@prisma/client';
import { CategoryDto } from '../../categories/category.dto';

/** Три размера от воркера ресайза (ONW-35). Пусто — клиент рисует плейсхолдер. */
export class MediaVariantsDto {
  @ApiProperty({ nullable: true, type: String }) thumb!: string | null;
  @ApiProperty({ nullable: true, type: String }) medium!: string | null;
  @ApiProperty({ nullable: true, type: String }) large!: string | null;

  static from(asset: MediaAsset | null | undefined): MediaVariantsDto {
    const empty = { thumb: null, medium: null, large: null };
    if (!asset?.variants || typeof asset.variants !== 'object') return empty;
    const v = asset.variants as Record<string, unknown>;
    return {
      thumb: typeof v.thumb === 'string' ? v.thumb : null,
      medium: typeof v.medium === 'string' ? v.medium : null,
      large: typeof v.large === 'string' ? v.large : null,
    };
  }
}

export class EventSessionDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ format: 'date-time' }) startsAt!: string;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) endsAt!: string | null;
  @ApiProperty({ description: 'Сеанс уже прошёл.' }) isPast!: boolean;

  static from(session: EventSession, now: Date): EventSessionDto {
    return {
      id: session.id,
      startsAt: session.startsAt.toISOString(),
      endsAt: session.endsAt?.toISOString() ?? null,
      isPast: session.startsAt < now,
    };
  }
}

export class VenueDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiProperty() address!: string;
  @ApiProperty({ nullable: true, type: Number }) lat!: number | null;
  @ApiProperty({ nullable: true, type: Number }) lon!: number | null;
  @ApiProperty({ format: 'uuid' }) cityId!: string;

  static from(venue: Venue): VenueDto {
    return {
      id: venue.id,
      name: venue.name,
      address: venue.address,
      lat: venue.lat,
      lon: venue.lon,
      cityId: venue.cityId,
    };
  }
}

export class UserPublicDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ nullable: true, type: String }) displayName!: string | null;
  @ApiProperty({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiProperty() isOrganizer!: boolean;

  static from(user: User): UserPublicDto {
    return {
      id: user.id,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      isOrganizer: user.role === 'organizer',
    };
  }
}

/** Облегчённая карточка для ленты — без полного описания. */
export class EventCardDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ enum: ['draft', 'pending', 'published', 'rejected', 'hidden'] }) status!: string;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) startsAt!: string | null;
  @ApiProperty({ description: 'Больше одного — в карточке «и ещё N дат».' }) sessionCount!: number;
  @ApiProperty({ type: MediaVariantsDto }) cover!: MediaVariantsDto;
  @ApiProperty({ nullable: true, type: String }) categorySlug!: string | null;
  @ApiProperty({ nullable: true, type: String }) venueName!: string | null;
  @ApiProperty({ format: 'uuid' }) cityId!: string;
  @ApiProperty({ nullable: true, type: Number }) priceFrom!: number | null;
  @ApiProperty() isFavorite!: boolean;

  static from(event: EventWithCardRelations): EventCardDto {
    return {
      id: event.id,
      title: event.title,
      status: event.status,
      startsAt: event.startsAt?.toISOString() ?? null,
      sessionCount: event._count.sessions,
      cover: MediaVariantsDto.from(event.cover),
      categorySlug: event.category?.slug ?? null,
      venueName: event.venue?.name ?? null,
      cityId: event.cityId,
      priceFrom: null,
      // ONW-37: пока избранного нет, флаг всегда false — поле в контракте
      // обязательное, и мобилке нужна стабильная форма ответа.
      isFavorite: false,
    };
  }
}

export class EventCardPageDto {
  @ApiProperty({ type: [EventCardDto] }) items!: EventCardDto[];
  @ApiProperty({ nullable: true, type: String, description: 'Null — страниц больше нет.' })
  nextCursor!: string | null;
}

export class EventDetailDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ nullable: true, type: String }) description!: string | null;
  @ApiProperty({ enum: ['draft', 'pending', 'published', 'rejected', 'hidden'] }) status!: string;
  @ApiProperty({ format: 'uuid' }) cityId!: string;
  @ApiPropertyOptional({ type: CategoryDto }) category?: CategoryDto;
  @ApiPropertyOptional({ type: VenueDto }) venue?: VenueDto;
  @ApiProperty({ nullable: true, type: String }) rawAddress!: string | null;
  @ApiProperty({ nullable: true, type: Number }) lat!: number | null;
  @ApiProperty({ nullable: true, type: Number }) lon!: number | null;
  @ApiProperty({ type: UserPublicDto }) author!: UserPublicDto;
  @ApiProperty({ type: [EventSessionDto] }) sessions!: EventSessionDto[];
  @ApiProperty({ type: MediaVariantsDto }) cover!: MediaVariantsDto;
  @ApiProperty({ nullable: true, type: String }) ticketUrl!: string | null;
  @ApiProperty({ nullable: true, type: Number }) priceFrom!: number | null;
  @ApiProperty() isFavorite!: boolean;
  @ApiProperty({ description: 'Показывать ли кнопку редактирования.' }) canEdit!: boolean;
  @ApiProperty({ nullable: true, type: String }) rejectionReason!: string | null;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) publishedAt!: string | null;
  @ApiProperty({ format: 'date-time' }) createdAt!: string;

  static from(event: EventWithDetailRelations, now: Date): EventDetailDto {
    return {
      id: event.id,
      title: event.title,
      description: event.description,
      status: event.status,
      cityId: event.cityId,
      category: event.category ? CategoryDto.from(event.category) : undefined,
      venue: event.venue ? VenueDto.from(event.venue) : undefined,
      rawAddress: event.rawAddress,
      lat: event.lat,
      lon: event.lon,
      author: UserPublicDto.from(event.author),
      sessions: event.sessions.map((s) => EventSessionDto.from(s, now)),
      cover: MediaVariantsDto.from(event.cover),
      ticketUrl: event.ticketUrl,
      priceFrom: null,
      isFavorite: false,
      canEdit: false,
      rejectionReason: event.rejectionReason,
      publishedAt: event.publishedAt?.toISOString() ?? null,
      createdAt: event.createdAt.toISOString(),
    };
  }
}

export type EventWithCardRelations = Event & {
  category: Category | null;
  venue: Venue | null;
  cover: MediaAsset | null;
  _count: { sessions: number };
};

export type EventWithDetailRelations = Event & {
  category: Category | null;
  venue: Venue | null;
  cover: MediaAsset | null;
  author: User;
  city: City;
  sessions: EventSession[];
};
