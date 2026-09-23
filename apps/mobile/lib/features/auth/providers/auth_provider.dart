import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/auth/secure_storage_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? accessToken;
  final String? deviceId;

  AuthState({required this.isAuthenticated, this.accessToken, this.deviceId});
}

// Провайдер для самого сервиса хранения
final secureStorageProvider = Provider((ref) => SecureStorageService());

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _storage;
  final Ref _ref;

  AuthNotifier(this._storage, this._ref)
    : super(AuthState(isAuthenticated: false)) {
    _tryRestoreSession(); // Автоматически восстанавливаем сессию при холодном старте
  }

  /// Холодный старт: пытаемся безопасно прочитать токены из Keychain / Keystore
  Future<void> _tryRestoreSession() async {
    final session = await _storage.readSession();

    // Если хранилище недоступно из-за сбоя Keystore (session == null) или токенов нет
    if (session != null && session['access'] != null) {
      state = AuthState(
        isAuthenticated: true,
        accessToken: session['access'],
        deviceId: session['deviceId'],
      );
    } else {
      // Безопасный откат к гостевому режиму по требованиям ТЗ
      state = AuthState(isAuthenticated: false);
    }
  }

  /// Логин с безопасным сохранением сессии в Keystore / Keychain
  Future<void> login() async {
    const mockAccess = 'mock_access_token_123';
    const mockRefresh = 'mock_refresh_token_123';
    const mockDeviceId = 'device_id_samsung_abc';

    // Записываем токены в защищенную память устройства
    await _storage.saveSession(
      accessToken: mockAccess,
      refreshToken: mockRefresh,
      deviceId: mockDeviceId,
    );

    state = AuthState(
      isAuthenticated: true,
      accessToken: mockAccess,
      deviceId: mockDeviceId,
    );
  }

  /// Логаут с полной очисткой Keystore и сбросом кэшей ответов
  Future<void> logout() async {
    // 1. Стираем все токены из Keychain / Keystore
    await _storage.clearAll();

    // 2. Сбрасываем состояния кэшей ответов Riverpod, если они будут добавлены в проект
    // В будущем здесь можно будет вызывать: _ref.invalidate(someCacheProvider);

    // 3. Переводим приложение в гостевой режим
    state = AuthState(isAuthenticated: false);
  }
}

// Передаем ref внутрь нотификатора для будущей инвалидации кэшей
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage, ref);
});
