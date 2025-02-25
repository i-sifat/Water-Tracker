import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watertracker/presentation/widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _routes = {
    '/': 0,
    '/progress': 1,
    '/settings': 2,
  };

  static const _paths = {
    0: '/',
    1: '/progress',
    2: '/settings',
  };

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return _routes[location] ?? 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    final path = _paths[index];
    if (path != null) {
      context.go(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          PageTransitionSwitcher(
            transitionBuilder: (
              child,
              primaryAnimation,
              secondaryAnimation,
            ) =>
                FadeThroughTransition(
              fillColor: colorScheme.surface,
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            ),
            child: widget.child,
          ),
          BottomNavBar(
            currentPage: _getCurrentIndex(context),
            onChanged: (index) => _onDestinationSelected(context, index),
          ),
        ],
      ),
    );
  }
}
