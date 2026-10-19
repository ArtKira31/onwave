import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Экземпляр [SharedPreferences], прочитанный один раз в `main()` до запуска
/// приложения. Благодаря этому выбранный город известен синхронно, ещё до
/// первого кадра, и роутер не мигает онбордингом при повторном запуске.
///
/// В тестах подменяется:
/// `sharedPreferencesProvider.overrideWithValue(prefs)`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider нужно переопределить в ProviderScope (main.dart)',
  ),
);
