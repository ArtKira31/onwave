import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/ui/category_chip.dart';
import 'package:mobile/core/ui/empty_state.dart';
import 'package:mobile/core/ui/error_state.dart';
import 'package:mobile/core/ui/event_card.dart';
import 'package:mobile/core/ui/event_cover.dart';
import 'package:mobile/core/ui/skeleton_loader.dart';

void _noop() {}

const _okCover = 'https://picsum.photos/seed/onwave-catalog/320/240';
const _brokenCover = 'https://invalid.invalid/cover.jpg';
const _longTitle =
    'Международный фестиваль современной музыки, перформанса и визуального '
    'искусства под открытым небом «Ночь в Тбилиси»: специальная программа '
    'для всей семьи и ночной оркестр';

/// Каталог общих компонентов (ONW-46). Каждый блок показан в светлой и тёмной
/// теме одновременно, независимо от темы системы.
class ComponentsCatalog extends StatelessWidget {
  const ComponentsCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Section(
          title: 'CATEGORYCHIP',
          note: 'Не выбран · выбран · очень длинная подпись',
          builder: (_) => const Wrap(
            spacing: AppInsets.sm,
            runSpacing: AppInsets.sm,
            children: [
              CategoryChip(label: 'Концерты', selected: false, onTap: _noop),
              CategoryChip(label: 'Театр', selected: true, onTap: _noop),
              CategoryChip(
                label:
                    'Международные фестивали и open-air события под открытым небом',
                selected: false,
                onTap: _noop,
              ),
              CategoryChip(
                label:
                    'Международные фестивали и open-air события под открытым небом',
                selected: true,
                onTap: _noop,
              ),
            ],
          ),
        ),
        _Section(
          title: 'EVENTCARD',
          note:
              'Обычная · без обложки · обложка не загрузилась · '
              'длинный заголовок · без даты и площадки',
          builder: (_) {
            final date = DateTime.now().add(const Duration(days: 3, hours: 2));
            return Column(
              children: [
                EventCard(
                  title: 'Концерт симфонического оркестра',
                  coverUrl: _okCover,
                  categoryLabel: 'Концерты',
                  venueName: 'Тбилисский концертный зал',
                  startsAt: date,
                  moreDatesLabel: 'и ещё 2 даты',
                  onTap: _noop,
                ),
                EventCard(
                  title: 'Выставка без обложки',
                  categoryLabel: 'Выставки',
                  venueName: 'Fabrika',
                  startsAt: date,
                  onTap: _noop,
                ),
                EventCard(
                  title: 'Обложка не загрузилась',
                  coverUrl: _brokenCover,
                  categoryLabel: 'Театр',
                  venueName: 'Дом омладине',
                  startsAt: date,
                  onTap: _noop,
                ),
                EventCard(
                  title: _longTitle,
                  coverUrl: _okCover,
                  categoryLabel: 'Образование и развитие для всей семьи',
                  venueName:
                      'Очень длинное название площадки, которое не помещается в одну строку',
                  startsAt: date,
                  moreDatesLabel: 'и ещё 12 дат',
                  onTap: _noop,
                ),
                const EventCard(title: 'Только заголовок', onTap: _noop),
              ],
            );
          },
        ),
        _Section(
          title: 'ОБЛОЖКА',
          note: 'Плейсхолдер на время загрузки · фолбэк (нет картинки / ошибка)',
          builder: (_) => const Row(
            children: [
              SizedBox.square(
                dimension: kEventCoverSize,
                child: EventCoverPlaceholder(),
              ),
              SizedBox(width: AppInsets.md),
              SizedBox.square(
                dimension: kEventCoverSize,
                child: EventCoverPlaceholder(showIcon: true),
              ),
            ],
          ),
        ),
        const _Section(
          title: 'SKELETONLOADER',
          note: 'Одна карточка · список',
          builder: _skeletons,
        ),
        _Section(
          title: 'EMPTYSTATE',
          note: 'С кнопкой действия · без кнопки',
          builder: (_) => Column(
            children: [
              EmptyState(
                title: 'Пока нет событий',
                subtitle:
                    'В выбранном городе нет событий по текущему фильтру.',
                actionLabel: 'Сбросить фильтры',
                onAction: _noop,
              ),
              const EmptyState(
                icon: Icons.favorite_border,
                title: 'В избранном пусто',
                subtitle: 'Нажмите на сердечко у события, чтобы сохранить его.',
              ),
            ],
          ),
        ),
        _Section(
          title: 'ERRORSTATE',
          note: 'Нет сети · что-то сломалось (кнопка «Повторить» всегда есть)',
          builder: (_) => const Column(
            children: [
              ErrorState.network(onRetry: _noop),
              ErrorState.generic(onRetry: _noop),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _skeletons(BuildContext context) => const Column(
  children: [SkeletonLoader.card(), SkeletonLoader.list(count: 3)],
);

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.builder, this.note});

  final String title;
  final String? note;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final n = note;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppInsets.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.h2),
          if (n != null) Text(n, style: typography.caption),
          const SizedBox(height: AppInsets.sm),
          _Themed(label: 'Светлая тема', theme: AppTheme.light, builder: builder),
          const SizedBox(height: AppInsets.md),
          _Themed(label: 'Тёмная тема', theme: AppTheme.dark, builder: builder),
        ],
      ),
    );
  }
}

class _Themed extends StatelessWidget {
  const _Themed({
    required this.label,
    required this.theme,
    required this.builder,
  });

  final String label;
  final ThemeData theme;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final outer = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.typography.caption),
        const SizedBox(height: AppInsets.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: outer.textSecondary.withValues(alpha: 0.3)),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderLg,
            child: Theme(
              data: theme,
              child: Builder(
                builder: (inner) => Material(
                  color: inner.colors.background,
                  child: Padding(
                    padding: const EdgeInsets.all(AppInsets.md),
                    child: builder(inner),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
