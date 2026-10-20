// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'blocked_user.dart';

part 'get_blocks_response.g.dart';

@JsonSerializable()
class GetBlocksResponse {
  const GetBlocksResponse({
    required this.items,
  });
  
  factory GetBlocksResponse.fromJson(Map<String, Object?> json) => _$GetBlocksResponseFromJson(json);
  
  final List<BlockedUser> items;

  Map<String, Object?> toJson() => _$GetBlocksResponseToJson(this);
}
