// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'event_session.g.dart';

@JsonSerializable()
class EventSession {
  const EventSession({
    required this.id,
    required this.startsAt,
    this.endsAt,
    this.isPast,
  });
  
  factory EventSession.fromJson(Map<String, Object?> json) => _$EventSessionFromJson(json);
  
  final String id;

  /// UTC. Локальное время считается по таймзоне города.
  final DateTime startsAt;
  final DateTime? endsAt;
  final bool? isPast;

  Map<String, Object?> toJson() => _$EventSessionToJson(this);
}
