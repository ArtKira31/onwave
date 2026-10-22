import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _isOnline(List<ConnectivityResult> r) =>
    r.any((e) => e != ConnectivityResult.none);

/// Поток «есть ли сетевой интерфейс». Это не гарантия доступа в интернет
/// (Wi-Fi без выхода покажет true), поэтому ошибки запросов обрабатываются отдельно.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _isOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_isOnline);
});

/// Синхронный флаг для UI. Пока статус неизвестен — считаем, что онлайн.
final isOnlineProvider = Provider<bool>(
  (ref) => ref.watch(connectivityProvider).valueOrNull ?? true,
);
