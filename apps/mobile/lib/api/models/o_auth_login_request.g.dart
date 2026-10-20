// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'o_auth_login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthLoginRequest _$OAuthLoginRequestFromJson(Map<String, dynamic> json) =>
    OAuthLoginRequest(
      idToken: json['idToken'] as String,
      deviceId: json['deviceId'] as String,
    );

Map<String, dynamic> _$OAuthLoginRequestToJson(OAuthLoginRequest instance) =>
    <String, dynamic>{
      'idToken': instance.idToken,
      'deviceId': instance.deviceId,
    };
