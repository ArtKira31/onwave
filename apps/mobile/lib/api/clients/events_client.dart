// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/event_card_page.dart';
import '../models/event_detail.dart';
import '../models/event_draft_input.dart';
import '../models/preset.dart';

part 'events_client.g.dart';

@RestApi()
abstract class EventsClient {
  factory EventsClient(Dio dio, {String? baseUrl}) = _EventsClient;

  /// Лента событий.
  ///
  /// Главный запрос приложения (ONW-28). Отдаются только события в статусе.
  /// `published`, у которых есть хотя бы один будущий сеанс. Контент.
  /// заблокированных авторов отфильтрован (ONW-39).
  ///
  /// [city] - Slug или id города. Лента всегда скоупится по городу.
  ///
  /// [cursor] - Непрозрачный курсор из `nextCursor` предыдущего ответа. Клиент его не.
  /// разбирает и не конструирует. Не offset (ONW-28).
  ///
  ///
  /// [limit] - Ограничен сверху, чтобы базу нельзя было выкачать одним запросом.
  ///
  /// [category] - Один или несколько slug категорий.
  ///
  /// [preset] - Готовый диапазон дат, считается по таймзоне города. Взаимоисключим.
  /// с `dateFrom`/`dateTo`.
  ///
  ///
  /// [query] - Полнотекстовый поиск по названию и описанию.
  @GET('/events')
  Future<EventCardPage> listEvents({
    @Query('city') required String city,
    @Query('limit') int? limit = 20,
    @Query('cursor') String? cursor,
    @Query('category') List<String>? category,
    @Query('dateFrom') DateTime? dateFrom,
    @Query('dateTo') DateTime? dateTo,
    @Query('preset') Preset? preset,
    @Query('query') String? query,
  });

  /// Создать черновик события.
  ///
  /// Создаётся именно черновик (ONW-30): форма мультишаговая, целиком её никто.
  /// не отправляет. Публикация — отдельным переходом `submit`.
  ///
  /// [idempotencyKey] - Защита от двойного тапа — повтор с тем же ключом вернёт то же событие.
  @POST('/events')
  Future<EventDetail> createEvent({
    @Body() required EventDraftInput body,
    @Header('Idempotency-Key') String? idempotencyKey,
  });

  /// Карточка события.
  ///
  /// Опубликованное видно всем, включая гостя. Черновик и `pending` — только.
  /// автору и модератору; остальным **404, а не 403**: существование чужого.
  /// черновика не подтверждается.
  @GET('/events/{id}')
  Future<EventDetail> getEvent({
    @Path('id') required String id,
  });

  /// Обновить черновик.
  ///
  /// Частичное обновление — форма сохраняется по шагам. Редактировать можно.
  /// свой `draft` и `rejected`; правка опубликованного отправляет его на.
  /// повторную модерацию.
  @PATCH('/events/{id}')
  Future<EventDetail> updateEvent({
    @Path('id') required String id,
    @Body() required EventDraftInput body,
  });

  /// Отправить событие на модерацию.
  ///
  /// Здесь включается полная валидация обязательных полей — до этого момента.
  /// черновик может быть каким угодно неполным. У роли `organizer` событие.
  /// публикуется сразу, минуя очередь.
  @POST('/events/{id}/submit')
  Future<EventDetail> submitEvent({
    @Path('id') required String id,
  });
}
