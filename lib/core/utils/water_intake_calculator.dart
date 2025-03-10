import 'package:shared_preferences/shared_preferences.dart';

class WaterIntakeCalculator {
  /// Calculates the recommended daily water intake based on user data
  static Future<int> calculateWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve user data with scientifically-backed default values
    final weight =
        prefs.getDouble('user_weight') ?? 70.0; // Average adult weight
    final isKg = prefs.getBool('weight_unit_is_kg') ?? true;
    final age = prefs.getInt('user_age') ?? 30; // Average adult age
    final isMale = prefs.getString('selected_gender') == 'male';
    final activityLevel =
        prefs.getInt('fitness_level') ?? 1; // Moderate activity
    final weather = prefs.getString('weather_preference') ?? 'normal';
    final isPregnant = prefs.getString('pregnancy_status') == 'pregnancy';
    final isBreastfeeding =
        prefs.getString('pregnancy_status') == 'breastfeeding';
    final vegetableIntake = prefs.getString('vegetable_frequency') ?? 'rarely';
    final sugaryDrinks =
        prefs.getString('sugary_beverages_frequency') ?? 'rarely';
    final goals = prefs.getStringList('selected_goals') ?? [];

    // Convert weight to kg if stored in lbs
    final weightInKg = isKg ? weight : weight * 0.45359237;

    // Base calculation using standard formula (35ml per kg of body weight)
    // Source: Institute of Medicine recommendations
    var baseIntake = weightInKg * 35;

    // Age-based adjustments
    // Source: National Academy of Medicine guidelines
    if (age > 65) {
      baseIntake *= 0.9; // Reduced needs for elderly
    } else if (age < 18) {
      baseIntake *= 1.1; // Increased needs for teenagers
    }

    // Gender-based adjustments
    // Source: WHO recommendations
    if (isMale) {
      baseIntake *= 1.1; // Men typically need more water
    }

    // Activity level adjustments
    // Source: American Council on Exercise
    switch (activityLevel) {
      case 0: // Sedentary
        baseIntake *= 1.0;
      case 1: // Moderate
        baseIntake *= 1.2;
      case 2: // Active
        baseIntake *= 1.4;
    }

    // Weather-based adjustments
    // Source: Sports Medicine research
    switch (weather) {
      case 'hot':
        baseIntake *= 1.3; // Increased needs in hot weather
      case 'cold':
        baseIntake *= 0.9; // Slightly reduced needs in cold weather
      default: // normal
        baseIntake *= 1.0;
    }

    // Special conditions adjustments
    // Source: American Pregnancy Association
    if (isPregnant) {
      baseIntake *= 1.3; // Increased needs during pregnancy
    } else if (isBreastfeeding) {
      baseIntake *= 1.4; // Increased needs during breastfeeding
    }

    // Dietary habits adjustments
    // Source: Journal of Nutrition studies
    switch (vegetableIntake) {
      case 'rarely':
        baseIntake *= 1.1; // Need more water due to less water from vegetables
      case 'often':
        baseIntake *= 0.95; // Getting water from vegetables
      case 'regularly':
        baseIntake *= 0.9; // Getting more water from vegetables
    }

    // Sugary drinks impact
    // Source: American Journal of Clinical Nutrition
    switch (sugaryDrinks) {
      case 'often':
        baseIntake *= 1.2; // Need more water to compensate
      case 'regularly':
        baseIntake *= 1.15;
      case 'rarely':
        baseIntake *= 1.05;
    }

    // Goals-based adjustments
    // Source: Sports Medicine research
    if (goals.contains('Lose weight')) {
      baseIntake *= 1.1; // Increased water intake helps with weight loss
    }
    if (goals.contains('Improve digestions')) {
      baseIntake *= 1.05;
    }

    // Ensure minimum intake
    // Source: WHO minimum recommendations
    final minimumIntake = isMale ? 2000.0 : 1600.0;
    if (baseIntake < minimumIntake) {
      baseIntake = minimumIntake;
    }

    // Round to nearest 100ml for user-friendly number
    return ((baseIntake / 100).round() * 100).toInt();
  }
}
