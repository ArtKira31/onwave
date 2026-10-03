import { Controller, Delete, Get, HttpCode, HttpStatus, Param, ParseUUIDPipe, Put, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service';
import { ListFavoritesQueryDto } from './dto/list-favorites.query';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AccessTokenPayload } from '../auth/token.service';
import { EventCardPageDto } from '../events/dto/event.dto';

@ApiTags('favorites')
@ApiBearerAuth()
@Controller()
export class FavoritesController {
  constructor(private readonly favorites: FavoritesService) {}

  @Put('events/:id/favorite')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    operationId: 'addFavorite',
    summary: 'Добавить в избранное',
    description: 'Идемпотентно — повторный вызов не ошибка.',
  })
  add(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<void> {
    return this.favorites.add(current.sub, id);
  }

  @Delete('events/:id/favorite')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    operationId: 'removeFavorite',
    summary: 'Убрать из избранного',
    description: 'Идемпотентно — удаление отсутствующей записи не ошибка.',
  })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<void> {
    return this.favorites.remove(current.sub, id);
  }

  @Get('favorites')
  @ApiOperation({
    operationId: 'listFavorites',
    summary: 'Избранные события',
    description: 'Единственная в Фазе 0 причина, по которой зрителю нужен аккаунт.',
  })
  @ApiOkResponse({ type: EventCardPageDto })
  list(
    @Query() query: ListFavoritesQueryDto,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<EventCardPageDto> {
    return this.favorites.list(current.sub, query);
  }
}
