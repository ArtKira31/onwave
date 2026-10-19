// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'address_suggestion.dart';

part 'get_geo_autocomplete_response.g.dart';

@JsonSerializable()
class GetGeoAutocompleteResponse {
  const GetGeoAutocompleteResponse({
    required this.items,
  });
  
  factory GetGeoAutocompleteResponse.fromJson(Map<String, Object?> json) => _$GetGeoAutocompleteResponseFromJson(json);
  
  final List<AddressSuggestion> items;

  Map<String, Object?> toJson() => _$GetGeoAutocompleteResponseToJson(this);
}
