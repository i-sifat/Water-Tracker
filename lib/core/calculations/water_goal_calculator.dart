import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/security/input_validator.dart';

/// Simplified water goal calculator with clear, testable methods
///
/// This calculator provides a clean separation between basic and advanced
/// calculations, with input validation and boundary checking for safety.
class WaterGoalCalculator {
  /// Default daily water goal in milliliters
  static const int defaultGoal = 2000;

  /// Base multiplier: 35ml per kg of body weight (WHO recommendation)
  static const double baseMultiplierPerKg = 35.0;

  /// Minimum safe daily water intake in milliliters
  static const int minimumDailyIntake = 1500;

  /// Maximum safe daily water intake in milliliters
  static const int maximumDailyIntake = 5000;

  /// Calculate basic daily water goal using simplified formula
  ///
  /// Uses the standard 35ml per kg body weight formula with basic adjustments
  /// for activity level and pregnancy status.
  ///
  /// Returns [defaultGoal] if weight is invalid or null.
  /// Throws [ArgumentError] if profile is null.
  static int calculateBasicGoal(UserProfile profile) {
    try {
      // Null check for profile
      ArgumentError.checkNotNull(profile, 'profile');

      // Input validation using secure validator
      final weightError = InputValidator.validateWeight(profile.weight);
      if (weightError != null) {
        debugPrint(
          'Invalid weight in calculateBasicGoal: ${weightError.message}',
        );
        return defaultGoal;
      }

      final ageError = InputValidator.validateAge(profile.age);
      if (ageError != null) {
        debugPrint('Invalid age in calculateBasicGoal: ${ageError.message}');
        // Continue with calculation as age is optional for basic calculation
      }

      // Base calculation: 35ml per kg of body weight
      double baseIntake = profile.weight! * baseMultiplierPerKg;

      // Apply basic multipliers with null safety
      final activityMultiplier = profile.activityLevel.waterMultiplier;
      final pregnancyMultiplier = profile.pregnancyStatus.waterMultiplier;

      if (activityMultiplier <= 0 || pregnancyMultiplier <= 0) {
        throw ArgumentError('Invalid multiplier values in profile');
      }

      baseIntake *= activityMultiplier;
      baseIntake *= pregnancyMultiplier;

      // Check for overflow or invalid calculation results
      if (baseIntake.isNaN || baseIntake.isInfinite || baseIntake <= 0) {
        throw StateError('Invalid calculation result: $baseIntake');
      }

      // Apply boundary checking
      return _applySafeBounds(baseIntake.round());
    } catch (e) {
      // Log error and return safe default
      debugPrint('Error in calculateBasicGoal: $e');
      return defaultGoal;
    }
  }

  /// Calculate daily water goal with age adjustments
  ///
  /// Includes age-based adjustments on top of basic calculation:
  /// - Children (< 18): 90% of base requirement
  /// - Adults (18-50): 100% of base requirement
  /// - Middle-aged (51-65): 105% of base requirement
  /// - Seniors (> 65): 110% of base requirement
  static int calculateAgeAdjustedGoal(UserProfile profile) {
    if (!_isValidWeight(profile.weight) || !_isValidAge(profile.age)) {
      return defaultGoal;
    }

    // Start with basic calculation
    double baseIntake = profile.weight! * baseMultiplierPerKg;

    // Apply activity and pregnancy multipliers
    baseIntake *= profile.activityLevel.waterMultiplier;
    baseIntake *= profile.pregnancyStatus.waterMultiplier;

    // Apply age adjustments
    baseIntake *= _getAgeMultiplier(profile.age!);

    return _applySafeBounds(baseIntake.round());
  }

  /// Calculate daily water goal with all basic factors
  ///
  /// Includes weight, age, activity, pregnancy, and goal-based adjustments.
  /// This is the recommended method for most users.
  static int calculateComprehensiveGoal(UserProfile profile) {
    if (!_isValidWeight(profile.weight) || !_isValidAge(profile.age)) {
      return defaultGoal;
    }

    // Start with base calculation
    double baseIntake = profile.weight! * baseMultiplierPerKg;

    // Apply core multipliers
    baseIntake *= profile.activityLevel.waterMultiplier;
    baseIntake *= profile.pregnancyStatus.waterMultiplier;

    // Apply age adjustments
    baseIntake *= _getAgeMultiplier(profile.age!);

    // Apply goal-based adjustments (take highest if multiple goals)
    if (profile.goals.isNotEmpty) {
      final maxGoalMultiplier = profile.goals
          .map((goal) => goal.waterMultiplier)
          .reduce((a, b) => a > b ? a : b);
      baseIntake *= maxGoalMultiplier;
    }

    // Apply dietary adjustments
    baseIntake *= _getDietaryMultiplier(
      profile.vegetableIntake,
      profile.sugarDrinkIntake,
    );

    return _applySafeBounds(baseIntake.round());
  }

  /// Get the effective daily goal from user profile
  ///
  /// Returns custom goal if set, otherwise calculates comprehensive goal.
  static int getEffectiveGoal(UserProfile profile) {
    return profile.customDailyGoal ?? calculateComprehensiveGoal(profile);
  }

  // MARK: - Private Helper Methods

  /// Validate weight input
  static bool _isValidWeight(double? weight) {
    return weight != null && weight > 0 && weight <= 500;
  }

  /// Validate age input
  static bool _isValidAge(int? age) {
    return age != null && age > 0 && age <= 150;
  }

  /// Get age-based multiplier
  static double _getAgeMultiplier(int age) {
    if (age < 18) {
      return 0.9; // Children need less per kg
    } else if (age > 65) {
      return 1.1; // Seniors need more due to decreased kidney function
    } else if (age > 50) {
      return 1.05; // Middle-aged slight increase
    }
    return 1.0; // Adults 18-50
  }

  /// Get dietary adjustment multiplier
  static double _getDietaryMultiplier(
    int vegetableIntake,
    int sugarDrinkIntake,
  ) {
    double multiplier = 1.0;

    // Less water from food if low vegetable intake
    if (vegetableIntake < 3) {
      multiplier *= 1.05;
    }

    // More water needed to process sugar
    if (sugarDrinkIntake > 2) {
      multiplier *= 1.1;
    }

    return multiplier;
  }

  /// Apply safe boundary limits to calculated intake
  static int _applySafeBounds(int calculatedIntake) {
    return max(minimumDailyIntake, min(maximumDailyIntake, calculatedIntake));
  }
}
