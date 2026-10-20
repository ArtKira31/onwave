// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_blocks_response.dart';
import '../models/report_input.dart';

part 'safety_client.g.dart';

@RestApi()
abstract class SafetyClient {
  factory SafetyClient(Dio dio, {String? baseUrl}) = _SafetyClient;

  /// Пожаловаться на событие или пользователя.
  ///
  /// Требование App Store Guideline 1.2 (ONW-38). Повторная жалоба того же.
  /// человека на тот же объект не создаёт дубль. При превышении порога.
  /// независимых жалоб событие автоматически уходит в `hidden` до решения.
  /// модератора. SLA реакции — 24 часа.
  @POST('/reports')
  Future<void> createReport({
    @Body() required ReportInput body,
  });

  /// Заблокировать пользователя.
  ///
  /// Односторонняя и мгновенная — решения модератора не требует. После неё.
  /// события автора пропадают из всех выдач для заблокировавшего (ONW-39).
  @POST('/users/{id}/block')
  Future<void> blockUser({
    @Path('id') required String id,
  });

  /// Снять блокировку.
  ///
  /// После снятия события автора снова появляются в выдачах.
  @DELETE('/users/{id}/block')
  Future<void> unblockUser({
    @Path('id') required String id,
  });

  /// Заблокированные пользователи.
  ///
  /// Нужен, чтобы пользователь мог разблокировать — иначе блокировка необратима.
  @GET('/blocks')
  Future<GetBlocksResponse> listBlockedUsers();
}
