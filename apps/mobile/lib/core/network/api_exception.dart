import 'package:dio/dio.dart';
import 'package:mobile/api/models/error.dart' as api;
import 'package:mobile/api/models/error_code.dart';

/// Доменная ошибка сетевого слоя. Экраны и репозитории работают с ней,
/// а не с DioException. Ветвление идёт по типу (а он выбирается по `code`
/// из ответа API), текст `message` пользователю напрямую не показываем.
sealed class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code,
    this.requestId,
    this.statusCode,
    this.details,
  });

  final String message;

  /// Машиночитаемый код из ответа API. null, если ответа не было
  /// или он не в формате `Error`.
  final ErrorCode? code;

  /// Совпадает с request-id в логах бэкенда.
  final String? requestId;
  final int? statusCode;

  /// Пофайловые ошибки валидации либо контекст ошибки (как пришло с сервера).
  final Object? details;

  /// Разбирает DioException в доменную ошибку. Повторный вызов на уже
  /// разобранной ошибке возвращает ту же ApiException.
  factory ApiException.fromDio(DioException e) {
    final existing = e.error;
    if (existing is ApiException) return existing;

    final response = e.response;
    if (response == null) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return NetworkException(
            message: e.message ?? 'Нет соединения с сервером',
          );
        default:
          return UnknownApiException(
            message: e.message ?? e.error?.toString() ?? 'Неизвестная ошибка',
          );
      }
    }

    final status = response.statusCode;
    api.Error? body;
    try {
      final data = response.data;
      if (data is Map) {
        body = api.Error.fromJson(Map<String, Object?>.from(data));
      }
    } catch (_) {
      body = null; // тело не в формате Error (например, HTML от прокси)
    }

    final code = body?.code;
    final kind = switch (code) {
      ErrorCode.validationFailed => _Kind.validation,
      ErrorCode.unauthorized || ErrorCode.invalidOauthToken =>
        _Kind.unauthorized,
      ErrorCode.forbidden => _Kind.forbidden,
      ErrorCode.notFound || ErrorCode.eventNotFound => _Kind.notFound,
      ErrorCode.invalidStateTransition => _Kind.invalidState,
      ErrorCode.rateLimited => _Kind.rateLimited,
      ErrorCode.internal => _Kind.server,
      ErrorCode.$unknown || null => _byStatus(status),
    };

    final retryAfterSeconds = int.tryParse(
      response.headers.value('retry-after') ?? '',
    );

    return _make(
      kind,
      message: body?.message ?? e.message ?? 'HTTP $status',
      code: code,
      requestId: body?.requestId,
      statusCode: status,
      details: body?.details,
      retryAfter: retryAfterSeconds == null
          ? null
          : Duration(seconds: retryAfterSeconds),
    );
  }

  /// Запасной вариант, когда `code` неизвестен или тела нет.
  static _Kind _byStatus(int? status) => switch (status) {
    400 => _Kind.validation,
    401 => _Kind.unauthorized,
    403 => _Kind.forbidden,
    404 => _Kind.notFound,
    429 => _Kind.rateLimited,
    final int n when n >= 500 => _Kind.server,
    _ => _Kind.unknown,
  };

  static ApiException _make(
    _Kind kind, {
    required String message,
    ErrorCode? code,
    String? requestId,
    int? statusCode,
    Object? details,
    Duration? retryAfter,
  }) {
    switch (kind) {
      case _Kind.validation:
        return ValidationException(
          message: message,
          code: code,
          requestId: requestId,
          statusCode: statusCode,
          details: details,
        );
      case _Kind.unauthorized:
        return UnauthorizedException(
          message: message,
          code: code,
          requestId: requestId,
          statusCode: statusCode,
          details: details,
        );
      case _Kind.forbidden:
        return ForbiddenException(
          message: message,
          code: code,
          requestId: requestId,
          statusCode: statusCode,
          details: details,
        );
      case _Kind.notFound:
        return NotFoundException(
          message: message,
          code: code,
          requestId: requestId,
          statusCode: statusCode,
          details: details,
        );
      case _Kind.invalidState:
        return InvalidStateTransitionException(
          message: message,
          code: code,
          requestId: requestId,
          statusCode: statusCode,
          details: details,
        );
      case _Kind.rateLimited:
        return RateLimitedException(
          message: message,
          code: code,
          requestId: requestId,
          statusCode: statusCode,
          details: details,
          retryAfter: retryAfter,
        );
      case _Kind.server:
        return ServerException(
          message: message,
          code: code,
          requestId: requestId,
          statusCode: statusCode,
          details: details,
        );
      case _Kind.unknown:
        return UnknownApiException(
          message: message,
          code: code,
          requestId: requestId,
          statusCode: statusCode,
          details: details,
        );
    }
  }

  @override
  String toString() =>
      '$runtimeType(status: ${statusCode ?? '-'}, code: ${code ?? '-'}, '
      'message: $message, requestId: ${requestId ?? '-'})';
}

enum _Kind {
  validation,
  unauthorized,
  forbidden,
  notFound,
  invalidState,
  rateLimited,
  server,
  unknown,
}

/// Нет сети, таймаут, обрыв соединения: ответа от сервера не было.
final class NetworkException extends ApiException {
  const NetworkException({required super.message});
}

/// 401: токена нет, он невалиден, либо сессия отозвана.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    required super.message,
    super.code,
    super.requestId,
    super.statusCode,
    super.details,
  });
}

final class ForbiddenException extends ApiException {
  const ForbiddenException({
    required super.message,
    super.code,
    super.requestId,
    super.statusCode,
    super.details,
  });
}

final class NotFoundException extends ApiException {
  const NotFoundException({
    required super.message,
    super.code,
    super.requestId,
    super.statusCode,
    super.details,
  });
}

/// Ошибка валидации. Поля с ошибками лежат в [details].
final class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    super.code,
    super.requestId,
    super.statusCode,
    super.details,
  });
}

final class InvalidStateTransitionException extends ApiException {
  const InvalidStateTransitionException({
    required super.message,
    super.code,
    super.requestId,
    super.statusCode,
    super.details,
  });
}

/// 429. [retryAfter] берётся из заголовка Retry-After, если он пришёл.
final class RateLimitedException extends ApiException {
  const RateLimitedException({
    required super.message,
    super.code,
    super.requestId,
    super.statusCode,
    super.details,
    this.retryAfter,
  });

  final Duration? retryAfter;
}

/// 5xx и код INTERNAL.
final class ServerException extends ApiException {
  const ServerException({
    required super.message,
    super.code,
    super.requestId,
    super.statusCode,
    super.details,
  });
}

/// Всё, что не удалось отнести к остальным видам.
final class UnknownApiException extends ApiException {
  const UnknownApiException({
    required super.message,
    super.code,
    super.requestId,
    super.statusCode,
    super.details,
  });
}
