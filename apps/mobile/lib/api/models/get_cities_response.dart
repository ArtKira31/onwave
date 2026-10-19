// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'city.dart';

part 'get_cities_response.g.dart';

@JsonSerializable()
class GetCitiesResponse {
  const GetCitiesResponse({
    required this.items,
  });
  
  factory GetCitiesResponse.fromJson(Map<String, Object?> json) => _$GetCitiesResponseFromJson(json);
  
  final List<City> items;

  Map<String, Object?> toJson() => _$GetCitiesResponseToJson(this);
}
