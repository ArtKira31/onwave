// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'event_status.dart';
import 'media_variants.dart';

part 'event_card.g.dart';

/// Облегчённая карточка для ленты — без полного описания.
@JsonSerializable()
class EventCard {
  const EventCard({
    required this.id,
    required this.title,
    required this.status,
    required this.cityId,
    this.startsAt,
    this.sessionCount,
    this.cover,
    this.categorySlug,
    this.venueName,
    this.priceFrom,
    this.isFavorite,
    this.rejectionReason,
  });
  
  factory EventCard.fromJson(Map<String, Object?> json) => _$EventCardFromJson(json);
  
  final String id;
  final String title;
  final EventStatus status;

  /// Ближайший будущий сеанс. По нему сортируется лента.
  final DateTime? startsAt;

  /// Больше одного — в карточке показывается «и ещё N дат».
  final int? sessionCount;
  final MediaVariants? cover;
  final String? categorySlug;
  final String? venueName;
  final String cityId;

  /// Только для показа. Оплаты внутри приложения нет.
  final num? priceFrom;
  final bool? isFavorite;

  /// Приходит только в `/me/events` для статуса `rejected`.
  final String? rejectionReason;

  Map<String, Object?> toJson() => _$EventCardToJson(this);
}
