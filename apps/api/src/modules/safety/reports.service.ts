import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { ReportTargetType } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { EventStatusService } from '../events/event-status.service';
import { RateLimitService } from '../../common/rate-limit/rate-limit.service';
import type { CreateReportRequest } from './dto/safety.dto';
import type { Env } from '../../common/config/env';

@Injectable()
export class ReportsService {
  private readonly logger = new Logger(ReportsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService<Env, true>,
    private readonly status: EventStatusService,
    private readonly limits: RateLimitService,
  ) {}

  /**
   * Жалоба (ONW-38). Требование App Store Guideline 1.2: без механизма жалобы
   * UGC-приложение отклоняют.
   *
   * Повторная жалоба того же человека на тот же объект не создаёт дубль и не
   * накручивает счётчик — иначе порог автоскрытия брался бы одним человеком
   * в одиночку.
   */
  async create(authorId: string, input: CreateReportRequest): Promise<void> {
    // Жалобами тоже злоупотребляют: заваливать ими неугодного автора —
    // ровно такой же спам, только через механизм защиты.
    await this.limits.consume({
      scope: 'report',
      subject: authorId,
      limit: this.config.get('RATE_LIMIT_REPORTS_PER_DAY', { infer: true }),
      windowSeconds: 86_400,
    });

    await this.assertTargetExists(input.targetType, input.targetId);

    if (input.targetType === 'user' && input.targetId === authorId) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Нельзя пожаловаться на самого себя',
        HttpStatus.BAD_REQUEST,
      );
    }

    await this.prisma.report.upsert({
      where: {
        authorId_targetType_targetId: {
          authorId,
          targetType: input.targetType,
          targetId: input.targetId,
        },
      },
      update: { reason: input.reason, comment: input.comment ?? null },
      create: {
        authorId,
        targetType: input.targetType,
        targetId: input.targetId,
        reason: input.reason,
        comment: input.comment ?? null,
      },
    });

    if (input.targetType === 'event') {
      await this.hideIfOverThreshold(input.targetId, authorId);
    }
  }

  /**
   * Порог независимых жалоб скрывает событие до решения модератора.
   *
   * Скрытие, а не удаление: контент нужен для разбора, а автор не должен
   * узнавать о жалобе раньше модератора.
   */
  private async hideIfOverThreshold(eventId: string, actorId: string): Promise<void> {
    const threshold = this.config.get('REPORTS_HIDE_THRESHOLD', { infer: true });

    const openReports = await this.prisma.report.count({
      where: { targetType: 'event', targetId: eventId, status: 'open' },
    });
    if (openReports < threshold) return;

    const event = await this.prisma.event.findUnique({ where: { id: eventId } });
    if (!event || event.status !== 'published') return;

    await this.prisma.$transaction([
      this.prisma.event.update({ where: { id: eventId }, data: { status: 'hidden' } }),
      this.prisma.moderationAction.create({
        data: this.status.journalEntry({
          eventId,
          from: event.status,
          to: 'hidden',
          actorId,
          reason: `Автоматически скрыто: жалоб ${openReports}`,
        }),
      }),
    ]);

    this.logger.warn({ eventId, reports: openReports }, 'Событие скрыто по жалобам');
  }

  private async assertTargetExists(type: ReportTargetType, id: string): Promise<void> {
    const exists =
      type === 'event'
        ? await this.prisma.event.findFirst({ where: { id, deletedAt: null }, select: { id: true } })
        : await this.prisma.user.findFirst({ where: { id, deletedAt: null }, select: { id: true } });

    if (!exists) {
      throw new AppException(
        ErrorCode.NOT_FOUND,
        type === 'event' ? 'Событие не найдено' : 'Пользователь не найден',
        HttpStatus.NOT_FOUND,
      );
    }
  }
}
