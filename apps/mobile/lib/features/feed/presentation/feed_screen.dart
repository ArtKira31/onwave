import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/l10n/app_localizations.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/core/network/connectivity_provider.dart';
import 'package:mobile/core/theme/app_sizes.dart';
import 'package:mobile/core/ui/empty_state.dart';
import 'package:mobile/core/ui/error_state.dart';
import 'package:mobile/core/ui/event_card.dart';
import 'package:mobile/core/ui/skeleton_loader.dart';
import 'package:mobile/features/feed/presentation/category_label.dart';
import 'package:mobile/features/feed/presentation/widgets/feed_banners.dart';
import 'package:mobile/features/feed/providers/feed_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final feed = ref.watch(feedControllerProvider);
    final online = ref.watch(isOnlineProvider);
    final controller = ref.read(feedControllerProvider.notifier);

    Future<void> onRefresh() async {
      final ok = await controller.refresh();
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.feedRefreshFailed)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedTitle)),
      body: Column(
        children: [
          if (!online) const OfflineBanner(),
          if (feed.isStale) StaleBanner(since: feed.staleSince!, onRefresh: onRefresh),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: CustomScrollView(
                // Сохраняет позицию скролла при возврате с карточки события.
                key: const PageStorageKey('feed_list_scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: _buildSlivers(context, feed, controller, online),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    FeedState feed,
    FeedController controller,
    bool online,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (feed.status) {
      case FeedStatus.loading:
        return [const SliverToBoxAdapter(child: SkeletonLoader.list(count: 7))];
      case FeedStatus.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: online
                ? ErrorState.generic(
                    onRetry: controller.retry,
                    title: l10n.feedErrorTitle,
                    subtitle: l10n.feedErrorSubtitle,
                  )
                : ErrorState.network(onRetry: controller.retry),
          ),
        ];
      case FeedStatus.empty:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: l10n.feedEmptyTitle,
              subtitle: l10n.feedEmptySubtitle,
            ),
          ),
        ];
      case FeedStatus.data:
        final items = feed.items;
        return [
          SliverPadding(
            padding: const EdgeInsets.only(top: AppInsets.sm),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                // Подгрузка заранее: не ждём, пока пользователь упрётся в конец.
                if (index >= items.length - kFeedPrefetchDistance) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadMore());
                }
                final event = items[index];
                return EventCard(
                  key: ValueKey(event.id),
                  title: event.title,
                  coverUrl: event.coverThumbUrl,
                  categoryLabel: categoryLabel(l10n, event.categorySlug),
                  venueName: event.venueName,
                  startsAt: event.startsAt,
                  moreDatesLabel: event.sessionCount > 1
                      ? l10n.moreDates(event.sessionCount - 1)
                      : null,
                  onTap: () => EventDetailRoute(id: event.id).push(context),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _Footer(feed: feed, controller: controller),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppInsets.xl)),
        ];
    }
  }
}

class _Footer extends StatelessWidget {
  final FeedState feed;
  final FeedController controller;
  const _Footer({required this.feed, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (feed.isLoadingMore) {
      return const SkeletonLoader.card();
    }
    if (feed.loadMoreFailed) {
      final l10n = AppLocalizations.of(context)!;
      return Padding(
        padding: const EdgeInsets.all(AppInsets.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.feedLoadMoreFailed),
            TextButton(onPressed: controller.retryLoadMore, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
