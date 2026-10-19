import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/api/clients/cities_client.dart';
import 'package:mobile/api/models/city.dart';
import 'package:mobile/core/network/api_guard.dart';
import 'package:mobile/core/network/api_providers.dart';
import 'package:mobile/features/city/domain/city_models.dart';

abstract interface class CitiesRepository {
  /// `GET /cities`: активные города, порядок задаёт сервер
  /// (по популярности, затем по алфавиту).
  Future<List<CityOption>> fetchCities();
}

/// Реальная реализация поверх сгенерированного клиента.
class ApiCitiesRepository implements CitiesRepository {
  final CitiesClient _client;
  ApiCitiesRepository(this._client);

  @override
  Future<List<CityOption>> fetchCities() async {
    final response = await guardApi(() => _client.listCities());
    return response.items.map(_toOption).toList();
  }

  static CityOption _toOption(City c) => CityOption(
    id: c.id,
    slug: c.slug,
    name: c.name,
    lat: c.lat?.toDouble(),
    lon: c.lon?.toDouble(),
  );
}

/// Заглушка для `--dart-define=USE_FAKE_API=true`: онбординг работает без
/// бэкенда. `FAKE_MODE=error` заставляет запрос падать.
class FakeCitiesRepository implements CitiesRepository {
  bool failing = false;

  static const _cities = [
    CityOption(id: 'c1', slug: 'tbilisi', name: 'Тбилиси', lat: 41.7151, lon: 44.8271),
    CityOption(id: 'c2', slug: 'belgrade', name: 'Белград', lat: 44.7866, lon: 20.4489),
    CityOption(id: 'c3', slug: 'batumi', name: 'Батуми', lat: 41.6168, lon: 41.6367),
    CityOption(id: 'c4', slug: 'novi-sad', name: 'Нови-Сад', lat: 45.2671, lon: 19.8335),
  ];

  @override
  Future<List<CityOption>> fetchCities() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (failing) throw Exception('network');
    return _cities;
  }
}

const _useFakeApi = bool.fromEnvironment('USE_FAKE_API');
const _fakeMode = String.fromEnvironment('FAKE_MODE');

final citiesRepositoryProvider = Provider<CitiesRepository>(
  (ref) => _useFakeApi
      ? (FakeCitiesRepository()..failing = _fakeMode == 'error')
      : ApiCitiesRepository(CitiesClient(ref.watch(dioProvider))),
);
