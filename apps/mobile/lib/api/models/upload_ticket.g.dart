// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadTicket _$UploadTicketFromJson(Map<String, dynamic> json) => UploadTicket(
  assetId: json['assetId'] as String,
  uploadUrl: json['uploadUrl'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  method: json['method'] == null
      ? UploadTicketMethod.put
      : UploadTicketMethod.fromJson(json['method'] as String),
);

Map<String, dynamic> _$UploadTicketToJson(UploadTicket instance) =>
    <String, dynamic>{
      'assetId': instance.assetId,
      'uploadUrl': instance.uploadUrl,
      'method': instance.method,
      'headers': instance.headers,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
