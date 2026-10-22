import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/ui/event_cover.dart';
import 'package:mobile/core/ui/shimmer.dart';

/// Скелетоны под карточку и список.
///
///   SkeletonLoader.card()          — одна карточка
///   SkeletonLoader.list(count: 6)  — список карточек
///
/// Shimmer один на всю группу, поэтому анимация синхронная.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader.card({super.key}) : count = 1;
  const SkeletonLoader.list({this.count = 6, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Shimmer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++) const EventCardSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Скелетон одной карточки. Повторяет раскладку [EventCard].
/// Сам по себе не анимирован: оборачивать в [Shimmer] или брать [SkeletonLoader].
class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppInsets.lg,
        vertical: AppInsets.xs,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppInsets.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBone(
              width: kEventCoverSize,
              height: kEventCoverSize,
              radius: AppRadius.md,
            ),
            SizedBox(width: AppInsets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Line(widthFactor: 0.35, height: 12),
                  SizedBox(height: AppInsets.sm),
                  _Line(widthFactor: 1, height: 16),
                  SizedBox(height: AppInsets.xs),
                  _Line(widthFactor: 0.8, height: 12),
                  SizedBox(height: AppInsets.xs),
                  _Line(widthFactor: 0.6, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Строка-«кость» шириной в долю доступного места: не ломается на узких экранах.
class _Line extends StatelessWidget {
  const _Line({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: widthFactor,
    alignment: Alignment.centerLeft,
    child: SkeletonBone(height: height),
  );
}

/// Базовый элемент скелетона. Цвет задаёт градиент [Shimmer].
class SkeletonBone extends StatelessWidget {
  const SkeletonBone({
    required this.height,
    this.width,
    this.radius = AppRadius.sm,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
