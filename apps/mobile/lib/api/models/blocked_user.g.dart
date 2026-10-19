// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedUser _$BlockedUserFromJson(Map<String, dynamic> json) => BlockedUser(
  user: UserPublic.fromJson(json['user'] as Map<String, dynamic>),
  blockedAt: DateTime.parse(json['blockedAt'] as String),
);

Map<String, dynamic> _$BlockedUserToJson(BlockedUser instance) =>
    <String, dynamic>{
      'user': instance.user,
      'blockedAt': instance.blockedAt.toIso8601String(),
    };
