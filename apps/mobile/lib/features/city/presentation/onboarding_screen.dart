import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/city/domain/city_models.dart';
import 'package:mobile/features/city/presentation/widgets/city_picker.dart';
import 'package:mobile/features/city/providers/cities_provider.dart';
import 'package:mobile/features/city/providers/city_provider.dart';

/// Онбординг: город → короткое объяснение ценности → лента.
///
/// Это один маршрут `/onboarding` с двумя шагами внутри. Город попадает в
/// `cityProvider` (и в память телефона) только в конце, на кнопках «В ленту»
/// и «Пропустить». Пока он не записан, роутер держит человека здесь, а как
/// только записан, сам уводит в ленту. Если закрыть приложение посреди
/// онбординга, он начнётся заново.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  CityOption? _city;
  bool _finishing = false;

  void _onCityPicked(CityOption city) {
    FocusScope.of(context).unfocus();
    setState(() => _city = city);
  }

  void _backToCity() => setState(() => _city = null);

  Future<void> _finish() async {
    final city = _city;
    if (city == null || _finishing) return;
    _finishing = true;
    await ref.read(cityProvider.notifier).selectCity(city.slug, name: city.name);
    // Дальше работает redirect роутера: город есть, значит, в ленту.
  }

  @override
  Widget build(BuildContext context) {
    // Список городов не перезагружается при возврате со второго шага.
    ref.listen(citiesProvider, (_, _) {});

    final city = _city;
    return PopScope(
      canPop: city == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToCity();
      },
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: city == null
                ? _CityStep(
                    key: const ValueKey('step_city'),
                    onSelected: _onCityPicked,
                  )
                : _ValueStep(
                    key: const ValueKey('step_value'),
                    city: city,
                    onBack: _backToCity,
                    onFinish: _finish,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CityStep extends StatelessWidget {
  final ValueChanged<CityOption> onSelected;
  const _CityStep({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppInsets.lg,
        AppInsets.xl,
        AppInsets.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingCityTitle, style: typography.h2),
          const SizedBox(height: AppInsets.sm),
          Text(
            l10n.onboardingCitySubtitle,
            style: typography.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppInsets.lg),
          Expanded(child: CityPicker(onSelected: onSelected)),
        ],
      ),
    );
  }
}

class _ValueStep extends StatelessWidget {
  final CityOption city;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const _ValueStep({
    super.key,
    required this.city,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppInsets.lg),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack,
              ),
              const Spacer(),
              TextButton(onPressed: onFinish, child: Text(l10n.onboardingSkip)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppInsets.lg),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: colors.brand),
                      const SizedBox(width: AppInsets.xs),
                      Flexible(
                        child: Text(
                          l10n.onboardingCityChosen(city.name),
                          style: typography.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppInsets.xl),
                  Text(l10n.onboardingValueTitle, style: typography.h2),
                  const SizedBox(height: AppInsets.xl),
                  _ValuePoint(
                    icon: Icons.event_outlined,
                    text: l10n.onboardingValue1,
                  ),
                  _ValuePoint(
                    icon: Icons.place_outlined,
                    text: l10n.onboardingValue2,
                  ),
                  _ValuePoint(
                    icon: Icons.favorite_border,
                    text: l10n.onboardingValue3,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onFinish,
              style: FilledButton.styleFrom(
                backgroundColor: colors.brand,
                foregroundColor: colors.background,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.onboardingStart),
            ),
          ),
          const SizedBox(height: AppInsets.xl),
        ],
      ),
    );
  }
}

class _ValuePoint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ValuePoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppInsets.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppInsets.sm),
            decoration: BoxDecoration(
              color: colors.brand.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.brand),
          ),
          const SizedBox(width: AppInsets.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppInsets.sm),
              child: Text(text, style: context.typography.body),
            ),
          ),
        ],
      ),
    );
  }
}
