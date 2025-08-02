import 'package:equatable/equatable.dart';
import 'package:watertracker/core/models/hydration_data.dart';

/// Model representing daily hydration progress tracking
class HydrationProgress extends Equatable {

  /// Create from current hydration data
  factory HydrationProgress.fromEntries({
    required List<HydrationData> todaysEntries,
    required int dailyGoal,
    DateTime? nextReminderTime,
  }) {
    final currentIntake = todaysEntries.totalWaterIntake;

    return HydrationProgress(
      currentIntake: currentIntake,
      dailyGoal: dailyGoal,
      todaysEntries: todaysEntries,
      nextReminderTime: nextReminderTime,
    );
  }
  const HydrationProgress({
    required this.currentIntake,
    required this.dailyGoal,
    required this.todaysEntries,
    this.nextReminderTime,
  });

  /// Current water intake for the day in milliliters
  final int currentIntake;

  /// Daily hydration goal in milliliters
  final int dailyGoal;

  /// List of all hydration entries for today
  final List<HydrationData> todaysEntries;

  /// Next scheduled reminder time (optional)
  final DateTime? nextReminderTime;

  /// Calculate progress percentage (0.0 to 1.0)
  double get percentage =>
      dailyGoal > 0 ? (currentIntake / dailyGoal).clamp(0.0, 1.0) : 0.0;

  /// Calculate remaining intake needed to reach goal
  int get remainingIntake => (dailyGoal - currentIntake).clamp(0, dailyGoal);

  /// Check if daily goal has been reached
  bool get isGoalReached => currentIntake >= dailyGoal;

  /// Get formatted progress text (e.g., "1.75 L drank so far")
  String get progressText {
    final liters = (currentIntake / 1000).toStringAsFixed(2);
    return '$liters L drank so far';
  }

  /// Get formatted goal text (e.g., "from a total of 3 L")
  String get goalText {
    final goalLiters = (dailyGoal / 1000).toStringAsFixed(1);
    return 'from a total of $goalLiters L';
  }

  /// Get formatted remaining text with reminder time
  String get remainingText {
    if (remainingIntake <= 0) {
      return 'Goal achieved!';
    }

    final remainingMl = remainingIntake;
    if (nextReminderTime != null) {
      final period = nextReminderTime!.hour >= 12 ? 'PM' : 'AM';
      final displayHour =
          nextReminderTime!.hour > 12
              ? nextReminderTime!.hour - 12
              : (nextReminderTime!.hour == 0 ? 12 : nextReminderTime!.hour);
      final displayTime =
          '$displayHour:${nextReminderTime!.minute.toString().padLeft(2, '0')} $period';
      return '$remainingMl ml left before $displayTime';
    }

    return '$remainingMl ml remaining';
  }

  /// Create a copy with updated fields
  HydrationProgress copyWith({
    int? currentIntake,
    int? dailyGoal,
    List<HydrationData>? todaysEntries,
    DateTime? nextReminderTime,
  }) {
    return HydrationProgress(
      currentIntake: currentIntake ?? this.currentIntake,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      todaysEntries: todaysEntries ?? this.todaysEntries,
      nextReminderTime: nextReminderTime ?? this.nextReminderTime,
    );
  }

  @override
  List<Object?> get props => [
    currentIntake,
    dailyGoal,
    todaysEntries,
    nextReminderTime,
  ];

  @override
  String toString() {
    return 'HydrationProgress(currentIntake: ${currentIntake}ml, dailyGoal: ${dailyGoal}ml, percentage: ${(percentage * 100).toStringAsFixed(1)}%)';
  }
}
