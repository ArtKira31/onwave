// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/geo_resolve_request_body.dart';
import '../models/get_geo_autocomplete_response.dart';
import '../models/resolved_address.dart';

part 'geo_client.g.dart';

@RestApi()
abstract class GeoClient {
  factory GeoClient(Dio dio, {String? baseUrl}) = _GeoClient;

  /// Подсказки адреса.
  ///
  /// Скоуп по выбранному городу. Ответы кэшируются — квоты провайдеров платные.
  @GET('/geo/autocomplete')
  Future<GetGeoAutocompleteResponse> autocompleteAddress({
    @Query('query') required String query,
    @Query('city') required String city,
  });

  /// Нормализовать адрес.
  ///
  /// Из `placeId` или строки получаем координаты, город и таймзону (ONW-36).
  /// Город события определяется по координатам, а не по выбору пользователя.
  /// в онбординге.
  @POST('/geo/resolve')
  Future<ResolvedAddress> resolveAddress({
    @Body() required GeoResolveRequestBody body,
  });
}
