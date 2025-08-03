import 'dart:math';
import 'package:flutter/material.dart';
import 'package:watertracker/core/calculations/adjustment_factors.dart';
import 'package:watertracker/core/calculations/water_goal_calculator.dart';
import 'package:watertracker/core/models/user_profile.dart';

/// Advanced water intake calculator with premium features
///
/// This calculator breaks down the complex calculation logic into modular,
/// testable components using the adjustment factor system.
class AdvancedWaterCalculator {
  /// Calculate advanced water intake using modular adjustment factors
  ///
  /// This method replaces the complex 500+ line calculateAdvancedIntake method
  /// with a clean, modular approach using the adjustment factor system.
  static int calculateAdvancedIntake(
    UserProfile profile, {
    List<EnvironmentalFactor>? environmentalFactors,
    List<LifestyleFactor>? lifestyleFactors,
    List<HealthFactor>? healthFactors,
  }) {
    // Start with basic goal calculation
    int baseIntake = WaterGoalCalculator.calculateComprehensiveGoal(profile);

    // Apply environmental adjustments
    if (environmentalFactors != null && environmentalFactors.isNotEmpty) {
      baseIntake = _applyEnvironmentalFactors(baseIntake, environmentalFactors);
    }

    // Apply lifestyle adjustments
    if (lifestyleFactors != null && lifestyleFactors.isNotEmpty) {
      baseIntake = _applyLifestyleFactors(baseIntake, lifestyleFactors);
    }

    // Apply health adjustments
    if (healthFactors != null && healthFactors.isNotEmpty) {
      baseIntake = _applyHealthFactors(baseIntake, healthFactors);
    }

    // Apply safety bounds
    return _applySafeBounds(baseIntake);
  }

  /// Calculate activity-specific hydration needs
  ///
  /// Calculates additional water needed for specific activities beyond daily goal.
  static int calculateActivityHydration({
    required ActivityType activityType,
    required int durationMinutes,
    required double bodyWeight,
    EnvironmentalConditions? conditions,
    int? intensityLevel, // 1-10 scale
  }) {
    // Validate inputs
    if (durationMinutes <= 0 || bodyWeight <= 0) return 0;

    // Get base hydration rate for activity
    final baseRate = _getActivityHydrationRate(activityType, bodyWeight);

    // Apply intensity adjustment
    double adjustedRate = baseRate;
    if (intensityLevel != null) {
      adjustedRate *= _getIntensityMultiplier(intensityLevel);
    }

    // Apply environmental adjustments
    if (conditions != null) {
      adjustedRate *= _getEnvironmentalMultiplier(conditions);
    }

    // Calculate total for duration
    final totalHydration = (adjustedRate * durationMinutes / 60).round();

    return max(100, min(2000, totalHydration)); // Safety bounds
  }

  /// Calculate optimal reminder schedule
  ///
  /// Creates a personalized reminder schedule based on user profile and preferences.
  static List<DateTime> calculateOptimalReminderTimes(
    UserProfile profile, {
    ReminderPreferences? preferences,
  }) {
    final prefs = preferences ?? ReminderPreferences.defaultPreferences();
    final reminders = <DateTime>[];
    final now = DateTime.now();

    // Calculate wake and sleep times
    final wakeTime = _getWakeTime(profile, prefs, now);
    final sleepTime = _getSleepTime(profile, prefs, now);

    // Calculate total waking hours
    final totalWakingHours = sleepTime.difference(wakeTime).inHours;
    if (totalWakingHours <= 0) return reminders;

    // Calculate reminder frequency based on daily goal
    final dailyGoal = WaterGoalCalculator.getEffectiveGoal(profile);
    final reminderInterval = _calculateReminderInterval(
      dailyGoal,
      totalWakingHours,
    );

    // Generate reminder times
    final reminderCount = (totalWakingHours / reminderInterval).round();

    for (var i = 0; i < reminderCount; i++) {
      final intervalHours = totalWakingHours / reminderCount;
      var reminderTime = wakeTime.add(
        Duration(minutes: (i * intervalHours * 60).round()),
      );

      // Apply preference-based adjustments
      reminderTime = _adjustReminderTime(reminderTime, prefs);

      reminders.add(reminderTime);
    }

    return reminders;
  }

