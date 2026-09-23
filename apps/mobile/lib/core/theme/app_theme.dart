import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_sizes.dart';

class AppTheme {
  static ThemeData get light {
    final colors = AppColors.light;
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      useMaterial3: true,
      extensions: [colors, AppShadows.light, AppTypography.generate(colors)],
    );
  }

  static ThemeData get dark {
    final colors = AppColors.dark;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      useMaterial3: true,
      extensions: [colors, AppShadows.dark, AppTypography.generate(colors)],
    );
  }
}

// Удобные расширения для вызова токенов из любого экрана приложения
extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;
  List<BoxShadow> get shadows =>
      Theme.of(this).extension<AppShadows>()!.primary;
}
