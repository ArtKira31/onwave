import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:mobile/core/network/api_exception.dart';

/// Логируем сеть только в dev-флейворе (и в debug-запуске без флейвора,
/// например в Chrome). В stage и prod логов нет.
bool get kLogHttp =>
    appFlavor == 'dev' || (appFlavor == null && kDebugMode);

void netLog(String message) {
  if (kLogHttp) debugPrint('[http] $message');
}

/// Пишет в консоль метод, путь, статус и время. Заголовки и тела не пишем
/// вообще: в них токены.
class LoggingInterceptor extends Interceptor {
  static const _startKey = 'log_started_at_ms';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    netLog('-> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    netLog('<- ${response.statusCode} ${o.method} ${o.path} (${_ms(o)})');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    final inner = err.error;
    final what = inner is ApiException
        ? inner.toString()
        : '${err.response?.statusCode ?? err.type.name}';
    netLog('x  ${o.method} ${o.path} $what (${_ms(o)})');
    handler.next(err);
  }

  String _ms(RequestOptions o) {
    final started = o.extra[_startKey];
    if (started is! int) return '?';
    return '${DateTime.now().millisecondsSinceEpoch - started} ms';
  }
}
