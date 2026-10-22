import 'package:dio/dio.dart';
import 'package:mobile/core/auth/secure_storage_service.dart';

/// Подставляет access-токен в каждый запрос. Токен читается из хранилища
/// при каждом запросе, поэтому логин, логаут и обновление токена подхватываются
/// сразу, без отдельного кэша.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey('Authorization')) {
      final access = (await _storage.readSession())?['access'];
      if (access != null && access.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $access';
      }
    }
    handler.next(options);
  }
}
