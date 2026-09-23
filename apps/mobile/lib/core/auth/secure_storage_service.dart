import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
    : _storage = FlutterSecureStorage(
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );

  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyDeviceId = 'device_id';

  /// Запись токенов с защитой от аппаратных сбоев
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String deviceId,
  }) async {
    try {
      await _storage.write(key: _keyAccess, value: accessToken);
      await _storage.write(key: _keyRefresh, value: refreshToken);
      await _storage.write(key: _keyDeviceId, value: deviceId);
    } on PlatformException catch (_) {
      // Если Keystore временно недоступен — приложение не падает
    }
  }

  /// Чтение токенов. При ошибке железа возвращаем null (откат к гостю)
  Future<Map<String, String?>?> readSession() async {
    try {
      final access = await _storage.read(key: _keyAccess);
      final refresh = await _storage.read(key: _keyRefresh);
      final deviceId = await _storage.read(key: _keyDeviceId);
      return {'access': access, 'refresh': refresh, 'deviceId': deviceId};
    } on PlatformException catch (_) {
      return null; // Безопасный откат в гостевой режим при сбое
    }
  }

  /// Полная очистка хранилища при Logout
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } on PlatformException catch (_) {
      // Игнорируем ошибки при очистке
    }
  }
}
