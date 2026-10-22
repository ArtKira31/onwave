import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/city/data/cities_repository.dart';
import 'package:mobile/features/city/data/location_service.dart';
import 'package:mobile/features/city/domain/city_models.dart';
import 'package:mobile/features/city/presentation/widgets/city_picker.dart';

const _tbilisi = CityOption(id: '1', slug: 'tbilisi', name: 'Тбилиси', lat: 41.7151, lon: 44.8271);
const _belgrade = CityOption(id: '2', slug: 'belgrade', name: 'Белград', lat: 44.7866, lon: 20.4489);
const _batumi = CityOption(id: '3', slug: 'batumi', name: 'Батуми', lat: 41.6168, lon: 41.6367);

class _Repo implements CitiesRepository {
  @override
  Future<List<CityOption>> fetchCities() async => [_tbilisi, _belgrade, _batumi];
}

class _Location implements LocationService {
  final DeviceLocation location;
  _Location(this.location);

  @override
  Future<DeviceLocation> currentLocation() async => location;

  @override
  Future<void> openSettings() async {}
}

Widget _app(ValueChanged<CityOption> onSelected, {LocationService? location}) {
  return ProviderScope(
    overrides: [
      citiesRepositoryProvider.overrideWithValue(_Repo()),
      if (location != null) locationServiceProvider.overrideWithValue(location),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: CityPicker(onSelected: onSelected),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('показывает города и плашку автоопределения', (tester) async {
    await tester.pumpWidget(_app((_) {}));
    await tester.pumpAndSettle();

    expect(find.text('Тбилиси'), findsOneWidget);
    expect(find.text('Белград'), findsOneWidget);
    expect(find.text('Определить автоматически'), findsOneWidget);
  });

  testWidgets('поиск фильтрует список и прячет плашку', (tester) async {
    await tester.pumpWidget(_app((_) {}));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'бел');
    await tester.pump();

    expect(find.text('Белград'), findsOneWidget);
    expect(find.text('Тбилиси'), findsNothing);
    expect(find.text('Определить автоматически'), findsNothing);
  });

  testWidgets('поиск без результатов показывает пустое состояние', (tester) async {
    await tester.pumpWidget(_app((_) {}));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();

    expect(find.text('Город не найден'), findsOneWidget);
  });

  testWidgets('тап по городу отдаёт его наружу', (tester) async {
    CityOption? picked;
    await tester.pumpWidget(_app((c) => picked = c));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Белград'));
    await tester.pump();

    expect(picked?.slug, 'belgrade');
  });

  testWidgets('автоопределение выбирает ближайший город', (tester) async {
    CityOption? picked;
    await tester.pumpWidget(
      _app((c) => picked = c, location: _Location(const DeviceLocation(41.72, 44.79))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Определить автоматически'));
    await tester.pumpAndSettle();

    expect(picked?.slug, 'tbilisi');
  });

  testWidgets('автоопределение вдали от городов ничего не выбирает и объясняет', (tester) async {
    CityOption? picked;
    await tester.pumpWidget(
      _app((c) => picked = c, location: _Location(const DeviceLocation(42.87, 74.59))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Определить автоматически'));
    await tester.pumpAndSettle();

    expect(picked, isNull);
    expect(find.textContaining('нет доступных городов'), findsOneWidget);
  });
}
