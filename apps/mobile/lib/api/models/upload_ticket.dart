// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'upload_ticket_method.dart';

part 'upload_ticket.g.dart';

@JsonSerializable()
class UploadTicket {
  const UploadTicket({
    required this.assetId,
    required this.uploadUrl,
    required this.expiresAt,
    this.headers,
    this.method = UploadTicketMethod.put,
  });
  
  factory UploadTicket.fromJson(Map<String, Object?> json) => _$UploadTicketFromJson(json);
  
  final String assetId;
  final String uploadUrl;
  final UploadTicketMethod method;

  /// Заголовки, которые клиент обязан отправить вместе с файлом.
  final Map<String, String>? headers;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$UploadTicketToJson(this);
}
