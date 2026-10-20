// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Me _$MeFromJson(Map<String, dynamic> json) => Me(
  id: json['id'] as String,
  role: UserRole.fromJson(json['role'] as String),
  isGuest: json['isGuest'] as bool,
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  acceptedTermsVersion: json['acceptedTermsVersion'] as String?,
);

Map<String, dynamic> _$MeToJson(Me instance) => <String, dynamic>{
  'id': instance.id,
  'role': instance.role,
  'isGuest': instance.isGuest,
  'email': instance.email,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'acceptedTermsVersion': instance.acceptedTermsVersion,
};
