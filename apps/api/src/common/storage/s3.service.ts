import { Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  DeleteObjectCommand,
  GetObjectCommand,
  HeadObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import type { Env } from '../config/env';

export interface ObjectHead {
  size: number;
  contentType?: string;
}

@Injectable()
export class S3Service implements OnModuleInit {
  private readonly logger = new Logger(S3Service.name);
  private readonly client: S3Client;
  readonly bucket: string;

  constructor(private readonly config: ConfigService<Env, true>) {
    this.bucket = config.get('S3_BUCKET', { infer: true });
    this.client = new S3Client({
      endpoint: config.get('S3_ENDPOINT', { infer: true }),
      region: config.get('S3_REGION', { infer: true }),
      // MinIO не умеет virtual-hosted style без DNS-настройки.
      forcePathStyle: config.get('S3_FORCE_PATH_STYLE', { infer: true }),
      credentials: {
        accessKeyId: config.get('S3_ACCESS_KEY', { infer: true }),
        secretAccessKey: config.get('S3_SECRET_KEY', { infer: true }),
      },
    });
  }

  onModuleInit(): void {
    this.logger.log(`Хранилище: ${this.config.get('S3_ENDPOINT', { infer: true })}/${this.bucket}`);
  }

  /**
   * Presigned URL на загрузку. Тип и размер вшиты в подпись: клиент обязан
   * прислать ровно эти заголовки, иначе S3 отклонит запрос сам. Проверять их
   * после загрузки поздно — файл уже в бакете и уже стоил трафика.
   */
  presignUpload(key: string, contentType: string, contentLength: number): Promise<string> {
    return getSignedUrl(
      this.client,
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: key,
        ContentType: contentType,
        ContentLength: contentLength,
      }),
      { expiresIn: this.config.get('MEDIA_UPLOAD_URL_TTL_SECONDS', { infer: true }) },
    );
  }

  async head(key: string): Promise<ObjectHead | null> {
    try {
      const result = await this.client.send(
        new HeadObjectCommand({ Bucket: this.bucket, Key: key }),
      );
      return { size: result.ContentLength ?? 0, contentType: result.ContentType };
    } catch {
      return null;
    }
  }

  /** `range` вида `bytes=0-31`: для сниффинга сигнатуры качать файл целиком незачем. */
  async getBytes(key: string, range?: string): Promise<Buffer> {
    const result = await this.client.send(
      new GetObjectCommand({ Bucket: this.bucket, Key: key, Range: range }),
    );
    return Buffer.from(await result.Body!.transformToByteArray());
  }

  async put(key: string, body: Buffer, contentType: string): Promise<void> {
    await this.client.send(
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: key,
        Body: body,
        ContentType: contentType,
        // Варианты неизменяемы: их имя включает размер, перезаписи не будет.
        CacheControl: 'public, max-age=31536000, immutable',
      }),
    );
  }

  async delete(key: string): Promise<void> {
    await this.client
      .send(new DeleteObjectCommand({ Bucket: this.bucket, Key: key }))
      .catch((error: Error) => this.logger.warn(`Не удалось удалить ${key}: ${error.message}`));
  }

  publicUrl(key: string): string {
    const base =
      this.config.get('S3_PUBLIC_URL', { infer: true }) ??
      `${this.config.get('S3_ENDPOINT', { infer: true })}/${this.bucket}`;
    return `${base.replace(/\/$/, '')}/${key}`;
  }

  /** Для readiness-пробы: живой запрос к бакету, а не просто доступность порта. */
  async isReachable(): Promise<boolean> {
    try {
      await this.client.send(new HeadObjectCommand({ Bucket: this.bucket, Key: '.probe' }));
      return true;
    } catch (error) {
      // 404 на несуществующий ключ означает, что бакет отвечает — это успех.
      const name = (error as { name?: string }).name;
      return name === 'NotFound' || name === 'NoSuchKey';
    }
  }
}
