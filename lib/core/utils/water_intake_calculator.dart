import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/models/user_profile.dart';

/// Advanced water intake calculator with premium features
class WaterIntakeCalculator {
  /// Calculate basic water intake (free users)
  static int calculateBasicIntake(UserProfile profile) {
    if (profile.weight == null || profile.age == null) return 2000;

    // Simple calculation: 35ml per kg of body weight
    var baseIntake = profile.weight! * 35;

    // Apply basic multipliers
    baseIntake *= profile.activityLevel.waterMultiplier;
    baseIntake *= profile.pregnancyStatus.waterMultiplier;

    return baseIntake.round();
  }

  /// Calculate advanced water intake (premium users)
  static int calculateAdvancedIntake(
    UserProfile profile, {
    double? bodyFatPercentage,
    double? muscleMass,
    int? sleepHours,
    int? stressLevel, // 1-10 scale
    double? environmentalTemperature,
    double? humidity,
    int? altitude, // meters above sea level
    bool? isPreWorkout,
    bool? isPostWorkout,
    int? caffeineIntake, // mg per day
    int? alcoholIntake, // standard drinks per day
    List<String>? medications,
    String? climateZone,
    int? sweatRate, // ml per hour during exercise
  }) {
    if (profile.weight == null || profile.age == null) {
      return calculateBasicIntake(profile);
    }

    // Start with body weight calculation
    var baseIntake = _calculateBodyWeightIntake(
      profile.weight!,
      bodyFatPercentage: bodyFatPercentage,
      muscleMass: muscleMass,
    );

    // Age adjustments
    baseIntake = _applyAgeAdjustments(baseIntake, profile.age!);

    // Gender adjustments
    baseIntake = _applyGenderAdjustments(baseIntake, profile.gender);

    // Activity level adjustments
    baseIntake = _applyActivityAdjustments(
      baseIntake,
      profile.activityLevel,
      sweatRate: sweatRate,
      isPreWorkout: isPreWorkout,
      isPostWorkout: isPostWorkout,
    );

    // Environmental adjustments
    baseIntake = _applyEnvironmentalAdjustments(
      baseIntake,
      temperature: environmentalTemperature,
      humidity: humidity,
      altitude: altitude,
      climateZone: climateZone,
    );

    // Health condition adjustments
    baseIntake = _applyHealthAdjustments(
      baseIntake,
      pregnancyStatus: profile.pregnancyStatus,
      medications: medications,
    );

    // Lifestyle adjustments
    baseIntake = _applyLifestyleAdjustments(
      baseIntake,
      sleepHours: sleepHours,
      stressLevel: stressLevel,
      caffeineIntake: caffeineIntake,
      alcoholIntake: alcoholIntake,
    );

    // Goal-based adjustments
    baseIntake = _applyGoalAdjustments(baseIntake, profile.goals);

    // Dietary adjustments
    baseIntake = _applyDietaryAdjustments(
      baseIntake,
      vegetableIntake: profile.vegetableIntake,
      sugarDrinkIntake: profile.sugarDrinkIntake,
    );

    return max(1500, min(5000, baseIntake.round())); // Safety bounds
  }

  /// Calculate water intake from user profile data (legacy method for compatibility)
  static Future<int> calculateWaterIntake() async {
    // This is a simplified version that uses stored preferences
    // In a real app, you'd pass the UserProfile directly
    try {
      final prefs = await SharedPreferences.getInstance();
      final weight = prefs.getDouble('user_weight') ?? 70.0;
      final age = prefs.getInt('user_age') ?? 30;
      
      // Simple calculation: 35ml per kg of body weight
      var baseIntake = weight * 35;
      
      // Age adjustments
      if (age > 65) {
        baseIntake *= 1.1;
      } else if (age < 18) {
        baseIntake *= 0.9;
      }
      
      return baseIntake.round();
    } catch (e) {
      debugPrint('Error calculating water intake: $e');
      return 2000; // Default value
    }
  }

