// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sessions.g.dart';

@JsonSerializable()
class Sessions {
  const Sessions({
    required this.startsAt,
    this.endsAt,
  });
  
  factory Sessions.fromJson(Map<String, Object?> json) => _$SessionsFromJson(json);
  
  final DateTime startsAt;
  final DateTime? endsAt;

  Map<String, Object?> toJson() => _$SessionsToJson(this);
}
