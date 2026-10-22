import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/feed/domain/feed_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedFeed {
  final List<FeedEvent> items;
  final DateTime savedAt;
  const CachedFeed(this.items, this.savedAt);
}

/// Кэш первой страницы ленты (то, что пользователь видит при запуске).
/// Ключ зависит от города и фильтра, чтобы не показать чужие события.
class FeedCache {
  String _key(String city, FeedFilter f) =>
      'feed_cache_v2/$city/${f.cacheKey}';

  Future<CachedFeed?> read(String city, FeedFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(city, filter));
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CachedFeed(
        (json['items'] as List)
            .map((e) => FeedEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        DateTime.parse(json['savedAt'] as String),
      );
    } catch (_) {
      return null; // битый кэш не должен ломать ленту
    }
  }

  Future<void> write(String city, FeedFilter filter, List<FeedEvent> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key(city, filter),
        jsonEncode({
          'savedAt': DateTime.now().toIso8601String(),
          'items': items.map((e) => e.toJson()).toList(),
        }),
      );
    } catch (_) {}
  }
}

final feedCacheProvider = Provider<FeedCache>((ref) => FeedCache());
