import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../common/prisma/prisma.service';
import { S3Service } from '../../common/storage/s3.service';

/** Час — с запасом больше времени жизни presigned URL. */
const UNCONFIRMED_TTL_MS = 60 * 60 * 1000;

@Injectable()
export class MediaCleanupService {
  private readonly logger = new Logger(MediaCleanupService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly s3: S3Service,
  ) {}

  /**
   * Пользователь запросил ссылку и передумал — запись и, возможно, объект
   * остались. Без уборки бакет и таблица растут от каждой брошенной формы.
   */
  @Cron(CronExpression.EVERY_HOUR)
  async removeUnconfirmed(): Promise<void> {
    const stale = await this.prisma.mediaAsset.findMany({
      where: { isConfirmed: false, createdAt: { lt: new Date(Date.now() - UNCONFIRMED_TTL_MS) } },
      take: 500,
    });

    if (stale.length === 0) return;

    for (const asset of stale) {
      await this.s3.delete(asset.storageKey);
    }
    await this.prisma.mediaAsset.deleteMany({ where: { id: { in: stale.map((a) => a.id) } } });

    this.logger.log(`Убрано неподтверждённых ассетов: ${stale.length}`);
  }
}
