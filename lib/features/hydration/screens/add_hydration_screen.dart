import 'package:flutter/material.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/features/history/history_screen.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

/// Main screen widget that appears when users want to add hydration
/// Now integrates SwipeablePageView with MainHydrationPage, StatisticsPage, and GoalBreakdownPage
/// Includes proper bottom navigation integration with state preservation
class AddHydrationScreen extends StatefulWidget {
  const AddHydrationScreen({super.key});

  @override
  State<AddHydrationScreen> createState() => _AddHydrationScreenState();
}

class _AddHydrationScreenState extends State<AddHydrationScreen> {
  late PageController _pageController;
  int _currentPage = 1; // 0: Statistics (up), 1: Main (center), 2: Goal Breakdown (down)
  int _selectedBottomNavIndex = 1; // Hydration section is active

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handle page changes and update current page index
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// Handle bottom navigation item taps
  void _onBottomNavItemTapped(int index) {
    if (index == _selectedBottomNavIndex) {
      // If tapping the same tab, do nothing or scroll to top
      return;
    }

    setState(() {
      _selectedBottomNavIndex = index;
    });

    // Navigate to other app sections while maintaining page state
    switch (index) {
      case 0:
        // Navigate to Home screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
          ),
        );
        break;
      case 1:
        // Already on hydration screen, do nothing
        break;
      case 2:
        // Navigate to History screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) => const HistoryScreen(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              );
            },
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SwipeablePageView(
        pages: [
          // Statistics page (swipe up from main)
          const StatisticsPage(),

          // Main hydration page (center/default)
          MainHydrationPage(currentPage: _currentPage),

          // Goal breakdown page (swipe down from main)
          const GoalBreakdownPage(),
        ],
        initialPage: _currentPage,
        controller: _pageController,
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedBottomNavIndex,
        onItemTapped: _onBottomNavItemTapped,
      ),
    );
  }
}
