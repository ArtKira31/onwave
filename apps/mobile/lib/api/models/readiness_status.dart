// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'checks.dart';
import 'readiness_status_status.dart';

part 'readiness_status.g.dart';

@JsonSerializable()
class ReadinessStatus {
  const ReadinessStatus({
    required this.status,
    required this.checks,
  });
  
  factory ReadinessStatus.fromJson(Map<String, Object?> json) => _$ReadinessStatusFromJson(json);
  
  final ReadinessStatusStatus status;
  final Checks checks;

  Map<String, Object?> toJson() => _$ReadinessStatusToJson(this);
}
