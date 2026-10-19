// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'moderation_queue_item.dart';

part 'moderation_queue_page.g.dart';

@JsonSerializable()
class ModerationQueuePage {
  const ModerationQueuePage({
    required this.items,
    this.nextCursor,
  });
  
  factory ModerationQueuePage.fromJson(Map<String, Object?> json) => _$ModerationQueuePageFromJson(json);
  
  final List<ModerationQueueItem> items;
  final String? nextCursor;

  Map<String, Object?> toJson() => _$ModerationQueuePageToJson(this);
}
