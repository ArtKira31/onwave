// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_input_reason.dart';
import 'report_input_target_type.dart';

part 'report_input.g.dart';

@JsonSerializable()
class ReportInput {
  const ReportInput({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.comment,
  });
  
  factory ReportInput.fromJson(Map<String, Object?> json) => _$ReportInputFromJson(json);
  
  final ReportInputTargetType targetType;
  final String targetId;
  final ReportInputReason reason;
  final String? comment;

  Map<String, Object?> toJson() => _$ReportInputToJson(this);
}
