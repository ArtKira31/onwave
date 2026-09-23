import 'package:flutter/material.dart';

/// Шкала отступов (строго кратная 4)
class AppInsets {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Фиксированный набор радиусов
class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 16.0;
  static const double max = 99.0; // Для круглых кнопок/аватарок

  static final BorderRadius borderSm = BorderRadius.circular(sm);
  static final BorderRadius borderMd = BorderRadius.circular(md);
  static final BorderRadius borderLg = BorderRadius.circular(lg);
  static final BorderRadius borderMax = BorderRadius.circular(max);
}

/// Токены теней через ThemeExtension для адаптации под темную тему
class AppShadows extends ThemeExtension<AppShadows> {
  final List<BoxShadow> primary;

  const AppShadows({required this.primary});

  static final light = AppShadows(
    primary: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const dark = AppShadows(
    primary: [], // В темной теме объем задаем цветом surface, а не тенями
  );

  @override
  AppShadows copyWith({List<BoxShadow>? primary}) =>
      AppShadows(primary: primary ?? this.primary);

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) => this;
}
