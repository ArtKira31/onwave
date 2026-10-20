// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolved_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolvedAddress _$ResolvedAddressFromJson(Map<String, dynamic> json) =>
    ResolvedAddress(
      resolved: json['resolved'] as bool,
      address: json['address'] as String,
      lat: json['lat'] as num?,
      lon: json['lon'] as num?,
      cityId: json['cityId'] as String?,
      timezone: json['timezone'] as String?,
      venueId: json['venueId'] as String?,
    );

Map<String, dynamic> _$ResolvedAddressToJson(ResolvedAddress instance) =>
    <String, dynamic>{
      'resolved': instance.resolved,
      'address': instance.address,
      'lat': instance.lat,
      'lon': instance.lon,
      'cityId': instance.cityId,
      'timezone': instance.timezone,
      'venueId': instance.venueId,
    };
