import 'dart:math';

import 'package:dio/dio.dart';

/// Повторяет только идемпотентные запросы при сетевых сбоях и 5xx,
/// с экспоненциальной задержкой и ограниченным числом попыток.
/// 4xx (включая 401 и 429) не повторяем.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this._dio,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 500),
    Future<void> Function(Duration)? sleep,
    Random? random,
  }) : _sleep = sleep ?? Future<void>.delayed,
       _random = random ?? Random();

  final Dio _dio;

  /// Сколько повторов после первой попытки (всего попыток = maxRetries + 1).
  final int maxRetries;

  /// Задержка перед первым повтором, дальше удваивается: 0.5 с, 1 с, 2 с...
  final Duration baseDelay;
  final Future<void> Function(Duration) _sleep;
  final Random _random;

  static const _disabledKey = 'retry_disabled';
  static const _idempotentMethods = {'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS'};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    if (req.extra[_disabledKey] == true ||
        !_isIdempotent(req) ||
        !_isRetryable(err)) {
      handler.next(err);
      return;
    }

    var last = err;
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      await _sleep(_delay(attempt));
      if (req.cancelToken?.isCancelled ?? false) break;
      try {
        final response = await _dio.fetch<dynamic>(
          req.copyWith(extra: {...req.extra, _disabledKey: true}),
        );
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        last = e;
        if (!_isRetryable(e)) break;
      }
    }
    handler.next(last);
  }

  /// POST/PATCH безопасны для повтора только с Idempotency-Key.
  bool _isIdempotent(RequestOptions o) =>
      _idempotentMethods.contains(o.method.toUpperCase()) ||
      o.headers.containsKey('Idempotency-Key');

  bool _isRetryable(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        return (e.response?.statusCode ?? 0) >= 500;
      default:
        return false;
    }
  }

  Duration _delay(int attempt) {
    final ms = baseDelay.inMilliseconds * (1 << attempt);
    final jitter = 1 + _random.nextDouble() * 0.25;
    return Duration(milliseconds: (ms * jitter).round());
  }
}
