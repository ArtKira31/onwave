// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_apple_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthAppleRequestBody _$AuthAppleRequestBodyFromJson(
  Map<String, dynamic> json,
) => AuthAppleRequestBody(
  idToken: json['idToken'] as String,
  deviceId: json['deviceId'] as String,
  fullName: json['fullName'] as String?,
);

Map<String, dynamic> _$AuthAppleRequestBodyToJson(
  AuthAppleRequestBody instance,
) => <String, dynamic>{
  'idToken': instance.idToken,
  'deviceId': instance.deviceId,
  'fullName': instance.fullName,
};
