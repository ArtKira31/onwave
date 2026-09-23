import { Controller, Get, Param, ParseUUIDPipe, Query } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { EventsService } from './events.service';
import { ListEventsQuery } from './dto/list-events.query';
import { EventCardPageDto, EventDetailDto } from './dto/event.dto';

@ApiTags('events')
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
  list(@Query() query: ListEventsQuery): Promise<EventCardPageDto> {
    return this.events.list(query);
  }

  @Get(':id')
  @ApiOperation({
    operationId: 'getEvent',
    summary: 'Карточка события',
    description: 'Неопубликованное отдаёт 404, а не 403: чужой черновик не подтверждается.',
  })
  @ApiOkResponse({ type: EventDetailDto })
  getById(@Param('id', ParseUUIDPipe) id: string): Promise<EventDetailDto> {
    return this.events.getById(id);
  }
}
