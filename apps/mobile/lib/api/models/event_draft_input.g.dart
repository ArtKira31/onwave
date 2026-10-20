// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_draft_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDraftInput _$EventDraftInputFromJson(Map<String, dynamic> json) =>
    EventDraftInput(
      title: json['title'] as String?,
      description: json['description'] as String?,
      categorySlug: json['categorySlug'] as String?,
      cityId: json['cityId'] as String?,
      venueId: json['venueId'] as String?,
      rawAddress: json['rawAddress'] as String?,
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((e) => Sessions.fromJson(e as Map<String, dynamic>))
          .toList(),
      coverAssetId: json['coverAssetId'] as String?,
      galleryAssetIds: (json['galleryAssetIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ticketUrl: json['ticketUrl'] as String?,
      priceFrom: json['priceFrom'] as num?,
    );

Map<String, dynamic> _$EventDraftInputToJson(EventDraftInput instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'categorySlug': instance.categorySlug,
      'cityId': instance.cityId,
      'venueId': instance.venueId,
      'rawAddress': instance.rawAddress,
      'sessions': instance.sessions,
      'coverAssetId': instance.coverAssetId,
      'galleryAssetIds': instance.galleryAssetIds,
      'ticketUrl': instance.ticketUrl,
      'priceFrom': instance.priceFrom,
    };
