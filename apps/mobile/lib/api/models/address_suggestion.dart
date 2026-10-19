// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'address_suggestion.g.dart';

@JsonSerializable()
class AddressSuggestion {
  const AddressSuggestion({
    required this.placeId,
    required this.title,
    this.subtitle,
  });
  
  factory AddressSuggestion.fromJson(Map<String, Object?> json) => _$AddressSuggestionFromJson(json);
  
  final String placeId;
  final String title;
  final String? subtitle;

  Map<String, Object?> toJson() => _$AddressSuggestionToJson(this);
}
