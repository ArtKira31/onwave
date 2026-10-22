import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_exception.dart';

/// Последний в цепочке: превращает ошибку Dio в [ApiException]
/// (кладёт её в DioException.error). Отмену запроса не трогает.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.cancel || err.error is ApiException) {
      handler.next(err);
      return;
    }
    handler.next(err.copyWith(error: ApiException.fromDio(err)));
  }
}
