// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDetail _$EventDetailFromJson(Map<String, dynamic> json) => EventDetail(
  id: json['id'] as String,
  title: json['title'] as String,
  status: EventStatus.fromJson(json['status'] as String),
  cityId: json['cityId'] as String,
  author: UserPublic.fromJson(json['author'] as Map<String, dynamic>),
  sessions: (json['sessions'] as List<dynamic>)
      .map((e) => EventSession.fromJson(e as Map<String, dynamic>))
      .toList(),
  description: json['description'] as String?,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  venue: json['venue'] == null
      ? null
      : Venue.fromJson(json['venue'] as Map<String, dynamic>),
  rawAddress: json['rawAddress'] as String?,
  lat: json['lat'] as num?,
  lon: json['lon'] as num?,
  cover: json['cover'] == null
      ? null
      : MediaVariants.fromJson(json['cover'] as Map<String, dynamic>),
  gallery: (json['gallery'] as List<dynamic>?)
      ?.map((e) => MediaAsset.fromJson(e as Map<String, dynamic>))
      .toList(),
  ticketUrl: json['ticketUrl'] as String?,
  priceFrom: json['priceFrom'] as num?,
  isFavorite: json['isFavorite'] as bool?,
  canEdit: json['canEdit'] as bool?,
  rejectionReason: json['rejectionReason'] as String?,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$EventDetailToJson(EventDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'cityId': instance.cityId,
      'category': instance.category,
      'venue': instance.venue,
      'rawAddress': instance.rawAddress,
      'lat': instance.lat,
      'lon': instance.lon,
      'author': instance.author,
      'sessions': instance.sessions,
      'cover': instance.cover,
      'gallery': instance.gallery,
      'ticketUrl': instance.ticketUrl,
      'priceFrom': instance.priceFrom,
      'isFavorite': instance.isFavorite,
      'canEdit': instance.canEdit,
      'rejectionReason': instance.rejectionReason,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
