import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Общая раскладка для [EmptyState] и [ErrorState]:
/// иллюстрация, заголовок, пояснение, кнопка.
class StateLayout extends StatelessWidget {
  const StateLayout({
    required this.icon,
    required this.title,
    this.subtitle,
    this.illustration,
    this.accent,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;

  /// Своя иллюстрация вместо иконки в круге.
  final Widget? illustration;

  /// Цвет иконки и подложки. По умолчанию — brand.
  final Color? accent;

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final tint = accent ?? colors.brand;
    final sub = subtitle;
    final label = actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppInsets.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration ??
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tint.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, size: 48, color: tint),
                ),
            const SizedBox(height: AppInsets.xl),
            Text(title, style: typography.h2, textAlign: TextAlign.center),
            if (sub != null) ...[
              const SizedBox(height: AppInsets.sm),
              Text(
                sub,
                style: typography.body.copyWith(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (label != null && onAction != null) ...[
              const SizedBox(height: AppInsets.xl),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  foregroundColor: colors.background,
                ),
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
