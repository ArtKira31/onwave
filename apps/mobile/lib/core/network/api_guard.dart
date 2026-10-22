import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_exception.dart';

/// Обёртка для вызовов сгенерированного клиента в репозиториях.
/// Dio умеет бросать только DioException, поэтому доменную ошибку
/// достаём из неё здесь, и дальше по приложению идёт [ApiException].
///
///   final page = await guardApi(() => client.listEvents(...));
///
/// Отмена запроса (CancelToken) пробрасывается как есть.
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    final inner = e.error;
    if (inner is ApiException) throw inner;
    rethrow;
  }
}
