import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_sizes.dart';

class DebugDesignSystemScreen extends StatelessWidget {
  const DebugDesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Catalog'),
        backgroundColor: colors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppInsets.lg),
        children: [
          Text('ЦВЕТОВЫЕ ТОКЕНЫ', style: typography.h2),
          const SizedBox(height: AppInsets.sm),
          _buildColorCard('Brand Color', colors.brand, colors.textPrimary),
          _buildColorCard('Background', colors.background, colors.textPrimary),
          _buildColorCard('Surface', colors.surface, colors.textPrimary),
          _buildColorCard(
            'Text Primary',
            colors.textPrimary,
            colors.background,
          ),
          _buildColorCard(
            'Text Secondary',
            colors.textSecondary,
            colors.background,
          ),

          const SizedBox(height: AppInsets.xl),

          Text('ТИПОГРАФИКА', style: typography.h2),
          const SizedBox(height: AppInsets.sm),
          Text('Heading 1 Text Style', style: typography.h1),
          const SizedBox(height: AppInsets.xs),
          Text('Heading 2 Text Style', style: typography.h2),
          const SizedBox(height: AppInsets.xs),
          Text(
            'Body Regular Text Style — Поддержка системного скейлинга.',
            style: typography.body,
          ),
          const SizedBox(height: AppInsets.xs),
          Text('Caption Text Style', style: typography.caption),

          const SizedBox(height: AppInsets.xl),

          Text('РАДИУСЫ И ТЕНИ', style: typography.h2),
          const SizedBox(height: AppInsets.sm),
          Container(
            padding: const EdgeInsets.all(AppInsets.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.borderMd,
              boxShadow: context.shadows,
            ),
            child: Text(
              'Карточка с AppRadius.borderMd и адаптивной тенью',
              style: typography.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(String name, Color color, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppInsets.xs),
      padding: const EdgeInsets.all(AppInsets.md),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          Text(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }
}
