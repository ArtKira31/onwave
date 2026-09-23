import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';
import type { ReportReason, ReportTargetType, User, UserBlock } from '@prisma/client';
import { UserPublicDto } from '../../events/dto/event.dto';

const TARGETS = ['event', 'user'] as const;
const REASONS = ['spam', 'abuse', 'fraud', 'adult', 'other'] as const;

export class CreateReportRequest {
  @ApiProperty({ enum: TARGETS })
  @IsIn(TARGETS)
  targetType!: ReportTargetType;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  targetId!: string;

  @ApiProperty({ enum: REASONS, description: 'Из фиксированного списка, не свободный текст.' })
  @IsIn(REASONS)
  reason!: ReportReason;

  @ApiPropertyOptional({ maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  comment?: string;
}

export class BlockedUserDto {
  @ApiProperty({ type: UserPublicDto }) user!: UserPublicDto;
  @ApiProperty({ format: 'date-time' }) blockedAt!: string;

  static from(block: UserBlock & { blocked: User }): BlockedUserDto {
    return {
      user: UserPublicDto.from(block.blocked),
      blockedAt: block.createdAt.toISOString(),
    };
  }
}

export class BlockedUserListDto {
  @ApiProperty({ type: [BlockedUserDto] })
  items!: BlockedUserDto[];
}
