import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { EventsService } from './events.service';
import { EventWritesService } from './event-writes.service';
import { ListEventsQuery } from './dto/list-events.query';
import { ListMyEventsQuery } from './dto/list-my-events.query';
import { EventDraftInput } from './dto/event-draft.input';
import { EventCardPageDto, EventDetailDto } from './dto/event.dto';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Public } from '../auth/decorators/public.decorator';
import { RequireAbility } from '../auth/rbac/require-ability.decorator';
import { Action } from '../auth/rbac/ability.factory';
import type { AccessTokenPayload } from '../auth/token.service';

@ApiTags('events')
@Controller('events')
export class EventsController {
  constructor(
    private readonly events: EventsService,
    private readonly writes: EventWritesService,
  ) {}

  @Public()
  @Get()
  @ApiOperation({
    operationId: 'listEvents',
    summary: 'Лента событий',
    description:
      'Только published с будущими сеансами. Пагинация курсорная: курсор непрозрачен, ' +
      'клиент его не конструирует. Доступна гостю.',
  })
  @ApiOkResponse({ type: EventCardPageDto })
  list(
    @Query() query: ListEventsQuery,
    // Маршрут публичный, но если токен пришёл — гард его разобрал, и лента
    // может честно проставить isFavorite.
    @CurrentUser() current?: AccessTokenPayload,
  ): Promise<EventCardPageDto> {
    return this.events.list(query, current?.sub);
  }

  @ApiBearerAuth()
  @Post()
  @RequireAbility(Action.Create, 'Event')
  @ApiOperation({
    operationId: 'createEvent',
    summary: 'Создать черновик события',
    description:
      'Создаётся именно черновик: форма мультишаговая. Публикация — отдельным ' +
      'переходом submit. Гостю недоступно.',
  })
  @ApiHeader({
    name: 'Idempotency-Key',
    required: false,
    description: 'Повтор с тем же ключом вернёт то же событие, а не создаст второе.',
  })
  @ApiOkResponse({ type: EventDetailDto })
  async create(
    @Body() input: EventDraftInput,
    @CurrentUser() current: AccessTokenPayload,
    @Headers('idempotency-key') idempotencyKey?: string,
  ): Promise<EventDetailDto> {
    const event = await this.writes.create(current, input, idempotencyKey);
    return this.events.getById(event.id, current);
  }

  @ApiBearerAuth()
  @Patch(':id')
  @ApiOperation({
    operationId: 'updateEvent',
    summary: 'Обновить черновик',
    description:
      'Частичное обновление — форма сохраняется по шагам. Правка опубликованного ' +
      'отправляет его на повторную модерацию.',
  })
  @ApiOkResponse({ type: EventDetailDto })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() input: EventDraftInput,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<EventDetailDto> {
    await this.writes.update(current, id, input);
    return this.events.getById(id, current);
  }

  @ApiBearerAuth()
  @Post(':id/submit')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    operationId: 'submitEvent',
    summary: 'Отправить событие на модерацию',
    description:
      'Здесь включается полная валидация обязательных полей. У роли organizer ' +
      'событие публикуется сразу, минуя очередь.',
  })
  @ApiOkResponse({ type: EventDetailDto })
  async submit(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<EventDetailDto> {
    await this.writes.submit(current, id);
    return this.events.getById(id, current);
  }

  @Public()
  @Get(':id')
  @ApiOperation({
    operationId: 'getEvent',
    summary: 'Карточка события',
    description:
      'Опубликованное видно всем. Черновик и pending — только автору и модератору, ' +
      'остальным 404, а не 403: чужой черновик не подтверждается.',
  })
  @ApiOkResponse({ type: EventDetailDto })
  getById(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current?: AccessTokenPayload,
  ): Promise<EventDetailDto> {
    return this.events.getById(id, current);
  }
}

@ApiTags('me')
@ApiBearerAuth()
@Controller('me')
export class MyEventsController {
  constructor(private readonly events: EventsService) {}

  @Get('events')
  @ApiOperation({
    operationId: 'listMyEvents',
    summary: 'Мои события',
    description: 'Со статусами модерации и причиной отказа: автор должен понимать, почему его событие не в ленте.',
  })
  @ApiOkResponse({ type: EventCardPageDto })
  list(
    @Query() query: ListMyEventsQuery,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<EventCardPageDto> {
    return this.events.listMine(current.sub, query);
  }
}
