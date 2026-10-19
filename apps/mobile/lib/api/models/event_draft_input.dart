// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sessions.dart';

part 'event_draft_input.g.dart';

/// Все поля опциональны: форма сохраняется по шагам. Полная валидация.
/// включается на `submit`, а не здесь.
///
@JsonSerializable()
class EventDraftInput {
  const EventDraftInput({
    this.title,
    this.description,
    this.categorySlug,
    this.cityId,
    this.venueId,
    this.rawAddress,
    this.sessions,
    this.coverAssetId,
    this.galleryAssetIds,
    this.ticketUrl,
    this.priceFrom,
  });
  
  factory EventDraftInput.fromJson(Map<String, Object?> json) => _$EventDraftInputFromJson(json);
  
  final String? title;
  final String? description;
  final String? categorySlug;
  final String? cityId;
  final String? venueId;

  /// Свободный адрес. Разрешение адреса в площадку и координаты через.
  /// `placeId` появится вместе с геокодингом (ONW-36) — пока поле.
  /// в запрос не принимается, чтобы схема не обещала несуществующего.
  ///
  final String? rawAddress;
  final List<Sessions>? sessions;
  final String? coverAssetId;
  final List<String>? galleryAssetIds;

  /// Только http(s).
  final String? ticketUrl;
  final num? priceFrom;

  Map<String, Object?> toJson() => _$EventDraftInputToJson(this);
}
