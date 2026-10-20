// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_url_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaUploadUrlRequestBody _$MediaUploadUrlRequestBodyFromJson(
  Map<String, dynamic> json,
) => MediaUploadUrlRequestBody(
  mimeType: MimeType.fromJson(json['mimeType'] as String),
  sizeBytes: (json['sizeBytes'] as num).toInt(),
);

Map<String, dynamic> _$MediaUploadUrlRequestBodyToJson(
  MediaUploadUrlRequestBody instance,
) => <String, dynamic>{
  'mimeType': instance.mimeType,
  'sizeBytes': instance.sizeBytes,
};
