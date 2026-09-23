import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/debug_design_system_screen.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/city/providers/city_provider.dart';
import '../../features/dummy_screens.dart';

import 'scaffold_with_navbar.dart';

part 'app_router.g.dart';

/// Роутер создаётся один раз. Изменения auth/city только заставляют его
/// перепроверить redirect (через refreshListenable), не пересоздавая его.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.listen(cityProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  // Куда вернуться после онбординга (например, ссылка, открывшая приложение).
  String? pendingLocation;

  return GoRouter(
    initialLocation: const FeedRoute().location,
    redirectLimit: 5,
    refreshListenable: refresh,
    redirect: (context, state) {
      final uri = state.uri;
      final loc = state.matchedLocation;
      final hasCity = ref.read(cityProvider) != null;
      final isAuthed = ref.read(authProvider).isAuthenticated;

      final onboarding = const OnboardingRoute().location;

      if (!hasCity) {
        if (loc == onboarding) return null;
        pendingLocation = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
        return onboarding;
      }
      if (loc == onboarding) {
        final target = pendingLocation ?? const FeedRoute().location;
        pendingLocation = null;
        return target;
      }

      final isProtected =
          loc.startsWith(const CreateEventRoute().location) ||
          loc.startsWith(const MyEventsRoute().location);

      if (isProtected && !isAuthed) {
        return LoginRoute(from: loc).location;
      }

      return null;
    },
    routes: $appRoutes,
  );
});

// --- Маршруты вне табов ---
@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  final String? from;
  const LoginRoute({this.from});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      LoginScreen(from: from);
}

// Переносим аннотацию каталога в общий список корневых роутов
@TypedGoRoute<DebugDesignSystemRoute>(path: '/debug/design-system')
class DebugDesignSystemRoute extends GoRouteData with $DebugDesignSystemRoute {
  const DebugDesignSystemRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DebugDesignSystemScreen();
}

// --- Таббар навигация ---
@TypedStatefulShellRoute<AppShellRoute>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<FeedBranch>(
      routes: [
        TypedGoRoute<FeedRoute>(
          path: '/feed',
          routes: [TypedGoRoute<EventDetailRoute>(path: 'event/:id')],
        ),
      ],
    ),
    TypedStatefulShellBranch<FavoritesBranch>(
      routes: [TypedGoRoute<FavoritesRoute>(path: '/favorites')],
    ),
    TypedStatefulShellBranch<CreateBranch>(
      routes: [TypedGoRoute<CreateEventRoute>(path: '/create')],
    ),
    TypedStatefulShellBranch<MyEventsBranch>(
      routes: [TypedGoRoute<MyEventsRoute>(path: '/my-events')],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile')],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
  }
}

class FeedBranch extends StatefulShellBranchData {
  const FeedBranch();
}

class FavoritesBranch extends StatefulShellBranchData {
  const FavoritesBranch();
}

class CreateBranch extends StatefulShellBranchData {
  const CreateBranch();
}

class MyEventsBranch extends StatefulShellBranchData {
  const MyEventsBranch();
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

class FeedRoute extends GoRouteData with $FeedRoute {
  const FeedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FeedScreen();
}

class EventDetailRoute extends GoRouteData with $EventDetailRoute {
  final String id;
  const EventDetailRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EventDetailScreen(id: id);
}

class FavoritesRoute extends GoRouteData with $FavoritesRoute {
  const FavoritesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FavoritesScreen();
}

class CreateEventRoute extends GoRouteData with $CreateEventRoute {
  const CreateEventRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateEventScreen();
}

class MyEventsRoute extends GoRouteData with $MyEventsRoute {
  const MyEventsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MyEventsScreen();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}
