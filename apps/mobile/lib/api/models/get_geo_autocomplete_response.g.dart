// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_geo_autocomplete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetGeoAutocompleteResponse _$GetGeoAutocompleteResponseFromJson(
  Map<String, dynamic> json,
) => GetGeoAutocompleteResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => AddressSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetGeoAutocompleteResponseToJson(
  GetGeoAutocompleteResponse instance,
) => <String, dynamic>{'items': instance.items};