  /// Calculate personalized reminder schedule (premium feature)
  static List<DateTime> calculateOptimalReminderTimes(
    UserProfile profile, {
    DateTime? wakeUpTime,
    DateTime? bedTime,
    List<DateTime>? mealTimes,
    List<DateTime>? workoutTimes,
    int? workStartHour,
    int? workEndHour,
    bool? hasLunchBreak,
    List<int>? busyHours,
  }) {
    final reminders = <DateTime>[];
    final now = DateTime.now();
    
    // Default times if not provided
    final wake = wakeUpTime ?? DateTime(now.year, now.month, now.day, 7, 0);
    final sleep = bedTime ?? DateTime(now.year, now.month, now.day, 22, 0);
    
    // Calculate optimal distribution
    final totalWakingHours = sleep.difference(wake).inHours;
    final dailyGoal = profile.effectiveDailyGoal;
    
    // Base frequency: every 2 hours, adjusted for goal
    var baseInterval = 2.0;
    if (dailyGoal > 3000) baseInterval = 1.5;
    if (dailyGoal < 2000) baseInterval = 2.5;
    
    // Calculate number of reminders
    final reminderCount = (totalWakingHours / baseInterval).round();
    
    // Distribute reminders throughout the day
    for (var i = 0; i < reminderCount; i++) {
      final intervalHours = totalWakingHours / reminderCount;
      var reminderTime = wake.add(Duration(
        minutes: (i * intervalHours * 60).round(),
      ));
      
      // Adjust for meal times (drink before meals)
      if (mealTimes != null) {
        reminderTime = _adjustForMealTimes(reminderTime, mealTimes);
      }
      
      // Adjust for workout times
      if (workoutTimes != null) {
        reminderTime = _adjustForWorkoutTimes(reminderTime, workoutTimes);
      }
      
      // Avoid busy hours
      if (busyHours != null) {
        reminderTime = _avoidBusyHours(reminderTime, busyHours);
      }
      
      reminders.add(reminderTime);
    }
    
    return reminders;
  }

  /// Calculate hydration needs for specific activities (premium feature)
  static int calculateActivityHydration({
    required String activityType,
    required int durationMinutes,
    required double bodyWeight,
    double? environmentalTemp,
    double? humidity,
    int? intensityLevel, // 1-10 scale
  }) {
    // Base hydration rates (ml per hour per kg of body weight)
    final baseRates = {
      'running': 8.0,
      'cycling': 6.0,
      'swimming': 4.0,
      'weightlifting': 5.0,
      'yoga': 2.0,
      'walking': 3.0,
      'hiking': 7.0,
      'tennis': 9.0,
      'basketball': 10.0,
      'soccer': 12.0,
      'general': 6.0,
    };
    
    final baseRate = baseRates[activityType.toLowerCase()] ?? baseRates['general']!;
    var hydrationRate = baseRate * bodyWeight;
    
    // Adjust for intensity
    if (intensityLevel != null) {
      final intensityMultiplier = 0.7 + (intensityLevel * 0.05);
      hydrationRate *= intensityMultiplier;
    }
    
    // Adjust for environment
    if (environmentalTemp != null && environmentalTemp > 25) {
      final tempMultiplier = 1 + ((environmentalTemp - 25) * 0.02);
      hydrationRate *= tempMultiplier;
    }
    
    if (humidity != null && humidity > 60) {
      final humidityMultiplier = 1 + ((humidity - 60) * 0.005);
      hydrationRate *= humidityMultiplier;
    }
    
    // Calculate total for duration
    final totalHydration = (hydrationRate * durationMinutes / 60).round();
    
    return max(100, min(2000, totalHydration)); // Safety bounds
  }

  // MARK: - Private Helper Methods

