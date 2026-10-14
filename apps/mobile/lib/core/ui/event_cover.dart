import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Размер обложки в карточке. Совпадает со скелетоном.
const kEventCoverSize = 88.0;

/// Обложка события: дисковый кэш, плейсхолдер на время загрузки и фолбэк,
/// если URL нет или картинка не загрузилась.
class EventCover extends StatelessWidget {
  const EventCover({required this.url, this.size = kEventCoverSize, super.key});

  /// `cover.thumb` из API. Null или пустая строка → фолбэк без запроса в сеть.
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final u = url;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: AppRadius.borderMd,
        child: SizedBox(
          width: size,
          height: size,
          child: (u == null || u.isEmpty)
              ? const EventCoverPlaceholder(showIcon: true)
              : CachedNetworkImage(
                  imageUrl: u,
                  fit: BoxFit.cover,
                  // thumb в контракте 320x240 (альбомный): чтобы закрыть квадрат,
                  // важна высота. Декодируем сразу в нужном размере: меньше памяти.
                  memCacheHeight: (size * dpr).round(),
                  fadeInDuration: const Duration(milliseconds: 150),
                  fadeOutDuration: const Duration(milliseconds: 150),
                  placeholder: (context, url) => const EventCoverPlaceholder(),
                  errorWidget: (context, url, error) =>
                      const EventCoverPlaceholder(showIcon: true),
                ),
        ),
      ),
    );
  }
}

/// Заливка вместо обложки. [showIcon] == false — картинка ещё грузится,
/// true — обложки нет или она не загрузилась (фолбэк).
class EventCoverPlaceholder extends StatelessWidget {
  const EventCoverPlaceholder({this.showIcon = false, super.key});

  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.brand.withValues(alpha: 0.12),
      child: showIcon
          ? Center(
              child: Icon(Icons.image_outlined, color: colors.textSecondary),
            )
          : null,
    );
  }
}
