import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RedisService } from '../../common/redis/redis.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';

/** Список блокировок меняется редко, а читается на каждый запрос ленты. */
const CACHE_TTL_SECONDS = 300;

@Injectable()
export class BlocksService {
  private readonly logger = new Logger(BlocksService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  async block(blockerId: string, blockedId: string): Promise<void> {
    if (blockerId === blockedId) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Нельзя заблокировать самого себя',
        HttpStatus.BAD_REQUEST,
      );
    }

    const target = await this.prisma.user.findFirst({
      where: { id: blockedId, deletedAt: null },
      select: { id: true },
    });
    if (!target) {
      throw new AppException(ErrorCode.NOT_FOUND, 'Пользователь не найден', HttpStatus.NOT_FOUND);
    }

    // Блокировка односторонняя и мгновенная — решения модератора не требует.
    await this.prisma.userBlock.upsert({
      where: { blockerId_blockedId: { blockerId, blockedId } },
      update: {},
      create: { blockerId, blockedId },
    });

    await this.invalidate(blockerId, blockedId);
  }

  async unblock(blockerId: string, blockedId: string): Promise<void> {
    await this.prisma.userBlock.deleteMany({ where: { blockerId, blockedId } });
    await this.invalidate(blockerId, blockedId);
  }

  list(blockerId: string) {
    return this.prisma.userBlock.findMany({
      where: { blockerId },
      include: { blocked: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Кого этот пользователь не должен видеть (ONW-39).
   *
   * Обе стороны, а не только «кого я заблокировал». Если человек заблокировал
   * преследователя, а тот продолжает видеть его события и ходить по ним —
   * блокировка защищает только на словах.
   */
  async hiddenAuthorIds(userId?: string): Promise<string[]> {
    if (!userId) return [];

    const cacheKey = `blocks:${userId}`;
    const cached = await this.redis.client.get(cacheKey).catch(() => null);
    if (cached !== null) {
      return cached === '' ? [] : cached.split(',');
    }

    const rows = await this.prisma.userBlock.findMany({
      where: { OR: [{ blockerId: userId }, { blockedId: userId }] },
      select: { blockerId: true, blockedId: true },
    });

    const ids = [
      ...new Set(rows.map((row) => (row.blockerId === userId ? row.blockedId : row.blockerId))),
    ];

    await this.redis.client
      .set(cacheKey, ids.join(','), 'EX', CACHE_TTL_SECONDS)
      .catch(() => undefined);

    return ids;
  }

  /** Обеим сторонам, иначе у одной из них выдача останется прежней до конца TTL. */
  private async invalidate(...userIds: string[]): Promise<void> {
    await this.redis.client
      .del(...userIds.map((id) => `blocks:${id}`))
      .catch((error: Error) => this.logger.warn(`Кэш блокировок не сброшен: ${error.message}`));
  }
}