  static double _calculateBodyWeightIntake(
    double weight, {
    double? bodyFatPercentage,
    double? muscleMass,
  }) {
    var baseIntake = weight * 35; // Base: 35ml per kg
    
    // Adjust for body composition if available
    if (bodyFatPercentage != null) {
      // Lower body fat = higher water needs (muscle holds more water)
      if (bodyFatPercentage < 15) {
        baseIntake *= 1.1;
      } else if (bodyFatPercentage > 25) {
        baseIntake *= 0.95;
      }
    }
    
    if (muscleMass != null && muscleMass > weight * 0.4) {
      // High muscle mass = higher water needs
      baseIntake *= 1.05;
    }
    
    return baseIntake;
  }

  static double _applyAgeAdjustments(double baseIntake, int age) {
    if (age < 18) {
      return baseIntake * 0.9; // Children need less per kg
    } else if (age > 65) {
      return baseIntake * 1.1; // Older adults need more
    } else if (age > 50) {
      return baseIntake * 1.05; // Middle-aged slight increase
    }
    return baseIntake;
  }

  static double _applyGenderAdjustments(double baseIntake, Gender gender) {
    switch (gender) {
      case Gender.male:
        return baseIntake * 1.05; // Men typically need slightly more
      case Gender.female:
        return baseIntake * 0.95; // Women typically need slightly less
      case Gender.notSpecified:
        return baseIntake; // No adjustment
    }
  }

  static double _applyActivityAdjustments(
    double baseIntake,
    ActivityLevel activityLevel, {
    int? sweatRate,
    bool? isPreWorkout,
    bool? isPostWorkout,
  }) {
    var adjustedIntake = baseIntake * activityLevel.waterMultiplier;
    
    // Additional adjustments for workout timing
    if (isPreWorkout == true) {
      adjustedIntake += 500; // Extra 500ml before workout
    }
    
    if (isPostWorkout == true) {
      adjustedIntake += 750; // Extra 750ml after workout
    }
    
    // Adjust for sweat rate if available
    if (sweatRate != null) {
      // Add replacement for expected sweat loss
      adjustedIntake += sweatRate * 1.5; // 150% replacement
    }
    
    return adjustedIntake;
  }

  static double _applyEnvironmentalAdjustments(
    double baseIntake, {
    double? temperature,
    double? humidity,
    int? altitude,
    String? climateZone,
  }) {
    var adjustedIntake = baseIntake;
    
    // Temperature adjustments
    if (temperature != null) {
      if (temperature > 30) {
        adjustedIntake *= 1.2; // Hot weather
      } else if (temperature > 25) {
        adjustedIntake *= 1.1; // Warm weather
      } else if (temperature < 10) {
        adjustedIntake *= 0.95; // Cold weather (less sweating)
      }
    }
    
    // Humidity adjustments
    if (humidity != null && humidity > 70) {
      adjustedIntake *= 1.1; // High humidity increases needs
    }
    
    // Altitude adjustments
    if (altitude != null && altitude > 2500) {
      adjustedIntake *= 1.15; // High altitude increases needs
    }
    
    // Climate zone adjustments
    if (climateZone != null) {
      switch (climateZone.toLowerCase()) {
        case 'tropical':
          adjustedIntake *= 1.2;
          break;
        case 'desert':
          adjustedIntake *= 1.3;
          break;
        case 'arctic':
          adjustedIntake *= 0.9;
          break;
      }
    }
    
    return adjustedIntake;
  }

  static double _applyHealthAdjustments(
    double baseIntake, {
    PregnancyStatus? pregnancyStatus,
    List<String>? medications,
  }) {
    var adjustedIntake = baseIntake;
    
    // Pregnancy adjustments
    if (pregnancyStatus != null) {
      adjustedIntake *= pregnancyStatus.waterMultiplier;
    }
    
    // Medication adjustments
    if (medications != null) {
      for (final medication in medications) {
        switch (medication.toLowerCase()) {
          case 'diuretic':
            adjustedIntake *= 1.2;
            break;
          case 'blood_pressure':
            adjustedIntake *= 1.1;
            break;
          case 'antidepressant':
            adjustedIntake *= 1.05;
            break;
        }
      }
    }
    
    return adjustedIntake;
  }

