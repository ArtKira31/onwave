// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'o_auth_login_request.dart';

part 'auth_apple_request_body.g.dart';

@JsonSerializable()
class AuthAppleRequestBody {
  const AuthAppleRequestBody({
    required this.idToken,
    required this.deviceId,
    this.fullName,
  });
  
  factory AuthAppleRequestBody.fromJson(Map<String, Object?> json) => _$AuthAppleRequestBodyFromJson(json);
  
  final String idToken;

  /// Тот же, что в гостевой сессии — по нему гость апгрейдится.
  final String deviceId;

  /// Только при первом входе. Второй раз Apple его не отдаст.
  final String? fullName;

  Map<String, Object?> toJson() => _$AuthAppleRequestBodyToJson(this);
}
