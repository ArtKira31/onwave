// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_events_id_reject_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModerationEventsIdRejectRequestBody
_$ModerationEventsIdRejectRequestBodyFromJson(Map<String, dynamic> json) =>
    ModerationEventsIdRejectRequestBody(
      reason: Reason.fromJson(json['reason'] as String),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$ModerationEventsIdRejectRequestBodyToJson(
  ModerationEventsIdRejectRequestBody instance,
) => <String, dynamic>{'reason': instance.reason, 'comment': instance.comment};
