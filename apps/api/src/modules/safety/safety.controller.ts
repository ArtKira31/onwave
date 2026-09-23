import { Body, Controller, Delete, Get, HttpCode, HttpStatus, Param, ParseUUIDPipe, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ReportsService } from './reports.service';
import { BlocksService } from './blocks.service';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RequireAbility } from '../auth/rbac/require-ability.decorator';
import { Action } from '../auth/rbac/ability.factory';
import type { AccessTokenPayload } from '../auth/token.service';
import { BlockedUserDto, BlockedUserListDto, CreateReportRequest } from './dto/safety.dto';

@ApiTags('safety')
@ApiBearerAuth()
@Controller()
export class SafetyController {
  constructor(
    private readonly reports: ReportsService,
    private readonly blocks: BlocksService,
  ) {}

  @Post('reports')
  @HttpCode(HttpStatus.CREATED)
  @RequireAbility(Action.Create, 'Report')
  @ApiOperation({
    operationId: 'createReport',
    summary: 'Пожаловаться на событие или пользователя',
    description:
      'Требование App Store Guideline 1.2. Повторная жалоба того же человека на тот же ' +
      'объект не создаёт дубль и не накручивает счётчик автоскрытия.',
  })
  async report(
    @Body() body: CreateReportRequest,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<void> {
    await this.reports.create(current.sub, body);
  }

  @Post('users/:id/block')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    operationId: 'blockUser',
    summary: 'Заблокировать пользователя',
    description:
      'Односторонняя и мгновенная, решения модератора не требует. После неё события ' +
      'обеих сторон пропадают из выдач друг друга.',
  })
  block(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<void> {
    return this.blocks.block(current.sub, id);
  }

  @Delete('users/:id/block')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    operationId: 'unblockUser',
    summary: 'Снять блокировку',
    description: 'Идемпотентно: снятие несуществующей блокировки не ошибка.',
  })
  unblock(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<void> {
    return this.blocks.unblock(current.sub, id);
  }

  @Get('blocks')
  @ApiOperation({
    operationId: 'listBlockedUsers',
    summary: 'Заблокированные пользователи',
    description: 'Без этого списка блокировка необратима — снять её было бы негде.',
  })
  @ApiOkResponse({ type: BlockedUserListDto })
  async list(@CurrentUser() current: AccessTokenPayload): Promise<BlockedUserListDto> {
    const blocks = await this.blocks.list(current.sub);
    return { items: blocks.map(BlockedUserDto.from) };
  }
}
