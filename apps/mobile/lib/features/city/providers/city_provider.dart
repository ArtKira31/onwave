import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/storage/preferences_provider.dart';

const _kCitySlug = 'selected_city_slug';
const _kCityName = 'selected_city_name';

/// Выбранный город: slug (`tbilisi`) или `null`, пока город не выбран.
/// Сохраняется в shared_preferences и читается синхронно при старте, поэтому
/// после перезапуска онбординг не показывается.
class CityNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_kCitySlug);

  /// Сохраняет город и только потом обновляет состояние: слушатели (роутер,
  /// лента, [cityNameProvider]) всегда видят уже записанные значения.
  Future<void> selectCity(String slug, {String? name}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kCitySlug, slug);
    if (name != null) {
      await prefs.setString(_kCityName, name);
    } else {
      await prefs.remove(_kCityName);
    }
    state = slug;
  }
}

final cityProvider = NotifierProvider<CityNotifier, String?>(CityNotifier.new);

/// Название выбранного города для шапки ленты и профиля.
final cityNameProvider = Provider<String?>((ref) {
  ref.watch(cityProvider); // пересчитывается при каждой смене города
  return ref.watch(sharedPreferencesProvider).getString(_kCityName);
});
