// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_card_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCardPage _$EventCardPageFromJson(Map<String, dynamic> json) =>
    EventCardPage(
      items: (json['items'] as List<dynamic>)
          .map((e) => EventCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$EventCardPageToJson(EventCardPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
    };
