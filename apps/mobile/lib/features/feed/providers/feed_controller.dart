import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/connectivity_provider.dart';
import 'package:mobile/features/city/providers/city_provider.dart';
import 'package:mobile/features/feed/data/events_repository.dart';
import 'package:mobile/features/feed/data/feed_cache.dart';
import 'package:mobile/features/feed/domain/feed_models.dart';

const kFeedPageSize = 20;

/// За сколько элементов до конца списка начинаем грузить следующую страницу.
const kFeedPrefetchDistance = 6;

final feedFilterProvider = StateProvider<FeedFilter>((_) => const FeedFilter());

enum FeedStatus { loading, data, empty, error }

class FeedState {
  final FeedStatus status;
  final List<FeedEvent> items;
  final String? nextCursor;
  final bool isLoadingMore;
  final bool loadMoreFailed;
  final bool isRefreshing;

  /// Не null — показан кэш, а не свежие данные (время сохранения кэша).
  final DateTime? staleSince;

  const FeedState({
    this.status = FeedStatus.loading,
    this.items = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.isRefreshing = false,
    this.staleSince,
  });

  bool get hasMore => nextCursor != null;
  bool get isStale => staleSince != null;

  static const _keep = Object();

  FeedState copyWith({
    FeedStatus? status,
    List<FeedEvent>? items,
    Object? nextCursor = _keep,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    bool? isRefreshing,
    Object? staleSince = _keep,
  }) => FeedState(
    status: status ?? this.status,
    items: items ?? this.items,
    nextCursor: identical(nextCursor, _keep) ? this.nextCursor : nextCursor as String?,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    staleSince: identical(staleSince, _keep) ? this.staleSince : staleSince as DateTime?,
  );
}

class FeedController extends Notifier<FeedState> {
  /// «Поколение» ленты. Любой сброс (refresh, смена города/фильтра, dispose)
  /// увеличивает его, а ответы с устаревшим поколением молча игнорируются.
  /// Это защищает от гонок: ответ старой подгрузки не попадёт в обновлённую ленту.
  int _gen = 0;
  String? _city;
  late FeedFilter _filter;

  @override
  FeedState build() {
    _city = ref.watch(cityProvider);
    _filter = ref.watch(feedFilterProvider);
    final gen = ++_gen;
    ref.onDispose(() => _gen++);

    // Сеть вернулась: если висит ошибка или показан кэш — обновляемся сами.
    ref.listen<bool>(isOnlineProvider, (prev, online) {
      if (prev == false && online) _onBackOnline();
    });

    if (_city != null) Future.microtask(() => _loadFirst(gen));
    return const FeedState();
  }

  /// Причину сбоя показываем только в отладочной консоли, пользователю — общий экран ошибки.
  void _log(String where, Object error) {
    if (kDebugMode) debugPrint('[feed] ошибка ($where): $error');
  }

  Future<EventsPage> _fetch(String? cursor) => ref
      .read(eventsRepositoryProvider)
      .fetchPage(city: _city!, filter: _filter, cursor: cursor, limit: kFeedPageSize)
      .timeout(const Duration(seconds: 15));

  Future<void> _loadFirst(int gen) async {
    try {
      final page = await _fetch(null);
      if (gen != _gen) return;
      _applyFirstPage(page);
    } catch (e) {
      _log('первая страница', e);
      if (gen != _gen) return;
      final cached = await ref.read(feedCacheProvider).read(_city!, _filter);
      if (gen != _gen) return;
      if (cached != null && cached.items.isNotEmpty) {
        state = FeedState(
          status: FeedStatus.data,
          items: cached.items,
          staleSince: cached.savedAt, // nextCursor=null: до обновления не пагинируем
        );
      } else {
        state = const FeedState(status: FeedStatus.error);
      }
    }
  }

  void _applyFirstPage(EventsPage page) {
    final items = _dedupe(const [], page.items);
    state = FeedState(
      status: items.isEmpty ? FeedStatus.empty : FeedStatus.data,
      items: items,
      nextCursor: items.isEmpty ? null : page.nextCursor,
    );
    if (items.isNotEmpty) {
      unawaited(ref.read(feedCacheProvider).write(_city!, _filter, items));
    }
  }

  /// Оставляет только те элементы, id которых ещё нет в [existing].
  List<FeedEvent> _dedupe(List<FeedEvent> existing, List<FeedEvent> incoming) {
    final seen = {for (final e in existing) e.id};
    return [
      for (final e in incoming)
        if (seen.add(e.id)) e,
    ];
  }

  /// Подгрузка следующей страницы. Безопасно вызывать сколько угодно раз.
  Future<void> loadMore() async {
    final s = state;
    if (s.status != FeedStatus.data || !s.hasMore || s.isLoadingMore || s.isRefreshing || s.loadMoreFailed) {
      return;
    }
    final gen = _gen;
    final cursor = s.nextCursor;
    state = s.copyWith(isLoadingMore: true);
    try {
      final page = await _fetch(cursor);
      if (gen != _gen) return;
      final fresh = _dedupe(state.items, page.items);
      state = state.copyWith(
        items: [...state.items, ...fresh],
        // Если сервер вернул тот же курсор — считаем, что это конец (защита от цикла).
        nextCursor: page.nextCursor == cursor ? null : page.nextCursor,
        isLoadingMore: false,
      );
    } catch (e) {
      _log('подгрузка страницы', e);
      if (gen != _gen) return;
      state = state.copyWith(isLoadingMore: false, loadMoreFailed: true);
    }
  }

  void retryLoadMore() {
    state = state.copyWith(loadMoreFailed: false);
    loadMore();
  }

  /// Pull-to-refresh: сбрасывает курсор и грузит первую страницу заново.
  /// Возвращает false, если обновить не удалось.
  Future<bool> refresh() async {
    if (_city == null || state.isRefreshing) return true;
    final gen = ++_gen; // инвалидируем любые запросы «в полёте»
    state = state.copyWith(isRefreshing: true, isLoadingMore: false, loadMoreFailed: false);
    try {
      final page = await _fetch(null);
      if (gen != _gen) return true;
      _applyFirstPage(page);
      return true;
    } catch (e) {
      _log('обновление', e);
      if (gen != _gen) return true;
      state = state.copyWith(isRefreshing: false, status: state.items.isEmpty ? FeedStatus.error : state.status);
      return false;
    }
  }

  /// Кнопка «Повторить» на экране ошибки: возвращаемся к скелетонам.
  void retry() {
    if (_city == null) return;
    final gen = ++_gen;
    state = const FeedState();
    unawaited(_loadFirst(gen));
  }

  void _onBackOnline() {
    if (state.status == FeedStatus.error) {
      retry();
    } else if (state.isStale) {
      unawaited(refresh());
    }
  }
}

final feedControllerProvider = NotifierProvider<FeedController, FeedState>(FeedController.new);
