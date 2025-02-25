import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watertracker/presentation/pages/home/home_page.dart';
import 'package:watertracker/presentation/pages/hydration_pool/hydration_pool_page.dart';
import 'package:watertracker/presentation/pages/hydration_progress/hydration_progress_page.dart';
import 'package:watertracker/presentation/pages/settings/settings_page.dart';

/// Router configuration for the app
class AppRouter {
  const AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    errorBuilder: _buildErrorPage,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomePage(child: child),
        routes: _routes,
      ),
    ],
  );

  static Widget _buildErrorPage(BuildContext context, GoRouterState state) => Scaffold(
        body: Center(
          child: Text(
            'Error: ${state.error}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),
      );

  static List<RouteBase> get _routes => [
        GoRoute(
          path: '/',
          name: 'hydration-pool',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HydrationPoolPage(),
          ),
        ),
        GoRoute(
          path: '/progress',
          name: 'hydration-progress',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HydrationProgressPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ];
}