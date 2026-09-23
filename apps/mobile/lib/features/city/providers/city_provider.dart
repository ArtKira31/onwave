import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityNotifier extends AutoDisposeNotifier<String?> {
  @override
  String? build() => null; // По умолчанию город не выбран

  void selectCity(String city) => state = city;
}

final cityProvider = AutoDisposeNotifierProvider<CityNotifier, String?>(
  CityNotifier.new,
);
