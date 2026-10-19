// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_public.dart';

part 'blocked_user.g.dart';

@JsonSerializable()
class BlockedUser {
  const BlockedUser({
    required this.user,
    required this.blockedAt,
  });
  
  factory BlockedUser.fromJson(Map<String, Object?> json) => _$BlockedUserFromJson(json);
  
  final UserPublic user;
  final DateTime blockedAt;

  Map<String, Object?> toJson() => _$BlockedUserToJson(this);
}
