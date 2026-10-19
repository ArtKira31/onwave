// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()
class City {
  const City({
    required this.id,
    required this.slug,
    required this.name,
    required this.timezone,
    this.lat,
    this.lon,
  });
  
  factory City.fromJson(Map<String, Object?> json) => _$CityFromJson(json);
  
  final String id;
  final String slug;
  final String name;

  /// IANA-таймзона. «Сегодня» и пресеты дат считаются по ней, а не по.
  /// времени телефона.
  ///
  final String timezone;
  final num? lat;
  final num? lon;

  Map<String, Object?> toJson() => _$CityToJson(this);
}
