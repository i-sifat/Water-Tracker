import 'package:flutter/services.dart';

/// Utility class for providing consistent haptic feedback throughout the app
class HapticFeedbackUtils {
  HapticFeedbackUtils._();

  /// Light impact feedback for subtle interactions
  /// Use for: button taps, selection changes, minor interactions
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact feedback for standard interactions
  /// Use for: adding water, completing actions, confirmations
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback for important interactions
  /// Use for: errors, warnings, major state changes
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback for picker interactions
  /// Use for: scrolling through options, slider changes
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibration pattern for notifications
  /// Use for: reminders, alerts, notifications
  static Future<void> notification() async {
    await HapticFeedback.vibrate();
  }

  /// Success feedback pattern
  /// Use for: goal completion, successful actions
  static Future<void> success() async {
    await medium();
    await Future.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Error feedback pattern
  /// Use for: validation errors, failed actions
  static Future<void> error() async {
    await heavy();
    await Future.delayed(const Duration(milliseconds: 100));
    await heavy();
  }

  /// Warning feedback pattern
  /// Use for: warnings, cautions
  static Future<void> warning() async {
    await medium();
    await Future.delayed(const Duration(milliseconds: 150));
    await medium();
  }

  /// Button press feedback
  /// Use for: all button interactions
  static Future<void> buttonPress() async {
    await light();
  }

  /// Navigation feedback
  /// Use for: page transitions, navigation actions
  static Future<void> navigation() async {
    await selection();
  }

  /// Water addition feedback
  /// Use for: adding water to daily intake
  static Future<void> waterAdded() async {
    await medium();
  }

  /// Goal achievement feedback
  /// Use for: reaching daily hydration goal
  static Future<void> goalAchieved() async {
    await success();
    await Future.delayed(const Duration(milliseconds: 200));
    await light();
  }

  /// Reminder feedback
  /// Use for: hydration reminders
  static Future<void> reminder() async {
    await notification();
  }

  /// Settings change feedback
  /// Use for: changing app settings
  static Future<void> settingsChange() async {
    await selection();
  }

  /// Onboarding step feedback
  /// Use for: completing onboarding steps
  static Future<void> onboardingStep() async {
    await light();
  }

  /// Data sync feedback
  /// Use for: syncing data, saving progress
  static Future<void> dataSync() async {
    await light();
  }

  /// Achievement unlock feedback
  /// Use for: unlocking achievements or milestones
  static Future<void> achievementUnlock() async {
    await heavy();
    await Future.delayed(const Duration(milliseconds: 100));
    await medium();
    await Future.delayed(const Duration(milliseconds: 100));
    await light();
  }

  /// Contextual feedback based on interaction type
  static Future<void> contextual(HapticContext context) async {
    switch (context) {
      case HapticContext.buttonPress:
        await buttonPress();
        break;
      case HapticContext.navigation:
        await navigation();
        break;
      case HapticContext.waterAdded:
        await waterAdded();
        break;
      case HapticContext.goalAchieved:
        await goalAchieved();
        break;
      case HapticContext.reminder:
        await reminder();
        break;
      case HapticContext.settingsChange:
        await settingsChange();
        break;
      case HapticContext.onboardingStep:
        await onboardingStep();
        break;
      case HapticContext.dataSync:
        await dataSync();
        break;
      case HapticContext.achievementUnlock:
        await achievementUnlock();
        break;
      case HapticContext.success:
        await success();
        break;
      case HapticContext.error:
        await error();
        break;
      case HapticContext.warning:
        await warning();
        break;
    }
  }
}

/// Enum for different haptic feedback contexts
enum HapticContext {
  buttonPress,
  navigation,
  waterAdded,
  goalAchieved,
  reminder,
  settingsChange,
  onboardingStep,
  dataSync,
  achievementUnlock,
  success,
  error,
  warning,
}
