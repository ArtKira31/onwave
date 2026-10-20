// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/media_asset.dart';
import '../models/media_upload_url_request_body.dart';
import '../models/upload_ticket.dart';

part 'media_client.g.dart';

@RestApi()
abstract class MediaClient {
  factory MediaClient(Dio dio, {String? baseUrl}) = _MediaClient;

  /// Presigned URL для загрузки.
  ///
  /// Файл идёт напрямую в бакет мимо API (ONW-34) — иначе на загрузках ляжет.
  /// весь трафик приложения. URL живёт минуты.
  @POST('/media/upload-url')
  Future<UploadTicket> createUploadUrl({
    @Body() required MediaUploadUrlRequestBody body,
  });

  /// Подтвердить загрузку.
  ///
  /// Сервер проверяет реальный объект в бакете и ставит задачу на ресайз (ONW-35).
  /// До готовности вариантов карточка показывает плейсхолдер.
  @POST('/media/{id}/complete')
  Future<MediaAsset> completeUpload({
    @Path('id') required String id,
  });
}
