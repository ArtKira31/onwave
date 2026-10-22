import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/storage/preferences_provider.dart';
import 'package:mobile/features/city/providers/city_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('по умолчанию город не выбран', () async {
    final c = await _container({});
    expect(c.read(cityProvider), isNull);
    expect(c.read(cityNameProvider), isNull);
  });

  test('выбор сохраняется и виден слушателям', () async {
    final c = await _container({});
    var notified = 0;
    c.listen(cityProvider, (_, _) => notified++);

    await c.read(cityProvider.notifier).selectCity('tbilisi', name: 'Тбилиси');

    expect(c.read(cityProvider), 'tbilisi');
    expect(c.read(cityNameProvider), 'Тбилиси');
    expect(notified, 1);
  });

  test('после перезапуска город восстанавливается (онбординг не нужен)', () async {
    final first = await _container({});
    await first
        .read(cityProvider.notifier)
        .selectCity('belgrade', name: 'Белград');
    final saved = (await SharedPreferences.getInstance()).getKeys();

    // «Перезапуск»: новый контейнер поверх тех же сохранённых данных.
    final prefs = await SharedPreferences.getInstance();
    final second = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(second.dispose);

    expect(saved, isNotEmpty);
    expect(second.read(cityProvider), 'belgrade');
    expect(second.read(cityNameProvider), 'Белград');
  });

  test('смена города обновляет и slug, и название', () async {
    final c = await _container({});
    final notifier = c.read(cityProvider.notifier);

    await notifier.selectCity('tbilisi', name: 'Тбилиси');
    await notifier.selectCity('belgrade', name: 'Белград');

    expect(c.read(cityProvider), 'belgrade');
    expect(c.read(cityNameProvider), 'Белград');
  });

  test('выбор без названия стирает старое название', () async {
    final c = await _container({});
    final notifier = c.read(cityProvider.notifier);

    await notifier.selectCity('tbilisi', name: 'Тбилиси');
    await notifier.selectCity('belgrade');

    expect(c.read(cityNameProvider), isNull);
  });
}
