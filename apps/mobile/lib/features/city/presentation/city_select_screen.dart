import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/features/city/domain/city_models.dart';
import 'package:mobile/features/city/presentation/widgets/city_picker.dart';
import 'package:mobile/features/city/providers/cities_provider.dart';
import 'package:mobile/features/city/providers/city_provider.dart';

/// Смена города после онбординга: из шапки ленты и из профиля.
class CitySelectScreen extends ConsumerWidget {
  const CitySelectScreen({super.key});

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    CityOption city,
  ) async {
    await ref.read(cityProvider.notifier).selectCity(city.slug, name: city.name);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(cityProvider);
    // Держим список живым, пока экран открыт.
    ref.listen(citiesProvider, (_, _) {});

    return Scaffold(
      appBar: AppBar(title: Text(l10n.citySelectTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppInsets.lg,
            AppInsets.sm,
            AppInsets.lg,
            0,
          ),
          child: CityPicker(
            selectedSlug: current,
            onSelected: (city) => _select(context, ref, city),
          ),
        ),
      ),
    );
  }
}
