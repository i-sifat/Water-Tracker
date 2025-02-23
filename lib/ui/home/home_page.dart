import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:watertracker/ui/home/bottom_nav_bar.dart';
import 'package:watertracker/ui/hydration_pool/hydration_pool_page.dart';
import 'package:watertracker/ui/hydration_progress/hydration_progress_page.dart';
import 'package:watertracker/ui/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [
    const HydrationPoolPage(),
    const HydrationProgressPage(),
    const SettingsPage(),
  ];

  int _currentPage = 0;

  void _changePage(int index) {
    if (index == _currentPage) return;
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageTransitionSwitcher(
            transitionBuilder: (
              child,
              primaryAnimation,
              secondaryAnimation,
            ) {
              return FadeThroughTransition(
                fillColor: Theme.of(context).colorScheme.background,
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: _pages[_currentPage],
          ),
          BottomNavBar(
            currentPage: _currentPage,
            onChanged: _changePage,
          ),
        ],
      ),
    );
  }
}
