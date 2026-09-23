import { Body, Controller, Get, HttpCode, HttpStatus, Param, ParseUUIDPipe, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ModerationService } from './moderation.service';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RequireAbility } from '../auth/rbac/require-ability.decorator';
import { Action } from '../auth/rbac/ability.factory';
import type { AccessTokenPayload } from '../auth/token.service';
import { ListQueueQuery, QueuePageDto, RejectEventRequest } from './dto/moderation.dto';

@ApiTags('moderation')
@ApiBearerAuth()
@Controller('moderation')
export class ModerationController {
  constructor(private readonly moderation: ModerationService) {}

  @Get('queue')
  @RequireAbility(Action.Moderate, 'Event')
  @ApiOperation({
    operationId: 'getModerationQueue',
    summary: 'Очередь модерации',
    description:
      'Сортировка по возрасту, самое старое первым. Поле ageHours показывает ' +
      'приближение к SLA в 24 часа, lockedBy — кто уже разбирает запись.',
  })
  @ApiOkResponse({ type: QueuePageDto })
  queue(@Query() query: ListQueueQuery): Promise<unknown> {
    return this.moderation.queue(query);
  }

  @Post('events/:id/approve')
  @HttpCode(HttpStatus.OK)
  @RequireAbility(Action.Moderate, 'Event')
  @ApiOperation({ operationId: 'approveEvent', summary: 'Одобрить событие' })
  approve(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<unknown> {
    return this.moderation.approve(current, id);
  }

  @Post('events/:id/reject')
  @HttpCode(HttpStatus.OK)
  @RequireAbility(Action.Moderate, 'Event')
  @ApiOperation({
    operationId: 'rejectEvent',
    summary: 'Отклонить событие',
    description: 'Причина обязательна и видна автору на экране «Мои события».',
  })
  reject(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: RejectEventRequest,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<unknown> {
    return this.moderation.reject(current, id, body);
  }
}
