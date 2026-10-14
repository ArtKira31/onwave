import 'package:flutter/material.dart';
import 'package:mobile/core/ui/state_layout.dart';

/// Пустое состояние: иллюстрация, текст, необязательная кнопка действия
/// («Сбросить фильтры», «Выбрать город» и т. п.). Тексты задаёт экран.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.subtitle,
    this.icon = Icons.event_busy,
    this.illustration,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel и onAction задаются вместе',
       );

  final String title;
  final String? subtitle;
  final IconData icon;

  /// Своя иллюстрация вместо иконки.
  final Widget? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => StateLayout(
    icon: icon,
    illustration: illustration,
    title: title,
    subtitle: subtitle,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}
