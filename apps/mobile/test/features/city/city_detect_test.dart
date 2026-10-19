import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/city/data/location_service.dart';
import 'package:mobile/features/city/domain/city_models.dart';
import 'package:mobile/features/city/providers/city_detect_provider.dart';

const _cities = [
  CityOption(id: '1', slug: 'tbilisi', name: 'Тбилиси', lat: 41.7151, lon: 44.8271),
  CityOption(id: '2', slug: 'belgrade', name: 'Белград', lat: 44.7866, lon: 20.4489),
];

class _FakeLocation implements LocationService {
  final DeviceLocation? location;
  final Object? error;
  int calls = 0;

  _FakeLocation.at(double lat, double lon)
    : location = DeviceLocation(lat, lon),
      error = null;
  _FakeLocation.fails(LocationProblem problem)
    : location = null,
      error = LocationFailure(problem);
  _FakeLocation.crashes()
    : location = null,
      error = StateError('boom');

  @override
  Future<DeviceLocation> currentLocation() async {
    calls++;
    if (error != null) throw error!;
    return location!;
  }

  @override
  Future<void> openSettings() async {}
}

ProviderContainer _container(LocationService service) {
  final container = ProviderContainer(
    overrides: [locationServiceProvider.overrideWithValue(service)],
  );
  addTearDown(container.dispose);
  // autoDispose-провайдер должен жить, пока идёт запрос.
  container.listen(cityDetectProvider, (_, _) {});
  return container;
}

void main() {
  test('до тапа геолокация не запрашивается', () {
    final service = _FakeLocation.at(41.72, 44.79);
    final c = _container(service);
    expect(c.read(cityDetectProvider), DetectStatus.idle);
    expect(service.calls, 0);
  });

  test('нашли ближайший город', () async {
    final c = _container(_FakeLocation.at(41.72, 44.79));
    final city = await c.read(cityDetectProvider.notifier).detect(_cities);
    expect(city?.slug, 'tbilisi');
    expect(c.read(cityDetectProvider), DetectStatus.idle);
  });

  test('рядом нет городов — noNearby', () async {
    final c = _container(_FakeLocation.at(42.87, 74.59)); // Бишкек
    final city = await c.read(cityDetectProvider.notifier).detect(_cities);
    expect(city, isNull);
    expect(c.read(cityDetectProvider), DetectStatus.noNearby);
  });

  for (final entry in {
    LocationProblem.servicesDisabled: DetectStatus.servicesDisabled,
    LocationProblem.denied: DetectStatus.denied,
    LocationProblem.deniedForever: DetectStatus.deniedForever,
    LocationProblem.unavailable: DetectStatus.unavailable,
  }.entries) {
    test('отказ ${entry.key.name} — город не выбирается, статус ${entry.value.name}', () async {
      final c = _container(_FakeLocation.fails(entry.key));
      final city = await c.read(cityDetectProvider.notifier).detect(_cities);
      expect(city, isNull);
      expect(c.read(cityDetectProvider), entry.value);
    });
  }

  test('неожиданная ошибка не оставляет кнопку в «Определяем…»', () async {
    final c = _container(_FakeLocation.crashes());
    final city = await c.read(cityDetectProvider.notifier).detect(_cities);
    expect(city, isNull);
    expect(c.read(cityDetectProvider), DetectStatus.unavailable);
  });

  test('повторная попытка после отказа работает', () async {
    final service = _FakeLocation.fails(LocationProblem.denied);
    final c = _container(service);
    final notifier = c.read(cityDetectProvider.notifier);

    await notifier.detect(_cities);
    await notifier.detect(_cities);

    expect(service.calls, 2);
  });
}
