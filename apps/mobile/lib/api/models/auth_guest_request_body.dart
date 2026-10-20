// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'auth_guest_request_body.g.dart';

@JsonSerializable()
class AuthGuestRequestBody {
  const AuthGuestRequestBody({
    required this.deviceId,
  });
  
  factory AuthGuestRequestBody.fromJson(Map<String, Object?> json) => _$AuthGuestRequestBodyFromJson(json);
  
  /// Генерируется клиентом один раз и живёт в secure storage.
  final String deviceId;

  Map<String, Object?> toJson() => _$AuthGuestRequestBodyToJson(this);
}
