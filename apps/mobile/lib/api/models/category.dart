// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  const Category({
    required this.id,
    required this.slug,
    required this.nameKey,
    this.icon,
    this.sortOrder,
  });
  
  factory Category.fromJson(Map<String, Object?> json) => _$CategoryFromJson(json);
  
  final String id;
  final String slug;

  /// Ключ локализации, не готовая строка.
  final String nameKey;
  final String? icon;
  final int? sortOrder;

  Map<String, Object?> toJson() => _$CategoryToJson(this);
}
