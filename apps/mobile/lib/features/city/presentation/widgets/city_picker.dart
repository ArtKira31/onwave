import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/network/connectivity_provider.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/ui/empty_state.dart';
import 'package:mobile/core/ui/error_state.dart';
import 'package:mobile/features/city/data/location_service.dart';
import 'package:mobile/features/city/domain/city_models.dart';
import 'package:mobile/features/city/providers/cities_provider.dart';
import 'package:mobile/features/city/providers/city_detect_provider.dart';

/// Выбор города: поиск, плашка «Определить автоматически» и список.
/// Один и тот же виджет в онбординге и на экране смены города.
/// Сам ничего не сохраняет: выбранный город отдаётся в [onSelected].
class CityPicker extends ConsumerStatefulWidget {
  final ValueChanged<CityOption> onSelected;

  /// slug текущего города (отмечается галочкой).
  final String? selectedSlug;

  const CityPicker({super.key, required this.onSelected, this.selectedSlug});

  @override
  ConsumerState<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends ConsumerState<CityPicker> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _detect(List<CityOption> cities) async {
    final city = await ref.read(cityDetectProvider.notifier).detect(cities);
    if (city != null && mounted) widget.onSelected(city);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cities = ref.watch(citiesProvider);

    return cities.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) {
        final online = ref.watch(isOnlineProvider);
        void retry() => ref.invalidate(citiesProvider);
        return online
            ? ErrorState.generic(onRetry: retry, title: l10n.cityListErrorTitle)
            : ErrorState.network(onRetry: retry);
      },
      data: _buildData,
    );
  }

  Widget _buildData(List<CityOption> all) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final typography = context.typography;

    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(q)).toList();
    // Пока человек ищет вручную, плашку автоопределения не показываем.
    final showDetect = q.isEmpty;
    final itemCount = filtered.length + (showDetect ? 1 : 0);

    final border = OutlineInputBorder(
      borderRadius: AppRadius.borderLg,
      borderSide: BorderSide(color: colors.textSecondary.withValues(alpha: 0.3)),
    );

    return Column(
      children: [
        TextField(
          controller: _controller,
          style: typography.body,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: l10n.citySearchHint,
            hintStyle: typography.body.copyWith(color: colors.textSecondary),
            prefixIcon: Icon(Icons.search, color: colors.textSecondary),
            filled: true,
            fillColor: colors.surface,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: colors.brand, width: 2),
            ),
          ),
        ),
        const SizedBox(height: AppInsets.md),
        Expanded(
          child: itemCount == 0
              ? EmptyState(
                  title: l10n.citySearchEmptyTitle,
                  subtitle: l10n.citySearchEmptySubtitle,
                )
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (showDetect && index == 0) {
                      return _DetectCard(onDetect: () => _detect(all));
                    }
                    final city = filtered[index - (showDetect ? 1 : 0)];
                    return _CityTile(
                      city: city,
                      selected: city.slug == widget.selectedSlug,
                      onTap: () => widget.onSelected(city),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CityTile extends StatelessWidget {
  final CityOption city;
  final bool selected;
  final VoidCallback onTap;

  const _CityTile({
    required this.city,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      title: Text(city.name, style: context.typography.body),
      trailing: selected ? Icon(Icons.check, color: colors.brand) : null,
      selected: selected,
      selectedTileColor: colors.brand.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      onTap: onTap,
    );
  }
}

/// Плашка автоопределения. Объяснение «зачем» стоит до тапа: система
/// спросит разрешение только после нажатия кнопки.
class _DetectCard extends ConsumerWidget {
  final VoidCallback onDetect;
  const _DetectCard({required this.onDetect});

  String? _message(AppLocalizations l10n, DetectStatus status) =>
      switch (status) {
        DetectStatus.idle || DetectStatus.loading => null,
        DetectStatus.noNearby => l10n.cityDetectNoNearby,
        DetectStatus.servicesDisabled => l10n.cityDetectServicesOff,
        DetectStatus.denied => l10n.cityDetectDenied,
        DetectStatus.deniedForever => l10n.cityDetectDeniedForever,
        DetectStatus.unavailable => l10n.cityDetectUnavailable,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final typography = context.typography;
    final status = ref.watch(cityDetectProvider);
    final loading = status == DetectStatus.loading;
    final message = _message(l10n, status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppInsets.md),
      padding: const EdgeInsets.all(AppInsets.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderLg,
        boxShadow: context.shadows,
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cityDetectExplanation,
            style: typography.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppInsets.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : onDetect,
              style: FilledButton.styleFrom(
                backgroundColor: colors.brand,
                foregroundColor: colors.background,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: loading
                  ? const SizedBox(
                      width: AppInsets.lg,
                      height: AppInsets.lg,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(loading ? l10n.cityDetecting : l10n.cityDetectAuto),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppInsets.md),
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: typography.body.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
          if (status == DetectStatus.deniedForever)
            TextButton(
              onPressed: () => ref.read(locationServiceProvider).openSettings(),
              child: Text(l10n.cityDetectOpenSettings),
            ),
        ],
      ),
    );
  }
}
