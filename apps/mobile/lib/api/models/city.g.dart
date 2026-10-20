// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) => City(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  timezone: json['timezone'] as String,
  lat: json['lat'] as num?,
  lon: json['lon'] as num?,
);

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'timezone': instance.timezone,
  'lat': instance.lat,
  'lon': instance.lon,
};
