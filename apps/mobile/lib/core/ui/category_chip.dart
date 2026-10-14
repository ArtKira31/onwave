import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Чип категории с состоянием «выбрано / не выбрано».
/// Выбранный дополнительно помечен галочкой, чтобы состояние читалось не только цветом.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Ограничиваем ширину подписи, чтобы чип не ломался в горизонтальном списке
  /// (там ширина не ограничена и Flexible нельзя).
  static const _maxLabelWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    // На брендовой заливке текст в цвет фона: контраст достаточный в обеих темах.
    final fg = selected ? colors.background : colors.textPrimary;

    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? colors.brand : colors.surface,
        clipBehavior: Clip.antiAlias,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? colors.brand : colors.textSecondary),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppInsets.lg,
                vertical: AppInsets.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check, size: 16, color: fg),
                    const SizedBox(width: AppInsets.xs),
                  ],
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxLabelWidth),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.copyWith(
                        fontSize: 14,
                        color: fg,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
