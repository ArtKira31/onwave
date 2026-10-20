// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_public.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPublic _$UserPublicFromJson(Map<String, dynamic> json) => UserPublic(
  id: json['id'] as String,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isOrganizer: json['isOrganizer'] as bool?,
);

Map<String, dynamic> _$UserPublicToJson(UserPublic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'isOrganizer': instance.isOrganizer,
    };
