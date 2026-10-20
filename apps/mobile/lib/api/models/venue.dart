// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'venue.g.dart';

@JsonSerializable()
class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.address,
    this.lat,
    this.lon,
    this.cityId,
  });
  
  factory Venue.fromJson(Map<String, Object?> json) => _$VenueFromJson(json);
  
  final String id;
  final String name;
  final String address;
  final num? lat;
  final num? lon;
  final String? cityId;

  Map<String, Object?> toJson() => _$VenueToJson(this);
}
