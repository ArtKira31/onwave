import { ApiPropertyOptional, ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsArray, IsIn, IsInt, IsISO8601, IsOptional, IsString, Max, Min, MaxLength } from 'class-validator';

const PRESETS = ['today', 'tomorrow', 'weekend', 'week', 'month'] as const;

export class ListEventsQuery {
  @ApiProperty({ description: 'Slug или id города. Лента всегда скоупится по городу.' })
  @IsString()
  city!: string;

  @ApiPropertyOptional({ description: 'Непрозрачный курсор из nextCursor предыдущего ответа.' })
  @IsOptional()
  @IsString()
  cursor?: string;

  @ApiPropertyOptional({ minimum: 1, maximum: 50, default: 20 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(50)
  limit: number = 20;

  @ApiPropertyOptional({ type: [String], description: 'Один или несколько slug категорий.' })
  @IsOptional()
  @Transform(({ value }) => (Array.isArray(value) ? value : [value]))
  @IsArray()
  @IsString({ each: true })
  category?: string[];

  @ApiPropertyOptional({ format: 'date-time' })
  @IsOptional()
  @IsISO8601()
  dateFrom?: string;

  @ApiPropertyOptional({ format: 'date-time' })
  @IsOptional()
  @IsISO8601()
  dateTo?: string;

  @ApiPropertyOptional({
    enum: PRESETS,
    description: 'Считается по таймзоне города. Взаимоисключим с dateFrom/dateTo.',
  })
  @IsOptional()
  @IsIn(PRESETS)
  preset?: (typeof PRESETS)[number];

  @ApiPropertyOptional({ maxLength: 200 })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  query?: string;
}
