import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/city/data/cities_repository.dart';
import 'package:mobile/features/city/domain/city_models.dart';

/// Список городов для выбора. Повтор после ошибки: `ref.invalidate(citiesProvider)`.
final citiesProvider = FutureProvider.autoDispose<List<CityOption>>(
  (ref) => ref.watch(citiesRepositoryProvider).fetchCities(),
);
