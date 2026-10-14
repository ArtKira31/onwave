import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/ui/event_cover.dart';
import 'package:mobile/core/utils/date_formatter.dart';

/// Карточка события для ленты, избранного, «Моих событий».
///
/// Намеренно не знает про доменные модели и DTO: принимает простые значения,
/// тексты (категория, «и ещё N дат») приходят уже локализованными.
///
/// Переживает: нет обложки, обложка не загрузилась, очень длинный заголовок
/// (2 строки + многоточие), отсутствие даты / площадки / категории.
class EventCard extends StatelessWidget {
  const EventCard({
    required this.title,
    required this.onTap,
    this.coverUrl,
    this.categoryLabel,
    this.venueName,
    this.startsAt,
    this.moreDatesLabel,
    super.key,
  });

  final String title;
  final VoidCallback onTap;

  /// `cover.thumb`. Null → фолбэк-заливка.
  final String? coverUrl;

  /// Уже локализованная подпись категории; null → строка скрыта.
  final String? categoryLabel;
  final String? venueName;

  /// Ближайший сеанс в локальном времени; null → строка скрыта.
  final DateTime? startsAt;

  /// Например «и ещё 2 даты»; null → строка скрыта.
  final String? moreDatesLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final locale = Localizations.localeOf(context).toString();
    final category = categoryLabel;
    final venue = venueName;
    final date = startsAt;
    final more = moreDatesLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppInsets.lg,
        vertical: AppInsets.xs,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.borderLg,
          boxShadow: context.shadows,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.borderLg,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppInsets.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventCover(url: coverUrl),
                  const SizedBox(width: AppInsets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (category != null)
                          Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.caption.copyWith(
                              color: colors.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (venue != null)
                          Text(
                            venue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.caption,
                          ),
                        if (date != null)
                          Text(
                            AppDateFormatter.formatEventDate(date, locale),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.caption,
                          ),
                        if (more != null)
                          Text(
                            more,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.caption.copyWith(
                              color: colors.brand,
                            ),
                          ),
                      ],
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
