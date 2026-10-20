// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'me.dart';

part 'auth_tokens.g.dart';

@JsonSerializable()
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });
  
  factory AuthTokens.fromJson(Map<String, Object?> json) => _$AuthTokensFromJson(json);
  
  final String accessToken;
  final String refreshToken;

  /// Время жизни access-токена в секундах.
  final int expiresIn;
  final Me user;

  Map<String, Object?> toJson() => _$AuthTokensToJson(this);
}
