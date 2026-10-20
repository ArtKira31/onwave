// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'geo_resolve_request_body.g.dart';

@JsonSerializable()
class GeoResolveRequestBody {
  const GeoResolveRequestBody({
    this.placeId,
    this.address,
  });
  
  factory GeoResolveRequestBody.fromJson(Map<String, Object?> json) => _$GeoResolveRequestBodyFromJson(json);
  
  final String? placeId;
  final String? address;

  Map<String, Object?> toJson() => _$GeoResolveRequestBodyToJson(this);
}
