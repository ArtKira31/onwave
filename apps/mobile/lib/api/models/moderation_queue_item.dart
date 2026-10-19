// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'event_detail.dart';
import 'moderation_queue_item_kind.dart';
import 'report_input.dart';

part 'moderation_queue_item.g.dart';

@JsonSerializable()
class ModerationQueueItem {
  const ModerationQueueItem({
    required this.kind,
    required this.createdAt,
    required this.ageHours,
    this.lockedBy,
    this.event,
    this.report,
    this.reportCount,
  });
  
  factory ModerationQueueItem.fromJson(Map<String, Object?> json) => _$ModerationQueueItemFromJson(json);
  
  final ModerationQueueItemKind kind;
  final DateTime createdAt;

  /// Возраст записи. SLA реакции по правилам Apple — 24 часа.
  final num ageHours;

  /// Модератор, который сейчас принимает решение по этой записи.
  /// Клиент по нему гасит кнопки, чтобы двое не разбирали одно и то же.
  ///
  final String? lockedBy;
  final EventDetail? event;
  final ReportInput? report;

  /// Сколько независимых жалоб на этот объект.
  final int? reportCount;

  Map<String, Object?> toJson() => _$ModerationQueueItemToJson(this);
}
