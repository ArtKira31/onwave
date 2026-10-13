import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/api/clients/events_client.dart';
import 'package:mobile/api/models/event_card.dart';
import 'package:mobile/api/models/preset.dart';
import 'package:mobile/core/network/api_providers.dart';
import 'package:mobile/features/feed/domain/feed_models.dart';

abstract interface class EventsRepository {
  /// `GET /events`. [city] — slug или id города (так в контракте).
  /// [cursor] == null — первая страница; курсор непрозрачный.
  Future<EventsPage> fetchPage({required String city, required FeedFilter filter, String? cursor, int limit = 20});
}

/// Заглушка по форме контракта `EventCardPage` для ручной проверки ленты без
/// бэкенда: 120 событий. Режимы включаются через `--dart-define=FAKE_MODE=...`
/// (см. ниже [eventsRepositoryProvider]).
class FakeEventsRepository implements EventsRepository {
  /// Любой запрос падает (проверка ошибки / кэша «Данные устарели»).
  bool failing = false;

  /// Сервер вернул пустую ленту.
  bool empty = false;

  /// Каждая следующая страница повторяет 5 последних событий предыдущей.
  /// Проверка критерия «повторная загрузка не дублирует элементы».
  bool overlap = false;

  static const _total = 120;
  static const _categories = ['concerts', 'theatre', 'exhibitions', 'sport'];
  static const _venues = ['Тбилисский концертный зал', 'Fabrika', 'Парк Мтацминда', 'Дом омладине', 'Kombank дворана'];

  @override
  Future<EventsPage> fetchPage({required String city, required FeedFilter filter, String? cursor, int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (failing) throw Exception('network');
    if (empty) return const EventsPage(items: []);

    final now = DateTime.now();
    final anchor = DateTime(now.year, now.month, now.day); // стабильно в течение дня
    final requested = cursor == null ? 0 : int.parse(cursor);
    final start = (overlap && requested > 0) ? math.max(0, requested - 5) : requested;
    final end = math.min(requested + limit, _total);

    final items = [
      for (var i = start; i < end; i++)
        FeedEvent(
          id: 'evt_$i',
          title: 'Событие №${i + 1}',
          startsAt: anchor.add(Duration(hours: 18 + i * 7)),
          sessionCount: i % 3 == 0 ? 3 : 1,
          // Каждая пятая — без обложки (cover.thumb == null в контракте).
          coverThumbUrl: i % 5 == 0 ? null : 'https://picsum.photos/seed/onwave-$i/320/240',
          categorySlug: _categories[i % _categories.length],
          venueName: _venues[i % _venues.length],
        ),
    ].where((e) => filter.categories.isEmpty || filter.categories.contains(e.categorySlug));

    return EventsPage(items: items.toList(), nextCursor: end >= _total ? null : '$end');
  }
}

/// Реальная реализация поверх сгенерированного клиента (ONW-42).
/// Единственное место, которое знает про DTO из lib/api: дальше по приложению
/// ходят только доменные модели.
class ApiEventsRepository implements EventsRepository {
  final EventsClient _client;
  ApiEventsRepository(this._client);

  @override
  Future<EventsPage> fetchPage({required String city, required FeedFilter filter, String? cursor, int limit = 20}) async {
    final page = await _client.listEvents(
      city: city,
      limit: limit,
      cursor: cursor,
      category: filter.categories.isEmpty ? null : filter.categories,
      preset: _preset(filter.preset),
      query: (filter.query == null || filter.query!.isEmpty) ? null : filter.query,
    );
    return EventsPage(items: page.items.map(_toFeedEvent).toList(), nextCursor: page.nextCursor);
  }

  static Preset? _preset(String? value) {
    if (value == null) return null;
    final preset = Preset.fromJson(value);
    return preset == Preset.$unknown ? null : preset;
  }

  static FeedEvent _toFeedEvent(EventCard c) => FeedEvent(
    id: c.id,
    title: c.title,
    startsAt: c.startsAt?.toLocal(), // в API UTC
    sessionCount: c.sessionCount ?? 1,
    coverThumbUrl: c.cover?.thumb,
    categorySlug: c.categorySlug,
    venueName: c.venueName,
    isFavorite: c.isFavorite ?? false,
  );
}

/// `--dart-define=USE_FAKE_API=true` — работать на заглушке, бэкенд не нужен.
/// Дополнительно `--dart-define=FAKE_MODE=<режим>`:
///   empty   — пустая лента;
///   error   — все запросы падают;
///   overlap — страницы пересекаются (проверка отсутствия дублей).
const _useFakeApi = bool.fromEnvironment('USE_FAKE_API');
const _fakeMode = String.fromEnvironment('FAKE_MODE');

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => _useFakeApi
      ? (FakeEventsRepository()
          ..empty = _fakeMode == 'empty'
          ..failing = _fakeMode == 'error'
          ..overlap = _fakeMode == 'overlap')
      : ApiEventsRepository(ref.watch(restClientProvider).events),
);
