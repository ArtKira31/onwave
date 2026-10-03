import { Body, Controller, HttpCode, HttpStatus, Param, ParseUUIDPipe, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { MediaService } from './media.service';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AccessTokenPayload } from '../auth/token.service';
import { CreateUploadUrlRequest, MediaAssetDto, UploadTicketDto } from './dto/media.dto';

@ApiTags('media')
@ApiBearerAuth()
@Controller('media')
export class MediaController {
  constructor(private readonly media: MediaService) {}

  @Post('upload-url')
  @ApiOperation({
    operationId: 'createUploadUrl',
    summary: 'Presigned URL для загрузки',
    description:
      'Файл идёт напрямую в бакет мимо API. Тип и размер вшиты в подпись — ' +
      'клиент обязан прислать ровно те заголовки, что пришли в ответе.',
  })
  @ApiOkResponse({ type: UploadTicketDto })
  createUploadUrl(
    @Body() body: CreateUploadUrlRequest,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<UploadTicketDto> {
    return this.media.createUploadUrl(current, body);
  }

  @Post(':id/complete')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    operationId: 'completeUpload',
    summary: 'Подтвердить загрузку',
    description:
      'Сервер проверяет объект в бакете и определяет тип по содержимому, а не по ' +
      'заголовку. Дальше ставится задача на ресайз.',
  })
  @ApiOkResponse({ type: MediaAssetDto })
  async complete(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() current: AccessTokenPayload,
  ): Promise<MediaAssetDto> {
    return MediaAssetDto.from(await this.media.complete(current, id));
  }
}
