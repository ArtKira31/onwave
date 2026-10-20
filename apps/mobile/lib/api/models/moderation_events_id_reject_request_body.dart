// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reason.dart';

part 'moderation_events_id_reject_request_body.g.dart';

@JsonSerializable()
class ModerationEventsIdRejectRequestBody {
  const ModerationEventsIdRejectRequestBody({
    required this.reason,
    this.comment,
  });
  
  factory ModerationEventsIdRejectRequestBody.fromJson(Map<String, Object?> json) => _$ModerationEventsIdRejectRequestBodyFromJson(json);
  
  final Reason reason;
  final String? comment;

  Map<String, Object?> toJson() => _$ModerationEventsIdRejectRequestBodyToJson(this);
}
