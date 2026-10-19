// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_cities_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCitiesResponse _$GetCitiesResponseFromJson(Map<String, dynamic> json) =>
    GetCitiesResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetCitiesResponseToJson(GetCitiesResponse instance) =>
    <String, dynamic>{'items': instance.items};
