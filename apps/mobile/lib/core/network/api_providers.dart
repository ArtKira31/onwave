import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/api/rest_client.dart';

/// Адрес бэкенда. Переопределяется при запуске:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
/// По умолчанию — локальный бэкенд (pnpm api:dev). Эмулятор Android видит
/// хост-машину как 10.0.2.2, а не localhost.
/// TODO(ONW-47): когда появятся окружения (dev/stage/prod) — брать адрес оттуда.
class ApiConfig {
  static const _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}

/// Единственный Dio приложения. Интерцепторы авторизации (ONW-47) добавлять сюда.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final restClientProvider = Provider<RestClient>(
  (ref) => RestClient(ref.watch(dioProvider)),
);
