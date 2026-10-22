import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Один общий shimmer на всю группу «костей»: потомки рисуются сплошным цветом,
/// а градиент накладывается через ShaderMask (BlendMode.srcATop).
///
/// Цвета градиента непрозрачные (смешаны с фоном заранее): иначе в тёмной теме
/// белые «кости» просвечивали бы сквозь полупрозрачный градиент.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = Color.alphaBlend(
      colors.textSecondary.withValues(alpha: 0.14),
      colors.background,
    );
    final highlight = Color.alphaBlend(
      colors.textSecondary.withValues(alpha: 0.30),
      colors.background,
    );
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (rect) => LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlideGradient(-1 + 2 * _c.value),
        ).createShader(rect),
        child: child,
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.slide);

  final double slide;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}
