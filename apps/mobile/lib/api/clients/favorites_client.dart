// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/event_card_page.dart';
import '../models/scope.dart';

part 'favorites_client.g.dart';

@RestApi()
abstract class FavoritesClient {
  factory FavoritesClient(Dio dio, {String? baseUrl}) = _FavoritesClient;

  /// Добавить в избранное.
  ///
  /// Идемпотентно — повторный вызов не ошибка.
  @PUT('/events/{id}/favorite')
  Future<void> addFavorite({
    @Path('id') required String id,
  });

  /// Убрать из избранного.
  ///
  /// Идемпотентно — удаление отсутствующей записи не ошибка.
  @DELETE('/events/{id}/favorite')
  Future<void> removeFavorite({
    @Path('id') required String id,
  });

  /// Избранные события.
  ///
  /// Единственная в Фазе 0 причина, по которой зрителю нужен аккаунт.
  ///
  /// [cursor] - Непрозрачный курсор из `nextCursor` предыдущего ответа. Клиент его не.
  /// разбирает и не конструирует. Не offset (ONW-28).
  ///
  ///
  /// [limit] - Ограничен сверху, чтобы базу нельзя было выкачать одним запросом.
  ///
  /// [scope] - Прошедшие события отделены от будущих.
  @GET('/favorites')
  Future<EventCardPage> listFavorites({
    @Query('limit') int? limit = 20,
    @Query('scope') Scope? scope = Scope.upcoming,
    @Query('cursor') String? cursor,
  });
}
