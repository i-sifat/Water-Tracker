import 'package:watertracker/core/models/user_profile.dart';

/// Abstract interface for water intake adjustment factors
///
/// Each adjustment factor can modify the base water intake calculation
/// based on specific user characteristics or environmental conditions.
abstract class AdjustmentFactor {
  /// Get the multiplier for this adjustment factor
  ///
  /// Returns a value that will be multiplied with the base intake:
  /// - 1.0 = no adjustment
  /// - > 1.0 = increase water intake
  /// - < 1.0 = decrease water intake
  double getMultiplier(UserProfile profile);

  /// Get a human-readable description of this adjustment
  String getDescription(UserProfile profile);

  /// Get the name of this adjustment factor
  String get name;

  /// Check if this adjustment factor applies to the given profile
  bool appliesTo(UserProfile profile);
}

/// Activity level adjustment factor
///
/// Adjusts water intake based on user's activity level:
/// - Sedentary: 1.0x (no adjustment)
/// - Lightly Active: 1.1x
/// - Moderately Active: 1.2x
/// - Very Active: 1.3x
/// - Extremely Active: 1.4x
class ActivityAdjustment implements AdjustmentFactor {
  const ActivityAdjustment();

  @override
  double getMultiplier(UserProfile profile) {
    return profile.activityLevel.waterMultiplier;
  }

  @override
  String getDescription(UserProfile profile) {
    final multiplier = getMultiplier(profile);
    final percentage = ((multiplier - 1.0) * 100).round();

    if (percentage == 0) {
      return 'No adjustment for ${profile.activityLevel.displayName}';
    } else if (percentage > 0) {
      return '+$percentage% for ${profile.activityLevel.displayName}';
    } else {
      return '$percentage% for ${profile.activityLevel.displayName}';
    }
  }

  @override
  String get name => 'Activity Level';

  @override
  bool appliesTo(UserProfile profile) => true; // Always applies
}

/// Age-based adjustment factor
///
/// Adjusts water intake based on user's age:
/// - Children (< 18): 0.9x (90%)
/// - Adults (18-50): 1.0x (100%)
/// - Middle-aged (51-65): 1.05x (105%)
/// - Seniors (> 65): 1.1x (110%)
class AgeAdjustment implements AdjustmentFactor {
  const AgeAdjustment();

  @override
  double getMultiplier(UserProfile profile) {
    if (profile.age == null) return 1.0;

    final age = profile.age!;
    if (age < 18) {
      return 0.9; // Children need less per kg
    } else if (age > 65) {
      return 1.1; // Seniors need more due to decreased kidney function
    } else if (age > 50) {
      return 1.05; // Middle-aged slight increase
    }
    return 1.0; // Adults 18-50
  }

  @override
  String getDescription(UserProfile profile) {
    if (profile.age == null) return 'No age adjustment (age not specified)';

    final multiplier = getMultiplier(profile);
    final percentage = ((multiplier - 1.0) * 100).round();
    final age = profile.age!;

    String ageGroup;
    if (age < 18) {
      ageGroup = 'child';
    } else if (age > 65) {
      ageGroup = 'senior';
    } else if (age > 50) {
      ageGroup = 'middle-aged adult';
    } else {
      ageGroup = 'adult';
    }

    if (percentage == 0) {
      return 'No adjustment for $ageGroup (age $age)';
    } else if (percentage > 0) {
      return '+$percentage% for $ageGroup (age $age)';
    } else {
      return '$percentage% for $ageGroup (age $age)';
    }
  }

  @override
  String get name => 'Age';

  @override
  bool appliesTo(UserProfile profile) => profile.age != null;
}

/// Health condition adjustment factor
///
/// Adjusts water intake based on pregnancy status and health conditions:
/// - Not pregnant: 1.0x
/// - Pregnant: 1.3x
/// - Breastfeeding: 1.5x
class HealthAdjustment implements AdjustmentFactor {
  const HealthAdjustment();

  @override
  double getMultiplier(UserProfile profile) {
    return profile.pregnancyStatus.waterMultiplier;
  }

  @override
  String getDescription(UserProfile profile) {
    final multiplier = getMultiplier(profile);
    final percentage = ((multiplier - 1.0) * 100).round();

    if (percentage == 0) {
      return 'No health adjustment';
    } else {
      return '+$percentage% for ${profile.pregnancyStatus.displayName}';
    }
  }

  @override
  String get name => 'Health Status';

  @override
  bool appliesTo(UserProfile profile) {
    return profile.pregnancyStatus != PregnancyStatus.notPregnant &&
        profile.pregnancyStatus != PregnancyStatus.preferNotToSay;
  }
}

/// Goal-based adjustment factor
///
/// Adjusts water intake based on user's selected goals:
/// - General Health: 1.0x
/// - Weight Loss: 1.1x
/// - Muscle Gain: 1.2x
/// - Athletic Performance: 1.3x
/// - Skin Health: 1.1x
///
/// When multiple goals are selected, uses the highest multiplier.
class GoalAdjustment implements AdjustmentFactor {
  const GoalAdjustment();