  // MARK: - Environmental Factor Processing

  /// Apply environmental factors to base intake
  static int _applyEnvironmentalFactors(
    int baseIntake,
    List<EnvironmentalFactor> factors,
  ) {
    double multiplier = 1.0;

    for (final factor in factors) {
      multiplier *= factor.getMultiplier();
    }

    return (baseIntake * multiplier).round();
  }

  // MARK: - Lifestyle Factor Processing

  /// Apply lifestyle factors to base intake
  static int _applyLifestyleFactors(
    int baseIntake,
    List<LifestyleFactor> factors,
  ) {
    int adjustment = 0;

    for (final factor in factors) {
      adjustment += factor.getAdjustment(baseIntake);
    }

    return baseIntake + adjustment;
  }

  // MARK: - Health Factor Processing

  /// Apply health factors to base intake
  static int _applyHealthFactors(int baseIntake, List<HealthFactor> factors) {
    double multiplier = 1.0;

    for (final factor in factors) {
      multiplier *= factor.getMultiplier();
    }

    return (baseIntake * multiplier).round();
  }

  // MARK: - Activity Hydration Helpers

  /// Get base hydration rate for activity type (ml per hour per kg)
  static double _getActivityHydrationRate(
    ActivityType activityType,
    double bodyWeight,
  ) {
    final baseRates = {
      ActivityType.running: 8.0,
      ActivityType.cycling: 6.0,
      ActivityType.swimming: 4.0,
      ActivityType.weightlifting: 5.0,
      ActivityType.yoga: 2.0,
      ActivityType.walking: 3.0,
      ActivityType.hiking: 7.0,
      ActivityType.tennis: 9.0,
      ActivityType.basketball: 10.0,
      ActivityType.soccer: 12.0,
      ActivityType.general: 6.0,
    };

    final baseRate =
        baseRates[activityType] ?? baseRates[ActivityType.general]!;
    return baseRate * bodyWeight;
  }

  /// Get intensity multiplier (1-10 scale)
  static double _getIntensityMultiplier(int intensityLevel) {
    final clampedIntensity = max(1, min(10, intensityLevel));
    return 0.7 + (clampedIntensity * 0.05);
  }

  /// Get environmental multiplier for conditions
  static double _getEnvironmentalMultiplier(
    EnvironmentalConditions conditions,
  ) {
    double multiplier = 1.0;

    // Temperature adjustment
    if (conditions.temperature > 25) {
      multiplier *= 1 + ((conditions.temperature - 25) * 0.02);
    }

    // Humidity adjustment
    if (conditions.humidity > 60) {
      multiplier *= 1 + ((conditions.humidity - 60) * 0.005);
    }

    // Altitude adjustment
    if (conditions.altitude > 2500) {
      multiplier *= 1.15;
    }

    return multiplier;
  }

  // MARK: - Reminder Schedule Helpers

