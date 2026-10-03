import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsInt, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';

const REJECT_REASONS = ['spam', 'abuse', 'fraud', 'adult', 'incomplete', 'duplicate', 'other'] as const;

export class ListQueueQuery {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  cursor?: string;

  @ApiPropertyOptional({ minimum: 1, maximum: 50, default: 20 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(50)
  limit: number = 20;

  @ApiPropertyOptional({ enum: ['pending_events', 'reports'], default: 'pending_events' })
  @IsOptional()
  @IsIn(['pending_events', 'reports'])
  kind: 'pending_events' | 'reports' = 'pending_events';
}

export class RejectEventRequest {
  @ApiProperty({
    enum: REJECT_REASONS,
    description: 'Из фиксированного списка: причина видна автору и должна быть внятной.',
  })
  @IsIn(REJECT_REASONS)
  reason!: string;

  @ApiPropertyOptional({ maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  comment?: string;
}

export class QueueItemDto {
  @ApiProperty({ enum: ['pending_event', 'report'] }) kind!: string;
  @ApiProperty({ format: 'date-time' }) createdAt!: string;
  @ApiProperty({ description: 'Возраст записи. SLA реакции по правилам Apple — 24 часа.' })
  ageHours!: number;
  @ApiProperty({
    nullable: true,
    type: String,
    description: 'Кто сейчас разбирает: клиент по нему гасит кнопки.',
  })
  lockedBy!: string | null;
  @ApiPropertyOptional({ type: Object }) event?: unknown;
  @ApiPropertyOptional({ type: Object }) report?: unknown;
  @ApiPropertyOptional({ description: 'Сколько независимых жалоб на этот объект.' })
  reportCount?: number;
}

export class QueuePageDto {
  @ApiProperty({ type: [QueueItemDto] }) items!: QueueItemDto[];
  @ApiProperty({ nullable: true, type: String }) nextCursor!: string | null;
}
