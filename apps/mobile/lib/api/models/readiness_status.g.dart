// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readiness_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadinessStatus _$ReadinessStatusFromJson(Map<String, dynamic> json) =>
    ReadinessStatus(
      status: ReadinessStatusStatus.fromJson(json['status'] as String),
      checks: Checks.fromJson(json['checks'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadinessStatusToJson(ReadinessStatus instance) =>
    <String, dynamic>{'status': instance.status, 'checks': instance.checks};
