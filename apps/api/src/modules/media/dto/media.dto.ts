import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsInt, Min } from 'class-validator';
import type { MediaAsset } from '@prisma/client';
import { ALLOWED_MIME } from '../image-signature';
import { MediaVariantsDto } from '../../events/dto/event.dto';

export class CreateUploadUrlRequest {
  @ApiProperty({ enum: ALLOWED_MIME })
  @IsIn(ALLOWED_MIME)
  mimeType!: string;

  @ApiProperty({ minimum: 1, description: 'Реальный размер проверяется политикой presigned URL.' })
  @IsInt()
  @Min(1)
  sizeBytes!: number;
}

export class UploadTicketDto {
  @ApiProperty({ format: 'uuid' }) assetId!: string;
  @ApiProperty({ format: 'uri' }) uploadUrl!: string;
  @ApiProperty({ enum: ['PUT'] }) method!: 'PUT';
  @ApiProperty({
    type: Object,
    description: 'Заголовки, которые клиент обязан отправить: они вшиты в подпись.',
  })
  headers!: Record<string, string>;
  @ApiProperty({ format: 'date-time' }) expiresAt!: string;
}

export class MediaAssetDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() isConfirmed!: boolean;
  @ApiProperty({ description: 'Варианты готовы.' }) isProcessed!: boolean;
  @ApiPropertyOptional({ nullable: true, type: Number }) width!: number | null;
  @ApiPropertyOptional({ nullable: true, type: Number }) height!: number | null;
  @ApiProperty({ type: MediaVariantsDto }) variants!: MediaVariantsDto;

  static from(asset: MediaAsset): MediaAssetDto {
    return {
      id: asset.id,
      isConfirmed: asset.isConfirmed,
      isProcessed: asset.variants !== null,
      width: asset.width,
      height: asset.height,
      variants: MediaVariantsDto.from(asset),
    };
  }
}
