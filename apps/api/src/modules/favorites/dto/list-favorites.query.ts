import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class ListFavoritesQueryDto {
  @ApiPropertyOptional({ description: 'Непрозрачный курсор из предыдущего ответа.' })
  @IsOptional()
  @IsString()
  cursor?: string;

  @ApiPropertyOptional({ minimum: 1, maximum: 50, default: 20 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(50)
  limit: number = 20;

  @ApiPropertyOptional({
    enum: ['upcoming', 'past'],
    default: 'upcoming',
    description: 'Прошедшие отделены от будущих: вперемешку список бесполезен.',
  })
  @IsOptional()
  @IsIn(['upcoming', 'past'])
  scope: 'upcoming' | 'past' = 'upcoming';
}
