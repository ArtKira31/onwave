// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthStatus _$HealthStatusFromJson(Map<String, dynamic> json) => HealthStatus(
  status: HealthStatusStatus.fromJson(json['status'] as String),
  version: json['version'] as String?,
  gitSha: json['gitSha'] as String?,
);

Map<String, dynamic> _$HealthStatusToJson(HealthStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'version': instance.version,
      'gitSha': instance.gitSha,
    };
