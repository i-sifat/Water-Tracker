import 'package:equatable/equatable.dart';

/// Enum representing user gender
enum Gender {
  male,
  female,
  notSpecified;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.notSpecified:
        return 'Prefer not to say';
    }
  }
}

/// Enum representing activity levels
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive;

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

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Little to no exercise';
      case ActivityLevel.lightlyActive:
        return 'Light exercise 1-3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Moderate exercise 3-5 days/week';
      case ActivityLevel.veryActive:
        return 'Hard exercise 6-7 days/week';
      case ActivityLevel.extremelyActive:
        return 'Very hard exercise, physical job';
    }
  }

  /// Multiplier for water intake calculation
  double get waterMultiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1;
      case ActivityLevel.lightlyActive:
        return 1.1;
      case ActivityLevel.moderatelyActive:
        return 1.2;
      case ActivityLevel.veryActive:
        return 1.3;
      case ActivityLevel.extremelyActive:
        return 1.4;
    }
  }
}

/// Enum representing weather preferences
enum WeatherPreference {
  cold,
  moderate,
  hot;

  String get displayName {
    switch (this) {
      case WeatherPreference.cold:
        return 'Cold Weather';
      case WeatherPreference.moderate:
        return 'Moderate Weather';
      case WeatherPreference.hot:
        return 'Hot Weather';
    }
  }

  /// Multiplier for water intake calculation based on weather
  double get waterMultiplier {
    switch (this) {
      case WeatherPreference.cold:
        return 0.9;
      case WeatherPreference.moderate:
        return 1;
      case WeatherPreference.hot:
        return 1.2;
    }
  }
}

/// Enum representing user goals
enum Goal {
  weightLoss,
  muscleGain,
  generalHealth,
  athleticPerformance,
  skinHealth;

  String get displayName {
    switch (this) {
      case Goal.weightLoss:
        return 'Weight Loss';
      case Goal.muscleGain:
        return 'Muscle Gain';
      case Goal.generalHealth:
        return 'General Health';
      case Goal.athleticPerformance:
        return 'Athletic Performance';
      case Goal.skinHealth:
        return 'Skin Health';
    }
  }

  String get description {
    switch (this) {
      case Goal.weightLoss:
        return 'Stay hydrated to support metabolism';
      case Goal.muscleGain:
        return 'Optimize hydration for muscle growth';
      case Goal.generalHealth:
        return 'Maintain overall health and wellness';
      case Goal.athleticPerformance:
        return 'Enhance performance and recovery';
      case Goal.skinHealth:
        return 'Improve skin hydration and appearance';
    }
  }

  /// Multiplier for water intake calculation based on goal
  double get waterMultiplier {
    switch (this) {
      case Goal.weightLoss:
        return 1.1;
      case Goal.muscleGain:
        return 1.2;
      case Goal.generalHealth:
        return 1;
      case Goal.athleticPerformance:
        return 1.3;
      case Goal.skinHealth:
        return 1.1;
    }
  }
}

/// Enum representing pregnancy status
enum PregnancyStatus {
  notPregnant,
  pregnant,
  breastfeeding,
  preferNotToSay;

