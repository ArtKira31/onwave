// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_public.g.dart';

@JsonSerializable()
class UserPublic {
  const UserPublic({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.isOrganizer,
  });
  
  factory UserPublic.fromJson(Map<String, Object?> json) => _$UserPublicFromJson(json);
  
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final bool? isOrganizer;

  Map<String, Object?> toJson() => _$UserPublicToJson(this);
}
