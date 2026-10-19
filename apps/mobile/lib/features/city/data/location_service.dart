import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class DeviceLocation {
  final double lat;
  final double lon;
  const DeviceLocation(this.lat, this.lon);
}

enum LocationProblem {
  /// Геолокация выключена в системе.
  servicesDisabled,

  /// Пользователь отказал в разрешении (можно спросить ещё раз).
  denied,

  /// Отказ «навсегда»: системный диалог больше не покажется.
  deniedForever,

  /// Не получилось определить (таймаут, нет сигнала, ошибка платформы).
  unavailable,
}

class LocationFailure implements Exception {
  final LocationProblem problem;
  const LocationFailure(this.problem);

  @override
  String toString() => 'LocationFailure($problem)';
}

abstract interface class LocationService {
  /// Разовое определение положения. Запрашивает разрешение, если его ещё нет.
  /// Бросает [LocationFailure].
  Future<DeviceLocation> currentLocation();

  /// Открыть системные настройки приложения (после отказа «навсегда»).
  Future<void> openSettings();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<DeviceLocation> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(LocationProblem.servicesDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure(LocationProblem.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationProblem.deniedForever);
    }

    try {
      // Нужен город, а не точный адрес: низкой точности достаточно
      // (на Android хватает приблизительной геолокации).
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return DeviceLocation(position.latitude, position.longitude);
    } catch (_) {
      throw const LocationFailure(LocationProblem.unavailable);
    }
  }

  @override
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }
}

/// Фиксированное положение для проверки без выхода на улицу:
/// `--dart-define=FAKE_LOCATION=tbilisi` (или `belgrade`).
class FakeLocationService implements LocationService {
  final DeviceLocation location;
  const FakeLocationService(this.location);

  @override
  Future<DeviceLocation> currentLocation() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return location;
  }

  @override
  Future<void> openSettings() async {}
}

const _fakeLocation = String.fromEnvironment('FAKE_LOCATION');

final locationServiceProvider = Provider<LocationService>((ref) {
  switch (_fakeLocation) {
    case 'tbilisi':
      return const FakeLocationService(DeviceLocation(41.72, 44.79));
    case 'belgrade':
      return const FakeLocationService(DeviceLocation(44.80, 20.46));
  }
  return GeolocatorLocationService();
});
