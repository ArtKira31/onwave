// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/event_card_page.dart';
import '../models/event_status.dart';
import '../models/me.dart';

part 'me_client.g.dart';

@RestApi()
abstract class MeClient {
  factory MeClient(Dio dio, {String? baseUrl}) = _MeClient;

  /// Текущий пользователь.
  ///
  /// Профиль владельца токена. Для гостя `isGuest` = true и профиль почти пустой.
  @GET('/me')
  Future<Me> getMe();

  /// Мои события.
  ///
  /// Экран «Мои события» (ONW-58) — пользователь должен понимать, почему его.
  /// событие не видно в ленте, поэтому статус и причина отказа приходят здесь.
  ///
  /// [cursor] - Непрозрачный курсор из `nextCursor` предыдущего ответа. Клиент его не.
  /// разбирает и не конструирует. Не offset (ONW-28).
  ///
  ///
  /// [limit] - Ограничен сверху, чтобы базу нельзя было выкачать одним запросом.
  @GET('/me/events')
  Future<EventCardPage> listMyEvents({
    @Query('limit') int? limit = 20,
    @Query('cursor') String? cursor,
    @Query('status') List<EventStatus>? status,
  });
}
