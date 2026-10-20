// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_queue_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModerationQueueItem _$ModerationQueueItemFromJson(Map<String, dynamic> json) =>
    ModerationQueueItem(
      kind: ModerationQueueItemKind.fromJson(json['kind'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      ageHours: json['ageHours'] as num,
      lockedBy: json['lockedBy'] as String?,
      event: json['event'] == null
          ? null
          : EventDetail.fromJson(json['event'] as Map<String, dynamic>),
      report: json['report'] == null
          ? null
          : ReportInput.fromJson(json['report'] as Map<String, dynamic>),
      reportCount: (json['reportCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ModerationQueueItemToJson(
  ModerationQueueItem instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'createdAt': instance.createdAt.toIso8601String(),
  'ageHours': instance.ageHours,
  'lockedBy': instance.lockedBy,
  'event': instance.event,
  'report': instance.report,
  'reportCount': instance.reportCount,
};
