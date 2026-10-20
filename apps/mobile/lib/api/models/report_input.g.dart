// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportInput _$ReportInputFromJson(Map<String, dynamic> json) => ReportInput(
  targetType: ReportInputTargetType.fromJson(json['targetType'] as String),
  targetId: json['targetId'] as String,
  reason: ReportInputReason.fromJson(json['reason'] as String),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$ReportInputToJson(ReportInput instance) =>
    <String, dynamic>{
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'reason': instance.reason,
      'comment': instance.comment,
    };
