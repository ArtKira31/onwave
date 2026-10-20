// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'resolved_address.g.dart';

@JsonSerializable()
class ResolvedAddress {
  const ResolvedAddress({
    required this.resolved,
    required this.address,
    this.lat,
    this.lon,
    this.cityId,
    this.timezone,
    this.venueId,
  });
  
  factory ResolvedAddress.fromJson(Map<String, Object?> json) => _$ResolvedAddressFromJson(json);
  
  /// False — адрес не распознан. Событие всё равно создаётся, но получает.
  /// пометку для модератора.
  ///
  final bool resolved;
  final String address;
  final num? lat;
  final num? lon;
  final String? cityId;
  final String? timezone;

  /// Если адрес совпал с площадкой из справочника.
  final String? venueId;

  Map<String, Object?> toJson() => _$ResolvedAddressToJson(this);
}
