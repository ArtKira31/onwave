// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'media_variants.g.dart';

/// Заполняется воркером ресайза (ONW-35). Пока пусто — клиент показывает.
/// плейсхолдер, а не битую картинку.
///
@JsonSerializable()
class MediaVariants {
  const MediaVariants({
    this.thumb,
    this.medium,
    this.large,
  });
  
  factory MediaVariants.fromJson(Map<String, Object?> json) => _$MediaVariantsFromJson(json);
  
  final String? thumb;
  final String? medium;
  final String? large;

  Map<String, Object?> toJson() => _$MediaVariantsToJson(this);
}
