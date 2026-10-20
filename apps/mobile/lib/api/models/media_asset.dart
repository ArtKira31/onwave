// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'media_variants.dart';

part 'media_asset.g.dart';

@JsonSerializable()
class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.isConfirmed,
    this.isProcessed,
    this.width,
    this.height,
    this.variants,
  });
  
  factory MediaAsset.fromJson(Map<String, Object?> json) => _$MediaAssetFromJson(json);
  
  final String id;
  final bool isConfirmed;

  /// Варианты готовы.
  final bool? isProcessed;
  final int? width;
  final int? height;
  final MediaVariants? variants;

  Map<String, Object?> toJson() => _$MediaAssetToJson(this);
}