  @override
  double getMultiplier(UserProfile profile) {
    if (profile.goals.isEmpty) return 1.0;

    // Return the highest goal multiplier
    return profile.goals
        .map((goal) => goal.waterMultiplier)
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  String getDescription(UserProfile profile) {
    if (profile.goals.isEmpty) {
      return 'No goal adjustment (no goals selected)';
    }

    final multiplier = getMultiplier(profile);
    final percentage = ((multiplier - 1.0) * 100).round();

    // Find the goal with the highest multiplier
    final primaryGoal = profile.goals.reduce(
      (a, b) => a.waterMultiplier > b.waterMultiplier ? a : b,
    );

    if (percentage == 0) {
      return 'No adjustment for ${primaryGoal.displayName}';
    } else {
      final goalText =
          profile.goals.length > 1
              ? '${primaryGoal.displayName} (primary goal)'
              : primaryGoal.displayName;
      return '+$percentage% for $goalText';
    }
  }

  @override
  String get name => 'Goals';

  @override
  bool appliesTo(UserProfile profile) => profile.goals.isNotEmpty;
}

/// Dietary adjustment factor
///
/// Adjusts water intake based on dietary habits:
/// - Low vegetable intake (< 3 servings): +5% (need more water from drinks)
/// - High sugar drink intake (> 2 servings): +10% (need more water to process sugar)
/// - Both conditions can apply simultaneously
class DietaryAdjustment implements AdjustmentFactor {
  const DietaryAdjustment();

  @override
  double getMultiplier(UserProfile profile) {
    double multiplier = 1.0;

    // Less water from food if low vegetable intake
    if (profile.vegetableIntake < 3) {
      multiplier *= 1.05;
    }

    // More water needed to process sugar
    if (profile.sugarDrinkIntake > 2) {
      multiplier *= 1.1;
    }

    return multiplier;
  }

  @override
  String getDescription(UserProfile profile) {
    final lowVeggies = profile.vegetableIntake < 3;
    final highSugar = profile.sugarDrinkIntake > 2;

    if (!lowVeggies && !highSugar) {
      return 'No dietary adjustment';
    }

    final adjustments = <String>[];

    if (lowVeggies) {
      adjustments.add('+5% for low vegetable intake');
    }

    if (highSugar) {
      adjustments.add('+10% for high sugar drink intake');
    }

    return adjustments.join(', ');
  }

  @override
  String get name => 'Diet';

  @override
  bool appliesTo(UserProfile profile) {
    return profile.vegetableIntake < 3 || profile.sugarDrinkIntake > 2;
  }
}

/// Environmental adjustment factor
///
/// Adjusts water intake based on weather preferences:
/// - Cold weather: 0.9x (less sweating)
/// - Moderate weather: 1.0x (no adjustment)
/// - Hot weather: 1.2x (more sweating)
class EnvironmentalAdjustment implements AdjustmentFactor {
  const EnvironmentalAdjustment();

  @override
  double getMultiplier(UserProfile profile) {
    return profile.weatherPreference.waterMultiplier;
  }

  @override
  String getDescription(UserProfile profile) {
    final multiplier = getMultiplier(profile);
    final percentage = ((multiplier - 1.0) * 100).round();

    if (percentage == 0) {
      return 'No adjustment for ${profile.weatherPreference.displayName}';
    } else if (percentage > 0) {
      return '+$percentage% for ${profile.weatherPreference.displayName}';
    } else {
      return '$percentage% for ${profile.weatherPreference.displayName}';
    }
  }

  @override
  String get name => 'Environment';

  @override
  bool appliesTo(UserProfile profile) => true; // Always applies
}

/// Adjustment factor combination utility
///
/// Provides methods to combine multiple adjustment factors with clear precedence rules.
class AdjustmentFactorCombiner {
  /// Standard adjustment factors in order of precedence
  static const List<AdjustmentFactor> standardFactors = [
    ActivityAdjustment(),
    AgeAdjustment(),
    HealthAdjustment(),
    GoalAdjustment(),
    DietaryAdjustment(),
    EnvironmentalAdjustment(),
  ];

  /// Calculate combined multiplier from all applicable factors
  ///
  /// Multiplies all applicable adjustment factors together.
  /// Returns 1.0 if no factors apply.
  static double calculateCombinedMultiplier(
    UserProfile profile, {
    List<AdjustmentFactor>? factors,
  }) {
    final applicableFactors = factors ?? standardFactors;

    double combinedMultiplier = 1.0;

    for (final factor in applicableFactors) {
      if (factor.appliesTo(profile)) {
        combinedMultiplier *= factor.getMultiplier(profile);
      }
    }

    return combinedMultiplier;
  }

  /// Get breakdown of all applicable adjustment factors
  ///
  /// Returns a map of factor names to their multipliers and descriptions.
  static Map<String, AdjustmentFactorInfo> getAdjustmentBreakdown(
    UserProfile profile, {
    List<AdjustmentFactor>? factors,
  }) {
    final applicableFactors = factors ?? standardFactors;
    final breakdown = <String, AdjustmentFactorInfo>{};

    for (final factor in applicableFactors) {
      if (factor.appliesTo(profile)) {
        breakdown[factor.name] = AdjustmentFactorInfo(
          name: factor.name,
          multiplier: factor.getMultiplier(profile),
          description: factor.getDescription(profile),
        );
      }
    }

    return breakdown;
  }

  /// Get list of applicable factors for a profile
  static List<AdjustmentFactor> getApplicableFactors(
    UserProfile profile, {
    List<AdjustmentFactor>? factors,
  }) {
    final allFactors = factors ?? standardFactors;
    return allFactors.where((factor) => factor.appliesTo(profile)).toList();
  }
}

/// Information about an adjustment factor
class AdjustmentFactorInfo {
  const AdjustmentFactorInfo({
    required this.name,
    required this.multiplier,
    required this.description,
  });

  /// Name of the adjustment factor
  final String name;

  /// Multiplier value
  final double multiplier;

  /// Human-readable description
  final String description;

  /// Get percentage change as a string
  String get percentageChange {
    final percentage = ((multiplier - 1.0) * 100).round();
    if (percentage == 0) {
      return 'No change';
    } else if (percentage > 0) {
      return '+$percentage%';
    } else {
      return '$percentage%';
    }
  }

  @override
  String toString() {
    return '$name: $percentageChange ($description)';
  }
}