  /// Get wake time from profile or preferences
  static DateTime _getWakeTime(
    UserProfile profile,
    ReminderPreferences preferences,
    DateTime baseDate,
  ) {
    final wakeUpTime = profile.wakeUpTime ?? preferences.defaultWakeTime;
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      wakeUpTime.hour,
      wakeUpTime.minute,
    );
  }

  /// Get sleep time from profile or preferences
  static DateTime _getSleepTime(
    UserProfile profile,
    ReminderPreferences preferences,
    DateTime baseDate,
  ) {
    final sleepTime = profile.sleepTime ?? preferences.defaultSleepTime;
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      sleepTime.hour,
      sleepTime.minute,
    );
  }

  /// Calculate reminder interval based on daily goal
  static double _calculateReminderInterval(int dailyGoal, int wakingHours) {
    // Base frequency: every 2 hours, adjusted for goal
    double baseInterval = 2.0;

    if (dailyGoal > 3000) {
      baseInterval = 1.5;
    } else if (dailyGoal < 2000) {
      baseInterval = 2.5;
    }

    // Ensure we don't exceed waking hours
    return min(baseInterval, wakingHours / 2.0);
  }

  /// Adjust reminder time based on preferences
  static DateTime _adjustReminderTime(
    DateTime reminderTime,
    ReminderPreferences preferences,
  ) {
    // Avoid busy hours
    if (preferences.busyHours.contains(reminderTime.hour)) {
      // Move to next available hour
      for (var hour = reminderTime.hour + 1; hour < 24; hour++) {
        if (!preferences.busyHours.contains(hour)) {
          return DateTime(
            reminderTime.year,
            reminderTime.month,
            reminderTime.day,
            hour,
            reminderTime.minute,
          );
        }
      }
    }

    return reminderTime;
  }

  /// Apply safety bounds to calculated intake
  static int _applySafeBounds(int calculatedIntake) {
    return max(
      WaterGoalCalculator.minimumDailyIntake,
      min(WaterGoalCalculator.maximumDailyIntake, calculatedIntake),
    );
  }
}

// MARK: - Supporting Classes and Enums

/// Types of physical activities
enum ActivityType {
  running,
  cycling,
  swimming,
  weightlifting,
  yoga,
  walking,
  hiking,
  tennis,
  basketball,
  soccer,
  general,
}

/// Environmental conditions affecting hydration
class EnvironmentalConditions {
  const EnvironmentalConditions({
    required this.temperature,
    required this.humidity,
    this.altitude = 0,
  });

  /// Temperature in Celsius
  final double temperature;

  /// Humidity percentage (0-100)
  final double humidity;

  /// Altitude in meters above sea level
  final int altitude;
}

/// Abstract base class for environmental factors
abstract class EnvironmentalFactor {
  /// Get the multiplier for this environmental factor
  double getMultiplier();

  /// Get description of this factor
  String getDescription();
}

/// Temperature-based environmental factor
class TemperatureFactor implements EnvironmentalFactor {
  const TemperatureFactor(this.temperature);

  final double temperature;

  @override
  double getMultiplier() {
    if (temperature > 30) {
      return 1.2; // Hot weather
    } else if (temperature > 25) {
      return 1.1; // Warm weather
    } else if (temperature < 10) {
      return 0.95; // Cold weather
    }
    return 1.0;
  }

  @override
  String getDescription() {
    return 'Temperature: ${temperature.toStringAsFixed(1)}°C';
  }
}

/// Humidity-based environmental factor
class HumidityFactor implements EnvironmentalFactor {
  const HumidityFactor(this.humidity);

  final double humidity;

  @override
  double getMultiplier() {
    return humidity > 70 ? 1.1 : 1.0;
  }

  @override
  String getDescription() {
    return 'Humidity: ${humidity.toStringAsFixed(1)}%';
  }
}

/// Altitude-based environmental factor
class AltitudeFactor implements EnvironmentalFactor {
  const AltitudeFactor(this.altitude);

  final int altitude;

  @override
  double getMultiplier() {
    return altitude > 2500 ? 1.15 : 1.0;
  }

  @override
  String getDescription() {
    return 'Altitude: ${altitude}m';
  }
}

/// Abstract base class for lifestyle factors
abstract class LifestyleFactor {
  /// Get the adjustment amount in ml for this lifestyle factor
  int getAdjustment(int baseIntake);

  /// Get description of this factor
  String getDescription();
}

/// Sleep-based lifestyle factor
class SleepFactor implements LifestyleFactor {
  const SleepFactor(this.sleepHours);

  final int sleepHours;

