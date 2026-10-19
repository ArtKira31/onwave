// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_resolve_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoResolveRequestBody _$GeoResolveRequestBodyFromJson(
  Map<String, dynamic> json,
) => GeoResolveRequestBody(
  placeId: json['placeId'] as String?,
  address: json['address'] as String?,
);

Map<String, dynamic> _$GeoResolveRequestBodyToJson(
  GeoResolveRequestBody instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'address': instance.address,
};