  String get displayName {
    switch (this) {
      case PregnancyStatus.notPregnant:
        return 'Not Pregnant';
      case PregnancyStatus.pregnant:
        return 'Pregnant';
      case PregnancyStatus.breastfeeding:
        return 'Breastfeeding';
      case PregnancyStatus.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  /// Multiplier for water intake calculation
  double get waterMultiplier {
    switch (this) {
      case PregnancyStatus.notPregnant:
        return 1;
      case PregnancyStatus.pregnant:
        return 1.3;
      case PregnancyStatus.breastfeeding:
        return 1.5;
      case PregnancyStatus.preferNotToSay:
        return 1;
    }
  }
}

/// Model representing user profile with all onboarding data
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    this.weight,
    this.age,
    this.gender = Gender.notSpecified,
    this.activityLevel = ActivityLevel.sedentary,
    this.weatherPreference = WeatherPreference.moderate,
    this.goals = const [],
    this.pregnancyStatus = PregnancyStatus.notPregnant,
    this.vegetableIntake = 0,
    this.sugarDrinkIntake = 0,
    this.dailyGoal,
    this.customDailyGoal,
    this.notificationsEnabled = true,
    this.reminderTimes = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      weight: json['weight'] as double?,
      age: json['age'] as int?,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.notSpecified,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == json['activityLevel'],
        orElse: () => ActivityLevel.sedentary,
      ),
      weatherPreference: WeatherPreference.values.firstWhere(
        (e) => e.name == json['weatherPreference'],
        orElse: () => WeatherPreference.moderate,
      ),
      goals:
          (json['goals'] as List<dynamic>?)
              ?.map(
                (g) => Goal.values.firstWhere(
                  (e) => e.name == g,
                  orElse: () => Goal.generalHealth,
                ),
              )
              .toList() ??
          [],
      pregnancyStatus: PregnancyStatus.values.firstWhere(
        (e) => e.name == json['pregnancyStatus'],
        orElse: () => PregnancyStatus.notPregnant,
      ),
      vegetableIntake: json['vegetableIntake'] as int? ?? 0,
      sugarDrinkIntake: json['sugarDrinkIntake'] as int? ?? 0,
      dailyGoal: json['dailyGoal'] as int?,
      customDailyGoal: json['customDailyGoal'] as int?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      reminderTimes:
          (json['reminderTimes'] as List<dynamic>?)
              ?.map((t) => DateTime.fromMillisecondsSinceEpoch(t as int))
              .toList() ??
          [],
      createdAt:
          json['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
              : null,
    );
  }

  /// Create a new user profile with default values
  factory UserProfile.create({String? id}) {
    final now = DateTime.now();
    return UserProfile(
      id: id ?? now.millisecondsSinceEpoch.toString(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Unique identifier for the user profile
  final String id;

  /// User's weight in kilograms
  final double? weight;

  /// User's age in years
  final int? age;

  /// User's gender
  final Gender gender;

  /// User's activity level
  final ActivityLevel activityLevel;

  /// User's weather preference
  final WeatherPreference weatherPreference;

  /// User's selected goals
  final List<Goal> goals;

  /// User's pregnancy status
  final PregnancyStatus pregnancyStatus;

  /// Daily vegetable intake (servings)
  final int vegetableIntake;

  /// Daily sugary drink intake (servings)
  final int sugarDrinkIntake;

  /// Calculated daily water goal in milliliters
  final int? dailyGoal;

  /// Custom daily goal set by user (overrides calculated goal)
  final int? customDailyGoal;

  /// Whether notifications are enabled
  final bool notificationsEnabled;

  /// List of reminder times throughout the day
  final List<DateTime> reminderTimes;

  /// When the profile was created
  final DateTime? createdAt;

  /// When the profile was last updated
  final DateTime? updatedAt;

  /// Get the effective daily goal (custom or calculated)
  int get effectiveDailyGoal => customDailyGoal ?? dailyGoal ?? 2000;

  /// Check if profile is complete
  bool get isComplete {
    return weight != null &&
        age != null &&
        gender != Gender.notSpecified &&
        dailyGoal != null;
  }

  /// Calculate water intake goal based on profile data
  int calculateWaterIntake() {
    if (weight == null || age == null) return 2000; // Default

    // Base calculation: 35ml per kg of body weight
    var baseIntake = weight! * 35;

    // Apply multipliers
    baseIntake *= activityLevel.waterMultiplier;
    baseIntake *= weatherPreference.waterMultiplier;
    baseIntake *= pregnancyStatus.waterMultiplier;

    // Apply goal multipliers (take the highest if multiple goals)
    if (goals.isNotEmpty) {
      final maxGoalMultiplier = goals
          .map((goal) => goal.waterMultiplier)
          .reduce((a, b) => a > b ? a : b);
      baseIntake *= maxGoalMultiplier;
    }

    // Age adjustments
    if (age! > 65) {
      baseIntake *= 1.1; // Older adults need more water
    } else if (age! < 18) {
      baseIntake *= 0.9; // Younger people need slightly less
    }

    // Adjust for dietary factors
    if (sugarDrinkIntake > 2) {
      baseIntake *= 1.1; // More water needed to process sugar
    }
    if (vegetableIntake < 3) {
      baseIntake *= 1.05; // Less water from food sources
    }

    return baseIntake.round();
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    double? weight,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    WeatherPreference? weatherPreference,
    List<Goal>? goals,
    PregnancyStatus? pregnancyStatus,
    int? vegetableIntake,
    int? sugarDrinkIntake,
    int? dailyGoal,
    int? customDailyGoal,
    bool? notificationsEnabled,
    List<DateTime>? reminderTimes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      weatherPreference: weatherPreference ?? this.weatherPreference,
      goals: goals ?? this.goals,
      pregnancyStatus: pregnancyStatus ?? this.pregnancyStatus,
      vegetableIntake: vegetableIntake ?? this.vegetableIntake,
      sugarDrinkIntake: sugarDrinkIntake ?? this.sugarDrinkIntake,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      customDailyGoal: customDailyGoal ?? this.customDailyGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'age': age,
      'gender': gender.name,
      'activityLevel': activityLevel.name,
      'weatherPreference': weatherPreference.name,
      'goals': goals.map((g) => g.name).toList(),
      'pregnancyStatus': pregnancyStatus.name,
      'vegetableIntake': vegetableIntake,
      'sugarDrinkIntake': sugarDrinkIntake,
      'dailyGoal': dailyGoal,
      'customDailyGoal': customDailyGoal,
      'notificationsEnabled': notificationsEnabled,
      'reminderTimes':
          reminderTimes.map((t) => t.millisecondsSinceEpoch).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [
    id,
    weight,
    age,
    gender,
    activityLevel,
    weatherPreference,
    goals,
    pregnancyStatus,
    vegetableIntake,
    sugarDrinkIntake,
    dailyGoal,
    customDailyGoal,
    notificationsEnabled,
    reminderTimes,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'UserProfile(id: $id, weight: $weight, age: $age, gender: $gender, goal: $effectiveDailyGoal ml)';
  }
}
