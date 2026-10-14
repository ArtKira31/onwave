import 'package:flutter/material.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/ui/state_layout.dart';

/// Причина ошибки: определяет иллюстрацию и тексты по умолчанию.
enum ErrorKind {
  /// Нет сети / таймаут.
  network,

  /// Всё остальное: 5xx, неожиданный ответ, исключение.
  generic,
}

/// Состояние ошибки. Кнопка «Повторить» есть всегда: [onRetry] обязателен.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.kind,
    required this.onRetry,
    this.title,
    this.subtitle,
    super.key,
  });

  const ErrorState.network({
    required this.onRetry,
    this.title,
    this.subtitle,
    super.key,
  }) : kind = ErrorKind.network;

  const ErrorState.generic({
    required this.onRetry,
    this.title,
    this.subtitle,
    super.key,
  }) : kind = ErrorKind.generic;

  final ErrorKind kind;
  final VoidCallback onRetry;

  /// Переопределяют тексты по умолчанию (например «Не удалось загрузить ленту»).
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final isNetwork = kind == ErrorKind.network;

    return StateLayout(
      icon: isNetwork ? Icons.wifi_off : Icons.error_outline,
      accent: isNetwork ? colors.textSecondary : colors.error,
      title: title ?? (isNetwork ? l10n.errorNetworkTitle : l10n.errorGenericTitle),
      subtitle:
          subtitle ??
          (isNetwork ? l10n.errorNetworkSubtitle : l10n.errorGenericSubtitle),
      actionLabel: l10n.retry,
      onAction: onRetry,
    );
  }
}
