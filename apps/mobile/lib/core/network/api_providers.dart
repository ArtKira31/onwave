import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/api/clients/auth_client.dart';
import 'package:mobile/api/models/auth_refresh_request_body.dart';
import 'package:mobile/api/rest_client.dart';
import 'package:mobile/core/network/dio_setup.dart';
import 'package:mobile/core/network/logging_interceptor.dart';
import 'package:mobile/core/network/refresh_interceptor.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

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

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: ApiConfig.baseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
);

/// Единственный Dio приложения. Токен, обновление на 401, повторы и разбор
/// ошибок настроены в [configureDio]; экраны про это ничего не знают.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);

  // Отдельный Dio только для обмена refresh-токена: без интерсепторов,
  // иначе 401 на самом refresh зациклил бы обновление.
  final refreshDio = Dio(_baseOptions());
  if (kLogHttp) refreshDio.interceptors.add(LoggingInterceptor());
  final authClient = AuthClient(refreshDio);

  final refresher = SessionRefresher(
    storage: storage,
    refreshCall: (token) async {
      final tokens = await authClient.refreshTokens(
        body: AuthRefreshRequestBody(refreshToken: token),
      );
      return (
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    },
    onRefreshed: (access) =>
        ref.read(authProvider.notifier).sessionRefreshed(access),
    onSessionExpired: () => ref.read(authProvider.notifier).logout(),
  );

  final dio = Dio(_baseOptions());
  configureDio(dio, storage: storage, refresher: refresher, logging: kLogHttp);

  ref.onDispose(() {
    dio.close();
    refreshDio.close();
  });
  return dio;
});

final restClientProvider = Provider<RestClient>(
  (ref) => RestClient(ref.watch(dioProvider)),
);
