import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/l10n/app_localizations.dart';

import 'package:mobile/core/navigation/app_router.dart';
import 'auth/providers/auth_provider.dart';
import 'city/providers/city_provider.dart';
import '../core/utils/date_formatter.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.read(cityProvider.notifier).selectCity('Москва'),
          child: Text(l10n.selectCity),
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerWidget {
  final String? from;
  const LoginScreen({this.from, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ref.read(authProvider.notifier).login();
            final target = (from != null && from!.startsWith('/'))
                ? from!
                : '/feed';
            context.go(target);
          },
          child: const Text('Войти в аккаунт'),
        ),
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedTitle)),
      body: ListView.builder(
        key: const PageStorageKey(
          'feed_list_scroll',
        ), // Сохраняет позицию скролла
        itemCount: 50,
        itemBuilder: (context, index) {
          // Симулируем дату события (каждое следующее событие на 1 день дальше в будущем)
          final eventDate = DateTime.now().add(Duration(days: index + 1));

          return ListTile(
            title: Text('${l10n.feedTitle} #$index'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Плюрализация дней по ICU (1 день, 2 дня, 5 дней)
                Text(l10n.daysRemaining(index + 1)),
                // 2. Форматирование даты через intl под текущий язык смартфона
                Text(
                  AppDateFormatter.formatEventDate(eventDate, currentLocale),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            onTap: () => EventDetailRoute(id: '$index').go(context),
          );
        },
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  final String id;
  const EventDetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Событие #$id')),
      body: Center(child: Text('Детальная информация о событии $id')),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Избранное')));
}

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Создание события (Защищенный экран)')),
  );
}

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Мои события (Защищенный экран)')),
  );
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          child: const Text('Выйти из аккаунта'),
        ),
      ),
    );
  }
}
