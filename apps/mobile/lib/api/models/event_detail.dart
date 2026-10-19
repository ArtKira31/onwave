// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'event_session.dart';
import 'event_status.dart';
import 'media_asset.dart';
import 'media_variants.dart';
import 'user_public.dart';
import 'venue.dart';

part 'event_detail.g.dart';

@JsonSerializable()
class EventDetail {
  const EventDetail({
    required this.id,
    required this.title,
    required this.status,
    required this.cityId,
    required this.author,
    required this.sessions,
    this.description,
    this.category,
    this.venue,
    this.rawAddress,
    this.lat,
    this.lon,
    this.cover,
    this.gallery,
    this.ticketUrl,
    this.priceFrom,
    this.isFavorite,
    this.canEdit,
    this.rejectionReason,
    this.publishedAt,
    this.createdAt,
  });
  
  factory EventDetail.fromJson(Map<String, Object?> json) => _$EventDetailFromJson(json);
  
  final String id;
  final String title;
  final String? description;
  final EventStatus status;
  final String cityId;
  final Category? category;
  final Venue? venue;

  /// Свободный адрес, когда площадки в справочнике нет.
  final String? rawAddress;
  final num? lat;
  final num? lon;
  final UserPublic author;
  final List<EventSession> sessions;
  final MediaVariants? cover;
  final List<MediaAsset>? gallery;

  /// Внешняя ссылка. Приложение её открывает, оплаты внутри нет.
  final String? ticketUrl;
  final num? priceFrom;
  final bool? isFavorite;

  /// Клиент по нему решает, показывать ли кнопку редактирования.
  final bool? canEdit;
  final String? rejectionReason;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  Map<String, Object?> toJson() => _$EventDetailToJson(this);
}
