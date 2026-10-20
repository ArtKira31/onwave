// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'clients/health_client.dart';
import 'clients/auth_client.dart';
import 'clients/cities_client.dart';
import 'clients/categories_client.dart';
import 'clients/events_client.dart';
import 'clients/favorites_client.dart';
import 'clients/me_client.dart';
import 'clients/media_client.dart';
import 'clients/geo_client.dart';
import 'clients/safety_client.dart';
import 'clients/moderation_client.dart';

/// Onwave API `v0.1.0`.
///
/// Источник правды для бэкенда и мобильного клиента (ONW-8).
/// Бэкенд реализует эту схему, Flutter генерирует из неё клиент (ONW-42).
///
/// Договорённости, на которых держится всё остальное:.
///
/// * **Один формат ошибки** — `Error` с машиночитаемым `code`. Мобилка ветвит.
///   логику по `code`, а не по тексту `message`.
/// * **Пагинация курсорная, не offset.** Лента постоянно меняется, offset даёт.
///   дубли и пропуски. Курсор непрозрачный, клиент его не разбирает.
/// * **Время в UTC.** «Сегодня» и «на выходных» считаются по таймзоне города,.
///   которая приходит в `City.timezone`, а не по времени телефона.
/// * **Гость — полноценный клиент.** Всё чтение доступно по гостевому токену;.
///   логин нужен только для избранного, создания событий и жалоб.
/// * **Оплаты внутри нет.** `ticketUrl` — внешняя ссылка, приложение её открывает.
///
class RestClient {
  RestClient(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.1.0';

  HealthClient? _health;
  AuthClient? _auth;
  CitiesClient? _cities;
  CategoriesClient? _categories;
  EventsClient? _events;
  FavoritesClient? _favorites;
  MeClient? _me;
  MediaClient? _media;
  GeoClient? _geo;
  SafetyClient? _safety;
  ModerationClient? _moderation;

  HealthClient get health => _health ??= HealthClient(_dio, baseUrl: _baseUrl);

  AuthClient get auth => _auth ??= AuthClient(_dio, baseUrl: _baseUrl);

  CitiesClient get cities => _cities ??= CitiesClient(_dio, baseUrl: _baseUrl);

  CategoriesClient get categories => _categories ??= CategoriesClient(_dio, baseUrl: _baseUrl);

  EventsClient get events => _events ??= EventsClient(_dio, baseUrl: _baseUrl);

  FavoritesClient get favorites => _favorites ??= FavoritesClient(_dio, baseUrl: _baseUrl);

  MeClient get me => _me ??= MeClient(_dio, baseUrl: _baseUrl);

  MediaClient get media => _media ??= MediaClient(_dio, baseUrl: _baseUrl);

  GeoClient get geo => _geo ??= GeoClient(_dio, baseUrl: _baseUrl);

  SafetyClient get safety => _safety ??= SafetyClient(_dio, baseUrl: _baseUrl);

  ModerationClient get moderation => _moderation ??= ModerationClient(_dio, baseUrl: _baseUrl);
}
