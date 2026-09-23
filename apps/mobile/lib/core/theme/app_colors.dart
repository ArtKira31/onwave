import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color brand;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;

  const AppColors({
    required this.brand,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
  });

  static const light = AppColors(
    brand: Color(0xFF6200EE),
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A1A1A), // Высокий контраст (16.5:1)
    textSecondary: Color(0xFF6C757D), // Контраст (4.6:1)
    error: Color(0xFFDC3545),
  );

  static const dark = AppColors(
    brand: Color(0xFFBB86FC),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFFFFFFF), // Высокий контраст
    textSecondary: Color(0xFFA0A0A0), // Контраст (4.8:1)
    error: Color(0xFFCF6679),
  );

  @override
  AppColors copyWith({
    Color? brand,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? error,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brand: Color.lerp(brand, other.brand, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
