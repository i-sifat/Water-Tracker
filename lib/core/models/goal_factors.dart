import 'package:equatable/equatable.dart';

/// Enum representing different activity levels for goal calculation
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive;

  /// Display name for the activity level
  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extremelyActive:
        return 'Extremely Active';
    }
  }

  /// Adjustment factor for hydration goal (in ml)
  int get adjustmentFactor {
    switch (this) {
      case ActivityLevel.sedentary:
        return 0;
      case ActivityLevel.lightlyActive:
        return 200;
      case ActivityLevel.moderatelyActive:
        return 400;
      case ActivityLevel.veryActive:
        return 600;
      case ActivityLevel.extremelyActive:
        return 800;
    }
  }
}

/// Enum representing different climate conditions
enum ClimateCondition {
  cold,
  temperate,
  warm,
  hot,
  veryHot;

  /// Display name for the climate condition
  String get displayName {
    switch (this) {
      case ClimateCondition.cold:
        return 'Cold';
      case ClimateCondition.temperate:
        return 'Temperate';
      case ClimateCondition.warm:
        return 'Warm';
      case ClimateCondition.hot:
        return 'Hot';
      case ClimateCondition.veryHot:
        return 'Very Hot';
    }
  }

  /// Adjustment factor for hydration goal (in ml)
  int get adjustmentFactor {
    switch (this) {
      case ClimateCondition.cold:
        return -100;
      case ClimateCondition.temperate:
        return 0;
      case ClimateCondition.warm:
        return 200;
      case ClimateCondition.hot:
        return 400;
      case ClimateCondition.veryHot:
        return 600;
    }
  }
}

/// Model representing factors used to calculate daily hydration goal
class GoalFactors extends Equatable {

  /// Create default goal factors for a user
  factory GoalFactors.defaultForUser({int? weight, int? age, String? gender}) {
    // Basic calculation: 35ml per kg of body weight as base
    final baseWeight = weight ?? 70; // Default 70kg
    final baseRequirement = (baseWeight * 35).round();

    return GoalFactors(
      baseRequirement: baseRequirement,
      activityLevel: ActivityLevel.moderatelyActive,
      climateCondition: ClimateCondition.temperate,
    );
  }

  /// Create from JSON
  factory GoalFactors.fromJson(Map<String, dynamic> json) {
    return GoalFactors(
      baseRequirement: json['baseRequirement'] as int,
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == json['activityLevel'],
        orElse: () => ActivityLevel.moderatelyActive,
      ),
      climateCondition: ClimateCondition.values.firstWhere(
        (e) => e.name == json['climateCondition'],
        orElse: () => ClimateCondition.temperate,
      ),
      healthAdjustment: json['healthAdjustment'] as int? ?? 0,
      customAdjustment: json['customAdjustment'] as int? ?? 0,
    );
  }
  const GoalFactors({
    required this.baseRequirement,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.climateCondition = ClimateCondition.temperate,
    this.healthAdjustment = 0,
    this.customAdjustment = 0,
  });

  /// Base hydration requirement in milliliters (typically based on age, weight, gender)
  final int baseRequirement;

  /// User's activity level
  final ActivityLevel activityLevel;

  /// Current climate condition
  final ClimateCondition climateCondition;

  /// Health-related adjustment in milliliters (e.g., for medical conditions)
  final int healthAdjustment;

  /// Custom user adjustment in milliliters
  final int customAdjustment;

  /// Calculate activity level adjustment
  int get activityAdjustment => activityLevel.adjustmentFactor;

  /// Calculate climate adjustment
  int get climateAdjustment => climateCondition.adjustmentFactor;

  /// Calculate total daily goal
  int get totalGoal {
    return baseRequirement +
        activityAdjustment +
        climateAdjustment +
        healthAdjustment +
        customAdjustment;
  }

  /// Get breakdown of goal calculation
  Map<String, int> get breakdown {
    return {
      'Base Requirement': baseRequirement,
      'Activity Level': activityAdjustment,
      'Climate': climateAdjustment,
      'Health': healthAdjustment,
      'Custom': customAdjustment,
      'Total': totalGoal,
    };
  }

  /// Create a copy with updated fields
  GoalFactors copyWith({
    int? baseRequirement,
    ActivityLevel? activityLevel,
    ClimateCondition? climateCondition,
    int? healthAdjustment,
    int? customAdjustment,
  }) {
    return GoalFactors(
      baseRequirement: baseRequirement ?? this.baseRequirement,
      activityLevel: activityLevel ?? this.activityLevel,
      climateCondition: climateCondition ?? this.climateCondition,
      healthAdjustment: healthAdjustment ?? this.healthAdjustment,
      customAdjustment: customAdjustment ?? this.customAdjustment,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'baseRequirement': baseRequirement,
      'activityLevel': activityLevel.name,
      'climateCondition': climateCondition.name,
      'healthAdjustment': healthAdjustment,
      'customAdjustment': customAdjustment,
    };
  }

  @override
  List<Object?> get props => [
    baseRequirement,
    activityLevel,
    climateCondition,
    healthAdjustment,
    customAdjustment,
  ];

  @override
  String toString() {
    return 'GoalFactors(baseRequirement: ${baseRequirement}ml, totalGoal: ${totalGoal}ml, activity: ${activityLevel.displayName}, climate: ${climateCondition.displayName})';
  }
}
