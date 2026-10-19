import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/city/providers/city_provider.dart';

/// Название города в шапке ленты. Тап открывает экран смены города.
class CityButton extends ConsumerWidget {
  const CityButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final name = ref.watch(cityNameProvider) ?? ref.watch(cityProvider) ?? '';

    return Semantics(
      button: true,
      label: '${l10n.cityChange}: $name',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: () => const CitySelectRoute().push(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppInsets.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined, color: colors.brand),
                const SizedBox(width: AppInsets.xs),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.h2,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
