import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/auth/secure_storage_service.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/network/dio_setup.dart';
import 'package:mobile/core/network/refresh_interceptor.dart';

class _FakeStorage extends SecureStorageService {
  _FakeStorage(this.data);

  Map<String, String?> data;

  @override
  Future<Map<String, String?>?> readSession() async => {
    'access': data['access'],
    'refresh': data['refresh'],
    'deviceId': data['deviceId'],
  };

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String deviceId,
  }) async {
    data = {
      'access': accessToken,
      'refresh': refreshToken,
      'deviceId': deviceId,
    };
  }

  @override
  Future<void> clearAll() async => data = {};
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    calls++;
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, Object?> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody _error(int status, String code, {String? requestId}) => _json(
  status,
  {'code': code, 'message': 'msg', 'requestId': ?requestId},
);

void main() {
  late _FakeStorage storage;

  setUp(() {
    storage = _FakeStorage({
      'access': 'old',
      'refresh': 'r1',
      'deviceId': 'dev',
    });
  });

  Dio build(
    _FakeAdapter adapter, {
    RefreshCall? refreshCall,
    void Function()? onExpired,
  }) {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter;
    final refresher = SessionRefresher(
      storage: storage,
      refreshCall:
          refreshCall ?? (_) async => (accessToken: 'new', refreshToken: 'r2'),
      onSessionExpired: () async => onExpired?.call(),
    );
    configureDio(dio, storage: storage, refresher: refresher, retrySleep: (_) async {});
    return dio;
  }

  group('refresh', () {
    test('параллельные 401 вызывают ровно один refresh', () async {
      var refreshCalls = 0;
      final adapter = _FakeAdapter(
        (o) async => o.headers['Authorization'] == 'Bearer new'
            ? _json(200, {'ok': true})
            : _error(401, 'UNAUTHORIZED'),
      );
      final dio = build(
        adapter,
        refreshCall: (_) async {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return (accessToken: 'new', refreshToken: 'r2');
        },
      );

      final responses = await Future.wait(
        List.generate(5, (_) => dio.get<dynamic>('/events')),
      );

      expect(responses.every((r) => r.statusCode == 200), isTrue);
      expect(refreshCalls, 1);
      expect(storage.data['access'], 'new');
      expect(storage.data['refresh'], 'r2');
      expect(storage.data['deviceId'], 'dev');
    });

    test('отозванная сессия: выход и UnauthorizedException', () async {
      var expired = false;
      final adapter = _FakeAdapter((_) async => _error(401, 'UNAUTHORIZED'));
      final dio = build(
        adapter,
        onExpired: () => expired = true,
        refreshCall: (_) async => throw DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            statusCode: 401,
          ),
        ),
      );

      await expectLater(
        dio.get<dynamic>('/events'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<UnauthorizedException>(),
          ),
        ),
      );
      expect(expired, isTrue);
    });

    test('сеть упала во время refresh: сессию не трогаем', () async {
      var expired = false;
      final adapter = _FakeAdapter((_) async => _error(401, 'UNAUTHORIZED'));
      final dio = build(
        adapter,
        onExpired: () => expired = true,
        refreshCall: (_) async => throw DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.connectionError,
        ),
      );

      await expectLater(
        dio.get<dynamic>('/events'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<NetworkException>(),
          ),
        ),
      );
      expect(expired, isFalse);
      expect(storage.data['refresh'], 'r1');
    });
  });

  group('retry', () {
    test('GET повторяется при 503 и в итоге проходит', () async {
      var n = 0;
      final adapter = _FakeAdapter((_) async {
        n++;
        return n < 3 ? _error(503, 'INTERNAL') : _json(200, {'ok': true});
      });
      final dio = build(adapter);

      final response = await dio.get<dynamic>('/events');

      expect(response.statusCode, 200);
      expect(adapter.calls, 3);
    });

    test('число попыток ограничено', () async {
      final adapter = _FakeAdapter((_) async => _error(503, 'INTERNAL'));
      final dio = build(adapter);

      await expectLater(
        dio.get<dynamic>('/events'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ServerException>(),
          ),
        ),
      );
      expect(adapter.calls, 3); // первая попытка + 2 повтора
    });

    test('POST без Idempotency-Key не повторяется', () async {
      final adapter = _FakeAdapter((_) async => _error(503, 'INTERNAL'));
      final dio = build(adapter);

      await expectLater(
        dio.post<dynamic>('/events', data: <String, Object?>{}),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
    });

    test('4xx не повторяется', () async {
      final adapter = _FakeAdapter((_) async => _error(404, 'NOT_FOUND'));
      final dio = build(adapter);

      await expectLater(
        dio.get<dynamic>('/events/x'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<NotFoundException>(),
          ),
        ),
      );
      expect(adapter.calls, 1);
    });
  });

  group('ошибки', () {
    test('VALIDATION_FAILED разбирается с requestId', () async {
      final adapter = _FakeAdapter(
        (_) async => _error(400, 'VALIDATION_FAILED', requestId: 'req-1'),
      );
      final dio = build(adapter);

      try {
        await dio.get<dynamic>('/events');
        fail('ожидалось исключение');
      } on DioException catch (e) {
        final error = e.error;
        expect(error, isA<ValidationException>());
        expect((error as ApiException).requestId, 'req-1');
        expect(error.statusCode, 400);
      }
    });

    test('неизвестный code и тело не в формате Error: разбор по статусу', () async {
      final adapter = _FakeAdapter(
        (_) async => ResponseBody.fromString('<html>Bad gateway</html>', 502),
      );
      final dio = build(adapter);

      await expectLater(
        dio.post<dynamic>('/events', data: <String, Object?>{}),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ServerException>(),
          ),
        ),
      );
    });
  });
}
