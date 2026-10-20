// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ErrorCode {
  @JsonValue('VALIDATION_FAILED')
  validationFailed('VALIDATION_FAILED'),
  @JsonValue('UNAUTHORIZED')
  unauthorized('UNAUTHORIZED'),
  @JsonValue('INVALID_OAUTH_TOKEN')
  invalidOauthToken('INVALID_OAUTH_TOKEN'),
  @JsonValue('FORBIDDEN')
  forbidden('FORBIDDEN'),
  @JsonValue('NOT_FOUND')
  notFound('NOT_FOUND'),
  @JsonValue('EVENT_NOT_FOUND')
  eventNotFound('EVENT_NOT_FOUND'),
  @JsonValue('INVALID_STATE_TRANSITION')
  invalidStateTransition('INVALID_STATE_TRANSITION'),
  @JsonValue('RATE_LIMITED')
  rateLimited('RATE_LIMITED'),
  @JsonValue('INTERNAL')
  internal('INTERNAL'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const ErrorCode(this.json);

  factory ErrorCode.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError('Cannot convert enum value with null JSON representation to String. '
          'This usually happens for \$unknown or @JsonValue(null) entries.');
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<ErrorCode> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
