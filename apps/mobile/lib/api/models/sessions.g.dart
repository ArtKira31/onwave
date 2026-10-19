// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sessions _$SessionsFromJson(Map<String, dynamic> json) => Sessions(
  startsAt: DateTime.parse(json['startsAt'] as String),
  endsAt: json['endsAt'] == null
      ? null
      : DateTime.parse(json['endsAt'] as String),
);

Map<String, dynamic> _$SessionsToJson(Sessions instance) => <String, dynamic>{
  'startsAt': instance.startsAt.toIso8601String(),
  'endsAt': instance.endsAt?.toIso8601String(),
};
