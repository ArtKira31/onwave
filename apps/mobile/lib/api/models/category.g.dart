// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String,
  slug: json['slug'] as String,
  nameKey: json['nameKey'] as String,
  icon: json['icon'] as String?,
  sortOrder: (json['sortOrder'] as num?)?.toInt(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'nameKey': instance.nameKey,
  'icon': instance.icon,
  'sortOrder': instance.sortOrder,
};
