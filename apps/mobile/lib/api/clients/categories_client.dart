// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_categories_response.dart';

part 'categories_client.g.dart';

@RestApi()
abstract class CategoriesClient {
  factory CategoriesClient(Dio dio, {String? baseUrl}) = _CategoriesClient;

  /// Справочник категорий.
  ///
  /// Набор фиксированный. `nameKey` — ключ локализации, а не готовая строка:.
  /// переводы живут в мобилке.
  @GET('/categories')
  Future<GetCategoriesResponse> listCategories();
}
