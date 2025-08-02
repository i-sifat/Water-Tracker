import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';

/// Main hydration page widget that combines all hydration tracking components
/// with header, progress display, drink selection, and quick add buttons
class MainHydrationPage extends StatefulWidget {
  const MainHydrationPage({
    super.key,
    this.currentPage = 1,
    this.totalPages = 3,
  });

  /// Current page index for page indicator (0-based)
  final int currentPage;

  /// Total number of pages for page indicator
  final int totalPages;

  @override
  State<MainHydrationPage> createState() => _MainHydrationPageState();
}

class _MainHydrationPageState extends State<MainHydrationPage> {
  DrinkType _selectedDrinkType = DrinkType.water;
  late String _currentTime;
  late String _nextReminderTime;
  late String _endTime;

  @override
  void initState() {
    super.initState();
    _updateTimeRangeIndicators();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, hydrationProvider, child) {
        return Semantics(
          label: 'Main hydration tracking page',
          hint:
              '${AccessibilityUtils.swipeUpHint}. ${AccessibilityUtils.swipeDownHint}',
          child: Container(
            decoration: _buildGradientBackground(),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with navigation and time indicators
                  _buildHeader(),

                  // Main content area
                  Expanded(child: _buildMainContent(hydrationProvider)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build main content with loading states
  /// Performance optimization: Separate loading states for better UX
  Widget _buildMainContent(HydrationProvider hydrationProvider) {
    if (hydrationProvider.isLoading && !hydrationProvider.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading your hydration data...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Performance optimization: RepaintBoundary around circular progress
          RepaintBoundary(
            child: _buildCircularProgressSection(hydrationProvider),
          ),

          const SizedBox(height: 32),

          // Performance optimization: RepaintBoundary around drink selector
          RepaintBoundary(child: _buildDrinkTypeSelector()),

          const SizedBox(height: 24),

          // Performance optimization: RepaintBoundary around button grid
          RepaintBoundary(child: _buildQuickAddButtonGrid()),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Build gradient background matching design mockup
  BoxDecoration _buildGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gradientTop, // Top gradient color - matches design mockup
          AppColors
              .gradientBottom, // Bottom gradient color - matches design mockup
        ],
        stops: [0.0, 1.0],
      ),
    );
  }

  /// Build header with "Today" title and navigation icons
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top row with navigation icons and title
          Row(
            children: [
              // Hamburger menu icon
              AccessibilityUtils.ensureMinTouchTarget(
                onTap: _onMenuTapped,
                semanticLabel: AccessibilityUtils.navigationMenuLabel,
                semanticHint: 'Double tap to open navigation menu',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
              ),

              // Performance optimization: const widget for Today title
              Expanded(
                child: AccessibilityUtils.createAccessibleText(
                  text: 'Today',
                  style: AppTypography.hydrationTitle,
                  textAlign: TextAlign.center,
                  semanticLabel: "Today's hydration tracking page",
                ),
              ),

              // Profile/settings icon
              AccessibilityUtils.ensureMinTouchTarget(
                onTap: _onProfileTapped,
                semanticLabel: AccessibilityUtils.profileButtonLabel,
                semanticHint: 'Double tap to open profile and settings',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Time range indicators
          _buildTimeRangeIndicators(),
        ],
      ),
    );
  }

  /// Build time range indicators with dynamic updates
  Widget _buildTimeRangeIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeIndicator(_currentTime),
        const SizedBox(width: 16),
        _buildTimeIndicator(_nextReminderTime),
        const SizedBox(width: 16),
        _buildTimeIndicator(_endTime),
      ],
    );
  }

  /// Build individual time indicator
  Widget _buildTimeIndicator(String text) {
    return Semantics(
      label: 'Time indicator: $text',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: AccessibilityUtils.createAccessibleText(
          text: text,
          style: AppTypography.timeIndicatorText,
        ),
      ),
    );
  }

  /// Build circular progress section with current hydration data
  Widget _buildCircularProgressSection(HydrationProvider provider) {
    // Create HydrationProgress from provider data
    final progress = HydrationProgress.fromEntries(
      todaysEntries: provider.todaysEntries,
      dailyGoal: provider.dailyGoal,
      nextReminderTime: _getNextReminderTime(),
    );

    return CircularProgressSection(
      progress: progress,
      currentPage: widget.currentPage,
      totalPages: widget.totalPages,
    );
  }

  /// Build drink type selector
  Widget _buildDrinkTypeSelector() {
    return DrinkTypeSelector(
      selectedType: _selectedDrinkType,
      onTypeChanged: (DrinkType type) {
        setState(() {
          _selectedDrinkType = type;
        });
      },
    );
  }

  /// Build quick add button grid
  Widget _buildQuickAddButtonGrid() {
    return QuickAddButtonGrid(
      selectedDrinkType: _selectedDrinkType,
      onAmountAdded: () {
        // Optional callback for when amount is added
        // Could trigger animations or other UI updates
      },
    );
  }

  /// Calculate next reminder time (simplified implementation)
  DateTime _getNextReminderTime() {
    final now = DateTime.now();
    // Calculate next reminder time (every 2 hours during day)
    final nextHour = ((now.hour ~/ 2) + 1) * 2;

    if (nextHour < 22) {
      // Stop reminders after 10 PM
      return DateTime(now.year, now.month, now.day, nextHour);
    } else {
      // Next day 8 AM
      return DateTime(now.year, now.month, now.day + 1, 8);
    }
  }

  /// Update time range indicators with current time data
  void _updateTimeRangeIndicators() {
    final now = DateTime.now();

    // Format current time (start of day)
    final startTime = DateTime(now.year, now.month, now.day, 7);
    _currentTime = _formatTime(startTime);

    // Calculate next reminder time
    final nextReminder = _getNextReminderTime();
    final timeDiff = nextReminder.difference(now);
    if (timeDiff.inMinutes < 60) {
      _nextReminderTime = '${timeDiff.inMinutes}min';
    } else {
      _nextReminderTime = _formatTime(nextReminder);
    }

    // End time (11:00 PM)
    final endTime = DateTime(now.year, now.month, now.day, 23);
    _endTime = _formatTime(endTime);
  }

  /// Format time to display format (e.g., "07:00 AM")
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Handle hamburger menu tap - opens navigation drawer
  void _onMenuTapped() {
    try {
      // Try to open drawer if available
      Scaffold.of(context).openDrawer();
    } catch (e) {
      // If no drawer available, show a menu modal
      _showNavigationMenu();
    }
  }

  /// Show navigation menu modal when drawer is not available
  void _showNavigationMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Menu items
              ListTile(
                leading: const Icon(Icons.home, color: Color(0xFF6B73FF)),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF6B73FF)),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToSettings();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF6B73FF)),
                title: const Text('History'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to history - would need to be implemented
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('History feature coming soon'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Color(0xFF6B73FF)),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  _showHelpDialog();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Handle profile icon tap - navigates to settings/profile
  void _onProfileTapped() {
    _navigateToSettings();
  }

  /// Navigate to settings screen
  void _navigateToSettings() {
    Navigator.of(context).pushNamed(SettingsScreen.routeName);
  }

  /// Show help dialog
  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Text(
            'Welcome to Water Tracker!\n\n'
            '• Swipe up to view your hydration statistics\n'
            '• Swipe down to see your goal breakdown\n'
            '• Tap the quick add buttons to log water intake\n'
            '• Change drink types to track different beverages\n\n'
            'For more help, visit the Settings page.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
