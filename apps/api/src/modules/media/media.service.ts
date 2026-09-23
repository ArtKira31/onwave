import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectQueue } from '@nestjs/bullmq';
import type { Queue } from 'bullmq';
import type { MediaAsset } from '@prisma/client';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../../common/prisma/prisma.service';
import { S3Service } from '../../common/storage/s3.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { sniffImageMime, SIGNATURE_BYTES } from './image-signature';
import { MEDIA_QUEUE, RESIZE_JOB, type ResizeJobData } from './media.constants';
import { RateLimitService } from '../../common/rate-limit/rate-limit.service';
import type { AccessTokenPayload } from '../auth/token.service';
import type { CreateUploadUrlRequest, UploadTicketDto } from './dto/media.dto';
import type { Env } from '../../common/config/env';

const EXTENSION: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/heic': 'heic',
};

@Injectable()
export class MediaService {
  private readonly logger = new Logger(MediaService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly s3: S3Service,
    private readonly config: ConfigService<Env, true>,
    @InjectQueue(MEDIA_QUEUE) private readonly queue: Queue<ResizeJobData>,
    private readonly limits: RateLimitService,
  ) {}

  /**
   * Presigned URL (ONW-34): файл идёт напрямую в бакет мимо API.
   *
   * Иначе весь трафик загрузок пойдёт через приложение — а это единственный
   * эндпоинт, где пользователь отправляет мегабайты, и на нём инстансы лягут
   * первыми.
   */
  async createUploadUrl(
    user: AccessTokenPayload,
    request: CreateUploadUrlRequest,
  ): Promise<UploadTicketDto> {
    const max = this.config.get('MEDIA_MAX_UPLOAD_BYTES', { infer: true });
    if (request.sizeBytes > max) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        `Файл больше допустимых ${Math.round(max / 1024 / 1024)} МБ`,
        HttpStatus.BAD_REQUEST,
        { maxBytes: max },
      );
    }

    // Два лимита: по числу файлов и по суммарному объёму. Одного количества
    // мало — тридцать файлов по десять мегабайт это уже триста мегабайт в сутки
    // с одного аккаунта.
    await this.limits.consume({
      scope: 'media-upload',
      subject: user.sub,
      limit: this.config.get('RATE_LIMIT_UPLOADS_PER_DAY', { infer: true }),
      windowSeconds: 86_400,
    });
    await this.limits.consume({
      scope: 'media-bytes',
      subject: user.sub,
      limit: this.config.get('RATE_LIMIT_UPLOAD_BYTES_PER_DAY', { infer: true }),
      windowSeconds: 86_400,
      cost: request.sizeBytes,
    });

    const storageKey = `uploads/${user.sub}/${randomUUID()}.${EXTENSION[request.mimeType]}`;

    const asset = await this.prisma.mediaAsset.create({
      data: {
        ownerId: user.sub,
        storageKey,
        mimeType: request.mimeType,
        sizeBytes: request.sizeBytes,
        isConfirmed: false,
      },
    });

    const uploadUrl = await this.s3.presignUpload(
      storageKey,
      request.mimeType,
      request.sizeBytes,
    );
    const ttl = this.config.get('MEDIA_UPLOAD_URL_TTL_SECONDS', { infer: true });

    return {
      assetId: asset.id,
      uploadUrl,
      method: 'PUT',
      headers: {
        'Content-Type': request.mimeType,
        'Content-Length': String(request.sizeBytes),
      },
      expiresAt: new Date(Date.now() + ttl * 1000).toISOString(),
    };
  }

  /**
   * Подтверждение загрузки. Здесь сервер впервые видит содержимое и проверяет
   * его сам: до этого момента всё, что он знает о файле, — слова клиента.
   */
  async complete(user: AccessTokenPayload, assetId: string): Promise<MediaAsset> {
    const asset = await this.prisma.mediaAsset.findFirst({
      where: { id: assetId, ownerId: user.sub },
    });

    if (!asset) {
      throw new AppException(ErrorCode.NOT_FOUND, 'Ассет не найден', HttpStatus.NOT_FOUND);
    }
    if (asset.isConfirmed) return asset;

    const head = await this.s3.head(asset.storageKey);
    if (!head) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Файл не загружен в хранилище',
        HttpStatus.BAD_REQUEST,
      );
    }

    const signature = await this.s3.getBytes(
      asset.storageKey,
      `bytes=0-${SIGNATURE_BYTES - 1}`,
    );
    const actualMime = sniffImageMime(signature);

    if (!actualMime) {
      // Загрузили не картинку. Объект убираем сразу: держать мусор в бакете
      // и запись о нём в базе незачем.
      await this.discard(asset);
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Файл не является изображением jpeg, png или heic',
        HttpStatus.BAD_REQUEST,
      );
    }

    if (actualMime !== asset.mimeType) {
      this.logger.warn(
        { assetId: asset.id, declared: asset.mimeType, actual: actualMime },
        'Объявленный тип не совпал с содержимым',
      );
    }

    const confirmed = await this.prisma.mediaAsset.update({
      where: { id: asset.id },
      data: { isConfirmed: true, mimeType: actualMime, sizeBytes: head.size },
    });

    await this.queue.add(
      RESIZE_JOB,
      { assetId: confirmed.id },
      {
        // Повторы с растущей паузой: сбой хранилища обычно временный.
        attempts: 3,
        backoff: { type: 'exponential', delay: 2000 },
        // Упавшие задачи остаются в очереди — это и есть dead-letter,
        // по ним видно, что именно не обработалось.
        removeOnComplete: { age: 3600, count: 1000 },
        removeOnFail: false,
      },
    );

    return confirmed;
  }

  private async discard(asset: MediaAsset): Promise<void> {
    await this.s3.delete(asset.storageKey);
    await this.prisma.mediaAsset.delete({ where: { id: asset.id } });
  }
}
