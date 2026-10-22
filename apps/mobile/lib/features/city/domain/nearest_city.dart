import 'dart:math' as math;

import 'package:mobile/features/city/domain/city_models.dart';

/// Дальше этого расстояния город «ближайшим» не считаем: человек в другой
/// стране не должен получить Тбилиси только потому, что он ближе остальных.
const double kNearbyCityMaxKm = 150;

/// Расстояние между двумя точками по поверхности Земли, км (формула гаверсинуса).
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  double rad(double deg) => deg * math.pi / 180;

  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.min(1.0, math.sqrt(a)));
}

/// Ближайший к точке город из [cities] или `null`, если ближе [maxKm] ничего нет.
/// Города без координат пропускаются.
CityOption? nearestCity(
  List<CityOption> cities,
  double lat,
  double lon, {
  double maxKm = kNearbyCityMaxKm,
}) {
  CityOption? best;
  var bestKm = double.infinity;
  for (final city in cities) {
    if (!city.hasCoordinates) continue;
    final km = distanceKm(lat, lon, city.lat!, city.lon!);
    if (km < bestKm) {
      bestKm = km;
      best = city;
    }
  }
  return bestKm <= maxKm ? best : null;
}
