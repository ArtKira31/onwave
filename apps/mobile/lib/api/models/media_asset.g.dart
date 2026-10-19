// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaAsset _$MediaAssetFromJson(Map<String, dynamic> json) => MediaAsset(
  id: json['id'] as String,
  isConfirmed: json['isConfirmed'] as bool,
  isProcessed: json['isProcessed'] as bool?,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  variants: json['variants'] == null
      ? null
      : MediaVariants.fromJson(json['variants'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MediaAssetToJson(MediaAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isConfirmed': instance.isConfirmed,
      'isProcessed': instance.isProcessed,
      'width': instance.width,
      'height': instance.height,
      'variants': instance.variants,
    };
