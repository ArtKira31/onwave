import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/l10n/app_localizations.dart';

import 'auth/providers/auth_provider.dart';
import 'city/providers/city_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.read(cityProvider.notifier).selectCity('tbilisi'),
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
