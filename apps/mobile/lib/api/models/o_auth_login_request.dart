// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'o_auth_login_request.g.dart';

@JsonSerializable()
class OAuthLoginRequest {
  const OAuthLoginRequest({
    required this.idToken,
    required this.deviceId,
  });
  
  factory OAuthLoginRequest.fromJson(Map<String, Object?> json) => _$OAuthLoginRequestFromJson(json);
  
  final String idToken;

  /// Тот же, что в гостевой сессии — по нему гость апгрейдится.
  final String deviceId;

  Map<String, Object?> toJson() => _$OAuthLoginRequestToJson(this);
}