  @override
  int getAdjustment(int baseIntake) {
    if (sleepHours < 6) {
      return (baseIntake * 0.1).round(); // Poor sleep increases needs
    } else if (sleepHours > 9) {
      return -(baseIntake * 0.05)
          .round(); // Excessive sleep slightly reduces needs
    }
    return 0;
  }

  @override
  String getDescription() {
    return 'Sleep: ${sleepHours}h per night';
  }
}

/// Stress-based lifestyle factor
class StressFactor implements LifestyleFactor {
  const StressFactor(this.stressLevel);

  final int stressLevel; // 1-10 scale

  @override
  int getAdjustment(int baseIntake) {
    return stressLevel > 7 ? (baseIntake * 0.1).round() : 0;
  }

  @override
  String getDescription() {
    return 'Stress level: $stressLevel/10';
  }
}

/// Caffeine intake lifestyle factor
class CaffeineFactor implements LifestyleFactor {
  const CaffeineFactor(this.caffeineIntake);

  final int caffeineIntake; // mg per day

  @override
  int getAdjustment(int baseIntake) {
    // Add extra water for caffeine (diuretic effect)
    return ((caffeineIntake / 100) * 200).round(); // 200ml per 100mg caffeine
  }

  @override
  String getDescription() {
    return 'Caffeine: ${caffeineIntake}mg per day';
  }
}

/// Alcohol intake lifestyle factor
class AlcoholFactor implements LifestyleFactor {
  const AlcoholFactor(this.alcoholIntake);

  final int alcoholIntake; // standard drinks per day

  @override
  int getAdjustment(int baseIntake) {
    // Add extra water for alcohol (dehydrating effect)
    return alcoholIntake * 300; // 300ml per standard drink
  }

  @override
  String getDescription() {
    return 'Alcohol: $alcoholIntake drinks per day';
  }
}

/// Abstract base class for health factors
abstract class HealthFactor {
  /// Get the multiplier for this health factor
  double getMultiplier();

  /// Get description of this factor
  String getDescription();
}

/// Medication-based health factor
class MedicationFactor implements HealthFactor {
  const MedicationFactor(this.medications);

  final List<MedicationType> medications;

  @override
  double getMultiplier() {
    double multiplier = 1.0;

    for (final medication in medications) {
      switch (medication) {
        case MedicationType.diuretic:
          multiplier *= 1.2;
        case MedicationType.bloodPressure:
          multiplier *= 1.1;
        case MedicationType.antidepressant:
          multiplier *= 1.05;
      }
    }

    return multiplier;
  }

  @override
  String getDescription() {
    if (medications.isEmpty) return 'No medications';
    return 'Medications: ${medications.map((m) => m.name).join(', ')}';
  }
}

/// Types of medications that affect hydration
enum MedicationType { diuretic, bloodPressure, antidepressant }

/// Reminder preferences for scheduling
class ReminderPreferences {
  const ReminderPreferences({
    required this.defaultWakeTime,
    required this.defaultSleepTime,
    this.busyHours = const [],
    this.mealTimes = const [],
    this.workoutTimes = const [],
  });

  /// Create default reminder preferences
  factory ReminderPreferences.defaultPreferences() {
    return const ReminderPreferences(
      defaultWakeTime: TimeOfDay(hour: 7, minute: 0),
      defaultSleepTime: TimeOfDay(hour: 22, minute: 0),
    );
  }

  /// Default wake-up time
  final TimeOfDay defaultWakeTime;

  /// Default sleep time
  final TimeOfDay defaultSleepTime;

  /// Hours to avoid for reminders (24-hour format)
  final List<int> busyHours;

  /// Meal times for reminder adjustment
  final List<DateTime> mealTimes;

  /// Workout times for reminder adjustment
  final List<DateTime> workoutTimes;
}

/// Extension to add name property to TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  /// Convert TimeOfDay to a readable string
  String get displayName {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
