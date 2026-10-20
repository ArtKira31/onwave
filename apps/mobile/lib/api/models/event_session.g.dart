// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventSession _$EventSessionFromJson(Map<String, dynamic> json) => EventSession(
  id: json['id'] as String,
  startsAt: DateTime.parse(json['startsAt'] as String),
  endsAt: json['endsAt'] == null
      ? null
      : DateTime.parse(json['endsAt'] as String),
  isPast: json['isPast'] as bool?,
);

Map<String, dynamic> _$EventSessionToJson(EventSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startsAt': instance.startsAt.toIso8601String(),
      'endsAt': instance.endsAt?.toIso8601String(),
      'isPast': instance.isPast,
    };
