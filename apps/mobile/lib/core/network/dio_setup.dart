import 'package:dio/dio.dart';
import 'package:mobile/core/auth/secure_storage_service.dart';
import 'package:mobile/core/network/auth_interceptor.dart';
import 'package:mobile/core/network/error_interceptor.dart';
import 'package:mobile/core/network/logging_interceptor.dart';
import 'package:mobile/core/network/refresh_interceptor.dart';
import 'package:mobile/core/network/retry_interceptor.dart';

/// Подключает интерсепторы в нужном порядке:
/// токен -> обновление на 401 -> повтор при сбоях -> доменные ошибки -> лог.
/// Порядок важен: ошибка идёт по цепочке слева направо.
void configureDio(
  Dio dio, {
  required SecureStorageService storage,
  required SessionRefresher refresher,
  bool logging = false,
  Future<void> Function(Duration)? retrySleep,
}) {
  dio.interceptors.addAll([
    AuthInterceptor(storage),
    RefreshInterceptor(dio: dio, storage: storage, refresher: refresher),
    RetryInterceptor(dio: dio, sleep: retrySleep),
    ErrorInterceptor(),
    if (logging) LoggingInterceptor(),
  ]);
}
