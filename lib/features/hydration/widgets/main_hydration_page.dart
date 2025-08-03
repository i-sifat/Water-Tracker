import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/design_system/design_system.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/core/services/notification_service.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
import 'package:watertracker/core/widgets/animations/smooth_text_transition.dart';

import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';

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
  DateTime _selectedDate = DateTime.now();

  final GlobalKey<_CircularProgressSectionState> _progressSectionKey =
      GlobalKey<_CircularProgressSectionState>();

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
          child: ColoredBox(
            color: AppColors.surface,
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.waterFull),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
            Text(
              'Loading your hydration data...',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 4)),

        // Performance optimization: RepaintBoundary around circular progress
        RepaintBoundary(
          child: _buildCircularProgressSection(hydrationProvider),
        ),

        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

        // Performance optimization: RepaintBoundary around drink selector
        RepaintBoundary(child: _buildDrinkTypeSelector()),

        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

        // Performance optimization: RepaintBoundary around button grid
        RepaintBoundary(child: _buildQuickAddButtonGrid()),

        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 20)),
      ],
    );
  }

  /// Build header with "Today" title
  Widget _buildHeader() {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        horizontal: 20,
        vertical: 16,
      ),
      child: Column(
        children: [
          // Tappable "Today" title that opens calendar
          AccessibilityUtils.ensureMinTouchTarget(
            onTap: _onTodayTapped,
            semanticLabel: 'Select date',
            semanticHint: 'Double tap to select a different date',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SmoothTextTransition(
                  text: _getDateDisplayText(),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadline,
                  ),
                  semanticLabel:
                      'Hydration tracking page for ${_getDateDisplayText()}',
                  duration: const Duration(milliseconds: 400),
                  slideDistance: 20.0,
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(context, 8),
                ),
                Container(
                  padding: ResponsiveHelper.getResponsivePadding(
                    context,
                    all: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.waterFull.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveBorderRadius(context, 4),
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.waterFull,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

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
        _buildTimeIndicator(_currentTime, 'Wake up time', _onWakeUpTimeTapped),
        SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 8)),
        _buildTimeIndicator(
          _nextReminderTime,
          'Reminder interval',
          _onReminderIntervalTapped,
        ),
        SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 8)),
        _buildTimeIndicator(_endTime, 'Sleep time', _onSleepTimeTapped),
      ],
    );
  }

  /// Build individual time indicator
  Widget _buildTimeIndicator(String text, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: 'Edit $label',
        hint: 'Double tap to edit $label',
        button: true,
        child: Container(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveBorderRadius(context, 12),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: ResponsiveHelper.getResponsiveWidth(context, 4),
                offset: Offset(
                  0,
                  ResponsiveHelper.getResponsiveHeight(context, 2),
                ),
              ),
            ],
          ),
          child: SmoothTextTransition(
            text: text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textHeadline,
            ),
            duration: const Duration(milliseconds: 350),
            slideDistance: 15.0,
          ),
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
      key: _progressSectionKey,
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
        // Trigger border pulse animation on circular progress
        _progressSectionKey.currentState?.triggerWaterAddedAnimation();
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

  /// Handle wake up time selection
  Future<void> _onWakeUpTimeTapped() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteTextColor: AppColors.textHeadline,
              hourMinuteColor: AppColors.waterFull.withValues(alpha: 0.1),
              dialHandColor: AppColors.waterFull,
              dialBackgroundColor: AppColors.waterFull.withValues(alpha: 0.1),
              dialTextColor: AppColors.textHeadline,
              entryModeIconColor: AppColors.textHeadline,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _currentTime = _formatTime(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            selectedTime.hour,
            selectedTime.minute,
          ),
        );
      });

      // Schedule notifications with new wake up time
      try {
        final notificationService = NotificationService();
        await notificationService.updateNotificationSettings(
          startHour: selectedTime.hour,
        );
        await notificationService.scheduleSmartReminders();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wake up time set to $_currentTime'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error scheduling wake up reminders: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to set wake up time. Please try again.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// Handle reminder interval selection
  Future<void> _onReminderIntervalTapped() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 2, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteTextColor: AppColors.textHeadline,
              hourMinuteColor: AppColors.waterFull.withValues(alpha: 0.1),
              dialHandColor: AppColors.waterFull,
              dialBackgroundColor: AppColors.waterFull.withValues(alpha: 0.1),
              dialTextColor: AppColors.textHeadline,
              entryModeIconColor: AppColors.textHeadline,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final hours = selectedTime.hour;
      final minutes = selectedTime.minute;
      final totalMinutes = hours * 60 + minutes;

      setState(() {
        if (totalMinutes < 60) {
          _nextReminderTime = '${totalMinutes}min';
        } else {
          _nextReminderTime = '${hours}h ${minutes}min';
        }
      });

      // Schedule notifications with the new interval
      try {
        final notificationService = NotificationService();
        await notificationService.updateNotificationSettings(
          interval: totalMinutes ~/ 60, // Convert to hours
        );
        await notificationService.scheduleSmartReminders();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminders set for every $_nextReminderTime'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error scheduling reminders: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to set reminders. Please try again.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// Handle sleep time selection
  Future<void> _onSleepTimeTapped() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteTextColor: AppColors.textHeadline,
              hourMinuteColor: AppColors.waterFull.withValues(alpha: 0.1),
              dialHandColor: AppColors.waterFull,
              dialBackgroundColor: AppColors.waterFull.withValues(alpha: 0.1),
              dialTextColor: AppColors.textHeadline,
              entryModeIconColor: AppColors.textHeadline,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _endTime = _formatTime(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            selectedTime.hour,
            selectedTime.minute,
          ),
        );
      });

      // Schedule notifications with new sleep time
      try {
        final notificationService = NotificationService();
        await notificationService.updateNotificationSettings(
          endHour: selectedTime.hour,
        );
        await notificationService.scheduleSmartReminders();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sleep time set to $_endTime'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error scheduling sleep time reminders: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to set sleep time. Please try again.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// Get display text for selected date
  String _getDateDisplayText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      // Format as "Jan 15" or similar
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[_selectedDate.month - 1]} ${_selectedDate.day}';
    }
  }

  /// Handle today text tap to open calendar
  Future<void> _onTodayTapped() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.waterFull,
              onSurface: AppColors.textHeadline,
              secondary: AppColors.lightPurple,
              onSecondary: AppColors.textOnSecondary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.waterFull,
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: AppColors.surface,
              headerBackgroundColor: AppColors.waterFull,
              headerForegroundColor: AppColors.textOnPrimary,
              dayStyle: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textHeadline,
              ),
              yearStyle: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textHeadline,
              ),
              headerHelpStyle: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}
