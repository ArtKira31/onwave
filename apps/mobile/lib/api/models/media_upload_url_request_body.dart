// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mime_type.dart';

part 'media_upload_url_request_body.g.dart';

@JsonSerializable()
class MediaUploadUrlRequestBody {
  const MediaUploadUrlRequestBody({
    required this.mimeType,
    required this.sizeBytes,
  });
  
  factory MediaUploadUrlRequestBody.fromJson(Map<String, Object?> json) => _$MediaUploadUrlRequestBodyFromJson(json);
  
  final MimeType mimeType;

  /// Реальный размер проверяется политикой presigned URL.
  final int sizeBytes;

  Map<String, Object?> toJson() => _$MediaUploadUrlRequestBodyToJson(this);
}
