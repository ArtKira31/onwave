import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsISO8601,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  IsUrl,
  Length,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

export class EventSessionInput {
  @ApiPropertyOptional({ format: 'date-time' })
  @IsISO8601()
  startsAt!: string;

  @ApiPropertyOptional({ format: 'date-time', nullable: true })
  @IsOptional()
  @IsISO8601()
  endsAt?: string;
}

/**
 * Все поля опциональны: форма мультишаговая и сохраняется по частям (ONW-30).
 * Полная проверка обязательных полей включается на `submit`, а не здесь —
 * иначе черновик нельзя было бы сохранить, не заполнив его целиком.
 */
export class EventDraftInput {
  @ApiPropertyOptional({ minLength: 3, maxLength: 140 })
  @IsOptional()
  @IsString()
  @Length(3, 140)
  title?: string;

  @ApiPropertyOptional({ maxLength: 5000 })
  @IsOptional()
  @IsString()
  @MaxLength(5000)
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  categorySlug?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  cityId?: string;

  @ApiPropertyOptional({ format: 'uuid', nullable: true })
  @IsOptional()
  @IsUUID()
  venueId?: string;

  @ApiPropertyOptional({ maxLength: 300 })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  rawAddress?: string;

  @ApiPropertyOptional({ type: [EventSessionInput], maxItems: 50 })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => EventSessionInput)
  sessions?: EventSessionInput[];

  @ApiPropertyOptional({ format: 'uuid', nullable: true })
  @IsOptional()
  @IsUUID()
  coverAssetId?: string;

  @ApiPropertyOptional({ type: [String], maxItems: 10, description: 'Подтверждённые ассеты.' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsUUID('4', { each: true })
  galleryAssetIds?: string[];

  @ApiPropertyOptional({ nullable: true, description: 'Только http(s).' })
  @IsOptional()
  // Без ограничения протокола сюда приедет javascript: — и мобилка его откроет.
  @IsUrl({ protocols: ['http', 'https'], require_protocol: true })
  @MaxLength(2048)
  ticketUrl?: string;

  @ApiPropertyOptional({ nullable: true, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  priceFrom?: number;
}
