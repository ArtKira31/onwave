import 'package:flutter/foundation.dart';

/// Карточка события в ленте. Соответствует схеме `EventCard` из OpenAPI
/// (packages/api-contract), но это доменная модель UI и кэша: из сгенерированного
/// DTO она собирается в репозитории (см. events_repository.dart).
@immutable
class FeedEvent {
  final String id;
  final String title;

  /// Ближайший будущий сеанс (UTC в API, здесь уже локальное время).
  /// В контракте nullable — карточка обязана переживать null.
  final DateTime? startsAt;

  /// Больше одного — показываем «и ещё N дат».
  final int sessionCount;

  /// `cover.thumb` (320×240). Null, пока воркер ресайза не отработал.
  final String? coverThumbUrl;

  final String? categorySlug;
  final String? venueName;
  final bool isFavorite;

  const FeedEvent({
    required this.id,
    required this.title,
    this.startsAt,
    this.sessionCount = 1,
    this.coverThumbUrl,
    this.categorySlug,
    this.venueName,
    this.isFavorite = false,
  });

  /// Формат — наш собственный, только для локального кэша.
  factory FeedEvent.fromJson(Map<String, dynamic> json) => FeedEvent(
    id: json['id'] as String,
    title: json['title'] as String,
    startsAt: json['startsAt'] == null
        ? null
        : DateTime.parse(json['startsAt'] as String).toLocal(),
    sessionCount: json['sessionCount'] as int? ?? 1,
    coverThumbUrl: json['coverThumbUrl'] as String?,
    categorySlug: json['categorySlug'] as String?,
    venueName: json['venueName'] as String?,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startsAt': startsAt?.toUtc().toIso8601String(),
    'sessionCount': sessionCount,
    'coverThumbUrl': coverThumbUrl,
    'categorySlug': categorySlug,
    'venueName': venueName,
    'isFavorite': isFavorite,
  };
}

/// Страница ленты. [nextCursor] == null означает «страниц больше нет».
@immutable
class EventsPage {
  final List<FeedEvent> items;
  final String? nextCursor;
  const EventsPage({required this.items, this.nextCursor});
}

/// Параметры `GET /events`, кроме города и пагинации.
@immutable
class FeedFilter {
  /// Slug'и категорий (в API — повторяющийся query-параметр `category`).
  final List<String> categories;

  /// today | tomorrow | weekend | week | month. Взаимоисключим с dateFrom/dateTo.
  final String? preset;

  /// Полнотекстовый поиск, до 200 символов.
  final String? query;

  const FeedFilter({this.categories = const [], this.preset, this.query});

  /// Стабильная строка для ключа кэша.
  String get cacheKey =>
      '${([...categories]..sort()).join(',')}|${preset ?? ''}|${query ?? ''}';

  @override
  bool operator ==(Object other) =>
      other is FeedFilter &&
      listEquals(other.categories, categories) &&
      other.preset == preset &&
      other.query == query;

  @override
  int get hashCode => Object.hash(Object.hashAll(categories), preset, query);
}
