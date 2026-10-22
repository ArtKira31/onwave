import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/storage/preferences_provider.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Выбранный город читаем до первого кадра: так роутер сразу знает, нужен ли
  // онбординг, и при повторном запуске он не мигает.
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'onwave',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,

      // ПОДКЛЮЧАЕМ ЛОКАЛИЗАЦИЮ ЗДЕСЬ:
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
