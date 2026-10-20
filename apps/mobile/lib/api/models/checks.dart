// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'checks.g.dart';

@JsonSerializable()
class Checks {
  const Checks({
    this.database,
    this.redis,
    this.storage,
  });
  
  factory Checks.fromJson(Map<String, Object?> json) => _$ChecksFromJson(json);
  
  final bool? database;
  final bool? redis;
  final bool? storage;

  Map<String, Object?> toJson() => _$ChecksToJson(this);
}
