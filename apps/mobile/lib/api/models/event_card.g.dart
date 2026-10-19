// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCard _$EventCardFromJson(Map<String, dynamic> json) => EventCard(
  id: json['id'] as String,
  title: json['title'] as String,
  status: EventStatus.fromJson(json['status'] as String),
  cityId: json['cityId'] as String,
  startsAt: json['startsAt'] == null
      ? null
      : DateTime.parse(json['startsAt'] as String),
  sessionCount: (json['sessionCount'] as num?)?.toInt(),
  cover: json['cover'] == null
      ? null
      : MediaVariants.fromJson(json['cover'] as Map<String, dynamic>),
  categorySlug: json['categorySlug'] as String?,
  venueName: json['venueName'] as String?,
  priceFrom: json['priceFrom'] as num?,
  isFavorite: json['isFavorite'] as bool?,
  rejectionReason: json['rejectionReason'] as String?,
);

Map<String, dynamic> _$EventCardToJson(EventCard instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': instance.status,
  'startsAt': instance.startsAt?.toIso8601String(),
  'sessionCount': instance.sessionCount,
  'cover': instance.cover,
  'categorySlug': instance.categorySlug,
  'venueName': instance.venueName,
  'cityId': instance.cityId,
  'priceFrom': instance.priceFrom,
  'isFavorite': instance.isFavorite,
  'rejectionReason': instance.rejectionReason,
};
