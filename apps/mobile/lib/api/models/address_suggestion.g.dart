// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressSuggestion _$AddressSuggestionFromJson(Map<String, dynamic> json) =>
    AddressSuggestion(
      placeId: json['placeId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$AddressSuggestionToJson(AddressSuggestion instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'title': instance.title,
      'subtitle': instance.subtitle,
    };
