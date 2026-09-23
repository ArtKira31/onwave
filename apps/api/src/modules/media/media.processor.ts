import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import type { Job } from 'bullmq';
// В tsconfig нет esModuleInterop, поэтому `import sharp from 'sharp'`
// компилируется в `sharp_1.default` — а его не существует, и воркер падает
// в рантайме, пока типы молчат. Тот же дефект ранее ломал проверку токенов
// провайдеров (ONW-16). Namespace-импорт эмитится в голый require и вызывается
// корректно; приведение типа нужно только потому, что .d.ts описывает вызов
// через default.
import * as sharpModule from 'sharp';
const sharp = sharpModule as unknown as typeof import('sharp').default;
import { PrismaService } from '../../common/prisma/prisma.service';
import { S3Service } from '../../common/storage/s3.service';
import { MEDIA_QUEUE, VARIANTS, type ResizeJobData } from './media.constants';

@Processor(MEDIA_QUEUE)
export class MediaProcessor extends WorkerHost {
  private readonly logger = new Logger(MediaProcessor.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly s3: S3Service,
  ) {
    super();
  }

  /**
   * Ресайз (ONW-35). Отдавать в ленту оригиналы с телефона — это мегабайты
   * на карточку и тормозящий скролл.
   */
  async process(job: Job<ResizeJobData>): Promise<void> {
    const asset = await this.prisma.mediaAsset.findUnique({ where: { id: job.data.assetId } });
    if (!asset) {
      this.logger.warn(`Ассет ${job.data.assetId} исчез до обработки`);
      return;
    }

    const original = await this.s3.getBytes(asset.storageKey);

    // rotate() без аргументов применяет ориентацию из EXIF и убирает её:
    // без этого часть фотографий с телефона приедет повёрнутой.
    // Метаданные sharp не переносит по умолчанию — и хорошо: в EXIF бывают
    // координаты съёмки, а это утечка данных пользователя.
    //
    // Поворот применяется один раз здесь, а не в каждом варианте, и размеры
    // берутся из результата. metadata() читает исходник: у повёрнутого фото
    // она вернёт ширину и высоту местами, а клиент по ним строит заглушку —
    // и вёрстка прыгнет, когда картинка догрузится.
    const { data: upright, info } = await sharp(original)
      .rotate()
      .toBuffer({ resolveWithObject: true });
    const base = sharp(upright);

    const variants: Record<string, string> = {};

    for (const variant of VARIANTS) {
      const pipeline = base.clone().resize({
        width: variant.width,
        // Мелкое фото не растягиваем: апскейл даёт мыло и лишние байты.
        withoutEnlargement: true,
      });

      const webp = await pipeline.clone().webp({ quality: 82 }).toBuffer();
      const webpKey = `variants/${asset.id}/${variant.name}.webp`;
      await this.s3.put(webpKey, webp, 'image/webp');
      variants[variant.name] = this.s3.publicUrl(webpKey);

      // JPEG-копия: мобилка использует webp, но копия нужна на случай веба
      // и внешних превью, где webp до сих пор не везде уместен.
      const jpeg = await pipeline.clone().jpeg({ quality: 82, mozjpeg: true }).toBuffer();
      const jpegKey = `variants/${asset.id}/${variant.name}.jpg`;
      await this.s3.put(jpegKey, jpeg, 'image/jpeg');
      variants[`${variant.name}Jpeg`] = this.s3.publicUrl(jpegKey);
    }

    await this.prisma.mediaAsset.update({
      where: { id: asset.id },
      data: { variants, width: info.width, height: info.height },
    });

    this.logger.log(`Ассет ${asset.id} обработан: ${info.width}×${info.height}`);
  }
}
