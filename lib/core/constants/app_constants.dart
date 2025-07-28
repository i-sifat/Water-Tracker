class AppConstants {
  // App Information
  static const String appName = 'Water Tracker';
  static const String appVersion = '0.1.4';

  // Storage Keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String selectedGenderKey = 'selected_gender';
  static const String selectedGoalsKey = 'selected_goals';
  static const String userAgeKey = 'user_age';
  static const String userWeightKey = 'user_weight';
  static const String weightUnitIsKgKey = 'weight_unit_is_kg';
  static const String fitnessLevelKey = 'fitness_level';
  static const String vegetableFrequencyKey = 'vegetable_frequency';
  static const String weatherPreferenceKey = 'weather_preference';

  // Notification Keys
  static const String notificationWaterReminderKey =
      'notification_water_reminder';
  static const String notificationHealthTipsKey = 'notification_health_tips';
  static const String notificationSmartAssistantKey =
      'notification_smart_assistant';

  // Default Values
  static const double defaultWeight = 65;
  static const int defaultAge = 25;
  static const int defaultDailyGoal = 2000; // ml

  // Limits
  static const double minWeight = 0;
  static const double maxWeight = 150;
  static const int minAge = 1;
  static const int maxAge = 120;
}
