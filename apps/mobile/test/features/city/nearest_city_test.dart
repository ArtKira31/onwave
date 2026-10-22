import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/city/domain/city_models.dart';
import 'package:mobile/features/city/domain/nearest_city.dart';

const _tbilisi = CityOption(
  id: '1',
  slug: 'tbilisi',
  name: 'Тбилиси',
  lat: 41.7151,
  lon: 44.8271,
);
const _belgrade = CityOption(
  id: '2',
  slug: 'belgrade',
  name: 'Белград',
  lat: 44.7866,
  lon: 20.4489,
);
const _noCoords = CityOption(id: '3', slug: 'ghost', name: 'Без координат');

void main() {
  group('distanceKm', () {
    test('одна и та же точка даёт 0', () {
      expect(distanceKm(41.7, 44.8, 41.7, 44.8), closeTo(0, 0.001));
    });

    test('Тбилиси — Белград около 2000 км', () {
      expect(distanceKm(41.7151, 44.8271, 44.7866, 20.4489), closeTo(1996, 20));
    });
  });

  group('nearestCity', () {
    final cities = [_tbilisi, _belgrade, _noCoords];

    test('находит ближайший город', () {
      expect(nearestCity(cities, 41.72, 44.79)?.slug, 'tbilisi');
      expect(nearestCity(cities, 44.80, 20.46)?.slug, 'belgrade');
    });

    test('слишком далеко (Бишкек) — города нет', () {
      expect(nearestCity(cities, 42.87, 74.59), isNull);
    });

    test('города без координат пропускаются', () {
      expect(nearestCity([_noCoords], 41.7, 44.8), isNull);
    });

    test('пустой список — null', () {
      expect(nearestCity(const [], 41.7, 44.8), isNull);
    });

    test('порог можно поменять', () {
      expect(nearestCity(cities, 42.87, 74.59, maxKm: 3000)?.slug, 'tbilisi');
    });
  });
}
