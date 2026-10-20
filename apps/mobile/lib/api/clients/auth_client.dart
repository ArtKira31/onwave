// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_apple_request_body.dart';
import '../models/auth_guest_request_body.dart';
import '../models/auth_refresh_request_body.dart';
import '../models/auth_tokens.dart';
import '../models/o_auth_login_request.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  /// Гостевая сессия по device-id.
  ///
  /// Приложение работает без регистрации (ONW-21). Повторный запрос с тем же.
  /// device-id возвращает ту же гостевую учётку, а не создаёт новую.
  @POST('/auth/guest')
  Future<AuthTokens> createGuestSession({
    @Body() required AuthGuestRequestBody body,
  });

  /// Вход через Google.
  ///
  /// Обмен id_token на токены Onwave (ONW-23). Если запрос пришёл с гостевым.
  /// токеном в заголовке — гостевая учётка апгрейдится, а не дублируется.
  @POST('/auth/google')
  Future<AuthTokens> loginWithGoogle({
    @Body() required OAuthLoginRequest body,
  });

  /// Вход через Apple.
  ///
  /// Обязателен по правилам App Store при наличии любого другого соц-логина (ONW-24).
  /// Email может прийти в виде private relay или не прийти вовсе — аккаунт опирается.
  /// на `sub`. Имя Apple отдаёт только при первом входе, поэтому клиент передаёт его.
  /// именно тогда.
  @POST('/auth/apple')
  Future<AuthTokens> loginWithApple({
    @Body() required AuthAppleRequestBody body,
  });

  /// Обновление пары токенов.
  ///
  /// Refresh одноразовый: при обмене выдаётся новый, старый инвалидируется (ONW-22).
  /// Переиспользование старого refresh трактуется как кража и отзывает всю цепочку —.
  /// клиент получает 401 и уводит пользователя на экран входа.
  @POST('/auth/refresh')
  Future<AuthTokens> refreshTokens({
    @Body() required AuthRefreshRequestBody body,
  });

  /// Выход с текущего устройства.
  ///
  /// Отзывает refresh-цепочку этого устройства. Остальные сессии живут дальше.
  @POST('/auth/logout')
  Future<void> logout();

  /// Выход со всех устройств.
  ///
  /// Отзывает все refresh-цепочки пользователя. Нужен, если устройство потеряно.
  @POST('/auth/logout-all')
  Future<void> logoutAll();
}
