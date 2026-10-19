// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'error_code.dart';

part 'error.g.dart';

/// ONW-17: один формат на всё API. Мобилка ветвит логику по `code`, текст.
/// `message` показывать пользователю напрямую не обязана.
///
@JsonSerializable()
class Error {
  const Error({
    required this.code,
    required this.message,
    this.details,
    this.requestId,
  });
  
  factory Error.fromJson(Map<String, Object?> json) => _$ErrorFromJson(json);
  
  final ErrorCode code;
  final String message;

  /// Пофайловые ошибки валидации либо контекст ошибки.
  final dynamic details;

  /// Совпадает с request-id в логах — по нему ищется вся цепочка.
  final String? requestId;

  Map<String, Object?> toJson() => _$ErrorToJson(this);
}
