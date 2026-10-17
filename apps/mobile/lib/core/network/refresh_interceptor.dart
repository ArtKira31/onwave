import 'package:dio/dio.dart';
import 'package:mobile/core/auth/secure_storage_service.dart';
import 'package:mobile/core/network/logging_interceptor.dart';

/// Обмен refresh-токена на новую пару. Реализуется поверх AuthClient
/// (см. api_providers.dart), здесь только тип, чтобы слой не зависел
/// от сгенерированного клиента и легко тестировался.
typedef RefreshCall =
    Future<({String accessToken, String refreshToken})> Function(
      String refreshToken,
    );

/// Обновляет токены. Refresh одноразовый: если два запроса одновременно
/// отправят один и тот же refresh, сервер посчитает второй кражей и отзовёт
/// всю цепочку. Поэтому все, кому нужен новый токен, ждут ОДИН общий запрос.
class SessionRefresher {
  SessionRefresher({
    required this._storage,
    required this._refreshCall,
    required this._onSessionExpired,
    this._onRefreshed,
  });

  final SecureStorageService _storage;
  final RefreshCall _refreshCall;
  final Future<void> Function() _onSessionExpired;
  final void Function(String accessToken)? _onRefreshed;

  Future<String?>? _inFlight;

  /// Возвращает свежий access-токен или null, если сессии больше нет
  /// (refresh-токена нет или сервер его отклонил: тогда вызван onSessionExpired).
  /// Бросает DioException, если обновить не вышло по временной причине
  /// (нет сети, 5xx): сессию в этом случае не трогаем.
  Future<String?> refresh() {
    return _inFlight ??= _run().whenComplete(() => _inFlight = null);
  }

  Future<String?> _run() async {
    final session = await _storage.readSession();
    final refreshToken = session?['refresh'];
    if (refreshToken == null || refreshToken.isEmpty) return null;

    netLog('refresh: обновляю токен');
    try {
      final tokens = await _refreshCall(refreshToken);
      await _storage.saveSession(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        deviceId: session?['deviceId'] ?? '',
      );
      _onRefreshed?.call(tokens.accessToken);
      netLog('refresh: ok');
      return tokens.accessToken;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        netLog('refresh: сессия отозвана, выход');
        await _onSessionExpired();
        return null;
      }
      rethrow;
    }
  }
}

/// На 401 обновляет токен (один раз на всех) и повторяет запрос.
/// Пользователь ничего не замечает.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required this._dio,
    required this._storage,
    required this._refresher,
  });

  final Dio _dio;
  final SecureStorageService _storage;
  final SessionRefresher _refresher;

  static const _retriedKey = 'auth_retried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final sent = req.headers['Authorization'];

    // Не наш случай: не 401, запрос шёл без токена, уже повторяли,
    // либо это сам /auth/* (ошибка логина не лечится обновлением токена).
    final skip =
        err.response?.statusCode != 401 ||
        sent == null ||
        req.extra[_retriedKey] == true ||
        req.path.startsWith('/auth/');
    if (skip) {
      handler.next(err);
      return;
    }

    String? token;
    try {
      final current = (await _storage.readSession())?['access'];
      if (current != null && current.isNotEmpty && 'Bearer $current' != sent) {
        // Пока запрос летел, токен уже обновил кто-то другой: просто берём его.
        token = current;
      } else {
        token = await _refresher.refresh();
      }
    } on DioException catch (refreshError) {
      // Обновить не вышло по временной причине. Отдаём ошибку на запрос
      // оригинала, но с типом причины (сеть/5xx), чтобы сработал retry.
      handler.next(
        DioException(
          requestOptions: req,
          type: refreshError.type,
          response: refreshError.response,
          error: refreshError.error,
          message: refreshError.message,
        ),
      );
      return;
    }

    if (token == null) {
      handler.next(err); // сессии нет: уйдёт как UnauthorizedException
      return;
    }

    req.extra[_retriedKey] = true;
    req.headers['Authorization'] = 'Bearer $token';
    try {
      handler.resolve(await _dio.fetch<dynamic>(req));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