  static double _applyLifestyleAdjustments(
    double baseIntake, {
    int? sleepHours,
    int? stressLevel,
    int? caffeineIntake,
    int? alcoholIntake,
  }) {
    var adjustedIntake = baseIntake;
    
    // Sleep adjustments
    if (sleepHours != null) {
      if (sleepHours < 6) {
        adjustedIntake *= 1.1; // Poor sleep increases needs
      } else if (sleepHours > 9) {
        adjustedIntake *= 0.95; // Excessive sleep slightly reduces needs
      }
    }
    
    // Stress adjustments
    if (stressLevel != null && stressLevel > 7) {
      adjustedIntake *= 1.1; // High stress increases needs
    }
    
    // Caffeine adjustments
    if (caffeineIntake != null) {
      // Add extra water for caffeine (diuretic effect)
      adjustedIntake += (caffeineIntake / 100) * 200; // 200ml per 100mg caffeine
    }
    
    // Alcohol adjustments
    if (alcoholIntake != null && alcoholIntake > 0) {
      // Add extra water for alcohol (dehydrating effect)
      adjustedIntake += alcoholIntake * 300; // 300ml per standard drink
    }
    
    return adjustedIntake;
  }

  static double _applyGoalAdjustments(double baseIntake, List<Goal> goals) {
    if (goals.isEmpty) return baseIntake;
    
    // Apply the highest goal multiplier
    final maxMultiplier = goals
        .map((goal) => goal.waterMultiplier)
        .reduce((a, b) => a > b ? a : b);
    
    return baseIntake * maxMultiplier;
  }

  static double _applyDietaryAdjustments(
    double baseIntake, {
    int? vegetableIntake,
    int? sugarDrinkIntake,
  }) {
    var adjustedIntake = baseIntake;
    
    // Vegetable intake (provides water from food)
    if (vegetableIntake != null && vegetableIntake < 3) {
      adjustedIntake *= 1.05; // Less water from food
    }
    
    // Sugar drink intake (requires more water to process)
    if (sugarDrinkIntake != null && sugarDrinkIntake > 2) {
      adjustedIntake *= 1.1; // More water needed
    }
    
    return adjustedIntake;
  }

  static DateTime _adjustForMealTimes(DateTime reminderTime, List<DateTime> mealTimes) {
    // Try to schedule reminders 30 minutes before meals
    for (final mealTime in mealTimes) {
      final timeDiff = reminderTime.difference(mealTime).inMinutes.abs();
      if (timeDiff < 30) {
        // Move reminder to 30 minutes before meal
        return mealTime.subtract(const Duration(minutes: 30));
      }
    }
    return reminderTime;
  }

  static DateTime _adjustForWorkoutTimes(DateTime reminderTime, List<DateTime> workoutTimes) {
    // Schedule reminders before and after workouts
    for (final workoutTime in workoutTimes) {
      final timeDiff = reminderTime.difference(workoutTime).inMinutes;
      if (timeDiff.abs() < 60) {
        if (timeDiff > 0) {
          // After workout - move to 15 minutes after
          return workoutTime.add(const Duration(minutes: 15));
        } else {
          // Before workout - move to 30 minutes before
          return workoutTime.subtract(const Duration(minutes: 30));
        }
      }
    }
    return reminderTime;
  }

  static DateTime _avoidBusyHours(DateTime reminderTime, List<int> busyHours) {
    if (busyHours.contains(reminderTime.hour)) {
      // Move to next available hour
      for (var hour = reminderTime.hour + 1; hour < 24; hour++) {
        if (!busyHours.contains(hour)) {
          return DateTime(
            reminderTime.year,
            reminderTime.month,
            reminderTime.day,
            hour,
            0,
          );
        }
      }
    }
    return reminderTime;
  }
}