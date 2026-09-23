import { Controller, Get, Param, ParseUUIDPipe, Query } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { EventsService } from './events.service';
import { ListEventsQuery } from './dto/list-events.query';
import { EventCardPageDto, EventDetailDto } from './dto/event.dto';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AccessTokenPayload } from '../auth/token.service';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('events')
@Public()
@Controller('events')
export class EventsController {
  constructor(private readonly events: EventsService) {}

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

  @Get(':id')
  @ApiOperation({
    operationId: 'getEvent',
    summary: 'Карточка события',
    description: 'Неопубликованное отдаёт 404, а не 403: чужой черновик не подтверждается.',
  })
  @ApiOkResponse({ type: EventDetailDto })
  getById(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current?: AccessTokenPayload,
  ): Promise<EventDetailDto> {
    return this.events.getById(id, current?.sub);
  }
}
