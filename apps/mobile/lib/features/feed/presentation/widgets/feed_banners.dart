import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Инверсные цвета: достаточный контраст в обеих темах.
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: colors.textPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppInsets.lg,
          vertical: AppInsets.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off, size: 16, color: colors.background),
            const SizedBox(width: AppInsets.sm),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.offlineBanner,
                style: context.typography.caption.copyWith(
                  color: colors.background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StaleBanner extends StatelessWidget {
  final DateTime since;
  final VoidCallback onRefresh;
  const StaleBanner({required this.since, required this.onRefresh, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final time = DateFormat.MMMd(locale).add_Hm().format(since);
    return Container(
      width: double.infinity,
      color: colors.brand.withValues(alpha: 0.12),
      padding: const EdgeInsets.only(
        left: AppInsets.lg,
        right: AppInsets.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: colors.textPrimary),
          const SizedBox(width: AppInsets.sm),
          Expanded(
            child: Text(
              l10n.staleBanner(time),
              style: context.typography.caption.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          TextButton(onPressed: onRefresh, child: Text(l10n.refresh)),
        ],
      ),
    );
  }
}
