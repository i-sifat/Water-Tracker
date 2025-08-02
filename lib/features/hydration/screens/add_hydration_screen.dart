import 'package:flutter/material.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';
import 'package:watertracker/features/hydration/widgets/history_page.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

/// Main screen widget that appears when users want to add hydration
/// Now integrates SwipeablePageView with MainHydrationPage, StatisticsPage, and GoalBreakdownPage
/// Includes proper vertical swipe navigation within the add hydration section
class AddHydrationScreen extends StatefulWidget {
  const AddHydrationScreen({super.key});

  @override
  State<AddHydrationScreen> createState() => _AddHydrationScreenState();
}

class _AddHydrationScreenState extends State<AddHydrationScreen> {
  late PageController _pageController;
  int _currentPage = 1; // 0: Statistics (up), 1: Main (center), 2: Goal Breakdown (down)

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SwipeablePageView(
        pages: [
          // History page (swipe up from main)
          const HistoryPage(),

          // Main hydration page (center/default)
          MainHydrationPage(currentPage: _currentPage),

          // Goal breakdown page (swipe down from main)
          const GoalBreakdownPage(),
        ],
        initialPage: _currentPage,
        controller: _pageController,
        onPageChanged: _onPageChanged,
      ),
    );
  }
}
