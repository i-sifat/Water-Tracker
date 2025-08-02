import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Utility class for accessibility features and helpers
class AccessibilityUtils {
  /// Minimum touch target size for accessibility (44x44 logical pixels)
  static const double minTouchTargetSize = 44;

  /// Minimum color contrast ratio for WCAG AA compliance
  static const double minContrastRatio = 4.5;

  /// Semantic labels for common UI elements
  static const String progressIndicatorLabel = 'Hydration progress indicator';
  static const String quickAddButtonLabel = 'Quick add hydration button';
  static const String drinkTypeSelectorLabel = 'Select drink type';
  static const String pageIndicatorLabel = 'Page indicator';
  static const String navigationMenuLabel = 'Navigation menu';
  static const String profileButtonLabel = 'Profile and settings';
  static const String swipeUpHint = 'Swipe up to view statistics';
  static const String swipeDownHint = 'Swipe down to view goal breakdown';

  /// Announce progress changes to screen readers
  static void announceProgressChange(
    BuildContext context,
    int currentIntake,
    int dailyGoal,
    double percentage,
  ) {
    final percentageText = '${(percentage * 100).round()}%';
    final intakeText = '${(currentIntake / 1000).toStringAsFixed(1)} liters';
    final goalText = '${(dailyGoal / 1000).toStringAsFixed(1)} liters';

    final announcement =
        'Hydration progress updated. '
        'You have consumed $intakeText out of your $goalText daily goal. '
        'That is $percentageText complete.';

    _announceToScreenReader(context, announcement);
  }

  /// Announce hydration addition to screen readers
  static void announceHydrationAdded(
    BuildContext context,
    int amount,
    String drinkType,
  ) {
    final amountText = '${amount}ml';
    final announcement =
        'Added $amountText of $drinkType to your hydration log.';

    _announceToScreenReader(context, announcement);
  }

  /// Announce page changes to screen readers
  static void announcePageChange(BuildContext context, String pageName) {
    final announcement = 'Navigated to $pageName page';
    _announceToScreenReader(context, announcement);
  }

  /// Announce streak updates to screen readers
  static void announceStreakUpdate(BuildContext context, int streak) {
    final announcement = 'Current hydration streak: $streak days in a row';
    _announceToScreenReader(context, announcement);
  }

  /// Private method to announce text to screen readers
  static void _announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create semantic label for progress percentage
  static String createProgressLabel(
    double percentage,
    int currentIntake,
    int dailyGoal,
  ) {
    final percentageText = '${(percentage * 100).round()}%';
    final intakeText = '${(currentIntake / 1000).toStringAsFixed(1)} liters';
    final goalText = '${(dailyGoal / 1000).toStringAsFixed(1)} liters';

    return 'Hydration progress: $percentageText complete. '
        'Current intake: $intakeText of $goalText daily goal.';
  }

  /// Create semantic label for quick add buttons
  static String createQuickAddButtonLabel(int amount, String drinkType) {
    return 'Add ${amount}ml of $drinkType to hydration log';
  }

  /// Create semantic label for drink type selector
  static String createDrinkTypeSelectorLabel(
    String drinkType,
    double waterContent,
  ) {
    final waterPercentage = (waterContent * 100).round();
    return 'Currently selected: $drinkType with $waterPercentage% water content. Tap to change drink type.';
  }

  /// Create semantic label for page indicators
  static String createPageIndicatorLabel(
    int currentPage,
    int totalPages,
    List<String> pageNames,
  ) {
    final currentPageName =
        pageNames.length > currentPage
            ? pageNames[currentPage]
            : 'page ${currentPage + 1}';
    return 'Currently on $currentPageName, page ${currentPage + 1} of $totalPages';
  }

  /// Create semantic label for statistics cards
  static String createStatisticsCardLabel(
    String title,
    String value,
    String unit,
  ) {
    return '$title: $value $unit';
  }

  /// Create semantic label for streak indicators
  static String createStreakIndicatorLabel(
    int dayIndex,
    bool isCompleted,
    bool isToday,
  ) {
    final dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final dayName = dayNames[dayIndex];

    if (isToday && isCompleted) {
      return '$dayName: Goal completed today';
    } else if (isToday) {
      return '$dayName: Today, goal in progress';
    } else if (isCompleted) {
      return '$dayName: Goal completed';
    } else {
      return '$dayName: Goal not completed';
    }
  }

  /// Provide haptic feedback for accessibility
  static Future<void> provideAccessibilityFeedback() async {
    await HapticFeedback.lightImpact();
  }

  /// Check if a widget meets minimum touch target size
  static bool meetsMinTouchTarget(double width, double height) {
    return width >= minTouchTargetSize && height >= minTouchTargetSize;
  }

  /// Wrap a widget to ensure minimum touch target size
  static Widget ensureMinTouchTarget({
    required Widget child,
    required VoidCallback? onTap,
    String? semanticLabel,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: minTouchTargetSize,
            minHeight: minTouchTargetSize,
          ),
          child: child,
        ),
      ),
    );
  }

  /// Create accessible button with proper semantics and touch target
  static Widget createAccessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? semanticHint,
    bool enabled = true,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: enabled,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: minTouchTargetSize,
          minHeight: minTouchTargetSize,
        ),
        child: child,
      ),
    );
  }

  /// Create accessible text with proper scaling support
  static Widget createAccessibleText({
    required String text,
    required TextStyle style,
    String? semanticLabel,
    int? maxLines,
    TextAlign? textAlign,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        textScaler: TextScaler.noScaling, // Respect system font scaling
      ),
    );
  }

  /// Page names for semantic announcements
  static const List<String> pageNames = [
    'Statistics',
    'Main hydration',
    'Goal breakdown',
  ];
}
