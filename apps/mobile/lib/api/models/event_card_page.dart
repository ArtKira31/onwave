// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'event_card.dart';

part 'event_card_page.g.dart';

@JsonSerializable()
class EventCardPage {
  const EventCardPage({
    required this.items,
    this.nextCursor,
  });
  
  factory EventCardPage.fromJson(Map<String, Object?> json) => _$EventCardPageFromJson(json);
  
  final List<EventCard> items;

  /// Null — страниц больше нет.
  final String? nextCursor;

  Map<String, Object?> toJson() => _$EventCardPageToJson(this);
}
