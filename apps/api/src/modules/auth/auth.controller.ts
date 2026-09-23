import { Body, Controller, HttpCode, HttpStatus, Post, Get } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';
import { Public } from './decorators/public.decorator';
import { CurrentUser } from './decorators/current-user.decorator';
import type { AccessTokenPayload } from './token.service';
import { AuthTokensDto, GuestSessionRequest, MeDto, RefreshRequest } from './dto/auth.dto';

@ApiTags('auth')
@Controller()
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly prisma: PrismaService,
  ) {}

  @Public()
  @Post('auth/guest')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    operationId: 'createGuestSession',
    summary: 'Гостевая сессия по device-id',
    description:
      'Приложение работает без регистрации. Повторный запрос с тем же device-id ' +
      'возвращает ту же учётку, а не создаёт новую.',
  })
  @ApiOkResponse({ type: AuthTokensDto })
  async guest(@Body() body: GuestSessionRequest): Promise<AuthTokensDto> {
    const { user, ...tokens } = await this.auth.createGuestSession(body.deviceId);
    return { ...tokens, user: MeDto.from(user) };
  }

  @Public()
  @Post('auth/refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    operationId: 'refreshTokens',
    summary: 'Обновление пары токенов',
    description:
      'Refresh одноразовый. Переиспользование погашенного токена трактуется как ' +
      'кража и отзывает всю цепочку сессий — клиент получает 401.',
  })
  @ApiOkResponse({ type: AuthTokensDto })
  async refresh(@Body() body: RefreshRequest): Promise<AuthTokensDto> {
    const { user, ...tokens } = await this.auth.refresh(body.refreshToken);
    return { ...tokens, user: MeDto.from(user) };
  }

  @ApiBearerAuth()
  @Post('auth/logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    operationId: 'logout',
    summary: 'Выход с текущего устройства',
    description: 'Отзывает сессии устройства из access-токена. Остальные устройства не трогает.',
  })
  async logout(@CurrentUser() current: AccessTokenPayload): Promise<void> {
    await this.auth.logout(current.sub, current.deviceId);
  }

  @ApiBearerAuth()
  @Post('auth/logout-all')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ operationId: 'logoutAll', summary: 'Выход со всех устройств' })
  async logoutAll(@CurrentUser() current: AccessTokenPayload): Promise<void> {
    await this.auth.logoutAll(current.sub);
  }

  @ApiBearerAuth()
  @Get('me')
  @ApiOperation({ operationId: 'getMe', summary: 'Текущий пользователь' })
  @ApiOkResponse({ type: MeDto })
  async me(@CurrentUser() current: AccessTokenPayload): Promise<MeDto> {
    const user = await this.prisma.user.findUnique({ where: { id: current.sub } });
    if (!user) {
      // Токен валиден, но пользователя нет: удалён, пока access был жив.
      throw new AppException(ErrorCode.UNAUTHORIZED, 'Пользователь не найден', HttpStatus.UNAUTHORIZED);
    }
    return MeDto.from(user);
  }
}
