// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_queue_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModerationQueuePage _$ModerationQueuePageFromJson(Map<String, dynamic> json) =>
    ModerationQueuePage(
      items: (json['items'] as List<dynamic>)
          .map((e) => ModerationQueueItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$ModerationQueuePageToJson(
  ModerationQueuePage instance,
) => <String, dynamic>{
  'items': instance.items,
  'nextCursor': instance.nextCursor,
};
