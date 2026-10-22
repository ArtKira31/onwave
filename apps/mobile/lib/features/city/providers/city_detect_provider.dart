import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/city/data/location_service.dart';
import 'package:mobile/features/city/domain/city_models.dart';
import 'package:mobile/features/city/domain/nearest_city.dart';

enum DetectStatus {
  idle,
  loading,

  /// Положение определено, но ближайший город дальше [kNearbyCityMaxKm].
  noNearby,
  servicesDisabled,
  denied,
  deniedForever,
  unavailable,
}

/// Автоопределение города. Геолокация запрашивается только из [detect],
/// то есть по явному тапу, а не при старте.
class CityDetectNotifier extends AutoDisposeNotifier<DetectStatus> {
  bool _alive = true;

  @override
  DetectStatus build() {
    ref.onDispose(() => _alive = false);
    return DetectStatus.idle;
  }

  /// Возвращает найденный город или `null` (причина в [state]).
  Future<CityOption?> detect(List<CityOption> cities) async {
    if (state == DetectStatus.loading) return null;
    final service = ref.read(locationServiceProvider);
    state = DetectStatus.loading;
    try {
      final location = await service.currentLocation();
      if (!_alive) return null;
      final city = nearestCity(cities, location.lat, location.lon);
      state = city == null ? DetectStatus.noNearby : DetectStatus.idle;
      return city;
    } on LocationFailure catch (e) {
      if (_alive) state = _statusFor(e.problem);
      return null;
    } catch (_) {
      if (_alive) state = DetectStatus.unavailable;
      return null;
    }
  }

  static DetectStatus _statusFor(LocationProblem problem) => switch (problem) {
    LocationProblem.servicesDisabled => DetectStatus.servicesDisabled,
    LocationProblem.denied => DetectStatus.denied,
    LocationProblem.deniedForever => DetectStatus.deniedForever,
    LocationProblem.unavailable => DetectStatus.unavailable,
  };
}

final cityDetectProvider =
    AutoDisposeNotifierProvider<CityDetectNotifier, DetectStatus>(
      CityDetectNotifier.new,
    );
