// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_role.dart';

part 'me.g.dart';

@JsonSerializable()
class Me {
  const Me({
    required this.id,
    required this.role,
    required this.isGuest,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.acceptedTermsVersion,
  });
  
  factory Me.fromJson(Map<String, Object?> json) => _$MeFromJson(json);
  
  final String id;
  final UserRole role;

  /// У гостя нет аккаунта, но есть валидная сессия.
  final bool isGuest;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  /// Версия принятого EULA (ONW-61). Null — согласие ещё не получено.
  final String? acceptedTermsVersion;

  Map<String, Object?> toJson() => _$MeToJson(this);
}
