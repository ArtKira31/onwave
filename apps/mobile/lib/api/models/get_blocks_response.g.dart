// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_blocks_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetBlocksResponse _$GetBlocksResponseFromJson(Map<String, dynamic> json) =>
    GetBlocksResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => BlockedUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetBlocksResponseToJson(GetBlocksResponse instance) =>
    <String, dynamic>{'items': instance.items};
