// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/event_detail.dart';
import '../models/kind.dart';
import '../models/moderation_events_id_reject_request_body.dart';
import '../models/moderation_queue_page.dart';

part 'moderation_client.g.dart';

@RestApi()
abstract class ModerationClient {
  factory ModerationClient(Dio dio, {String? baseUrl}) = _ModerationClient;

  /// Очередь модерации.
  ///
  /// Только для ролей `moderator` и `admin`. Сортировка по возрасту — самое.
  /// старое первым, поле `ageHours` показывает приближение к SLA в 24 часа.
  ///
  /// [cursor] - Непрозрачный курсор из `nextCursor` предыдущего ответа. Клиент его не.
  /// разбирает и не конструирует. Не offset (ONW-28).
  ///
  ///
  /// [limit] - Ограничен сверху, чтобы базу нельзя было выкачать одним запросом.
  @GET('/moderation/queue')
  Future<ModerationQueuePage> getModerationQueue({
    @Query('limit') int? limit = 20,
    @Query('kind') Kind? kind = Kind.pendingEvents,
    @Query('cursor') String? cursor,
  });

  /// Одобрить событие.
  ///
  /// Переводит `pending` в `published`. Решение пишется в журнал модерации.
  @POST('/moderation/events/{id}/approve')
  Future<EventDetail> approveEvent({
    @Path('id') required String id,
  });

  /// Отклонить событие.
  ///
  /// Причина обязательна и видна автору на экране «Мои события».
  @POST('/moderation/events/{id}/reject')
  Future<EventDetail> rejectEvent({
    @Path('id') required String id,
    @Body() required ModerationEventsIdRejectRequestBody body,
  });
}
