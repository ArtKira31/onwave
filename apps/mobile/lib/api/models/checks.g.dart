// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Checks _$ChecksFromJson(Map<String, dynamic> json) => Checks(
  database: json['database'] as bool?,
  redis: json['redis'] as bool?,
  storage: json['storage'] as bool?,
);

Map<String, dynamic> _$ChecksToJson(Checks instance) => <String, dynamic>{
  'database': instance.database,
  'redis': instance.redis,
  'storage': instance.storage,
};
