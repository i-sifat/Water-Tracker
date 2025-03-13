import 'package:shared_preferences/shared_preferences.dart';

class WaterIntakeCalculator {
  /// Calculates the recommended daily water intake based on user data
  static Future<int> calculateWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Get user data
    final weight = prefs.getDouble('user_weight') ?? 70.0;
    final isKg = prefs.getBool('weight_unit_is_kg') ?? true;
    final age = prefs.getInt('user_age') ?? 30;
    final isMale = prefs.getString('selected_gender') == 'male';
    final activityLevel = prefs.getInt('fitness_level') ?? 1;
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

    // 2. Calculate baseline based on age
    double baseIntake;
    if (age < 4) {
      baseIntake = 1300.0; // 1.3L for ages 1-3
    } else if (age < 9) {
      baseIntake = 1700.0; // 1.7L for ages 4-8
    } else if (age < 14) {
      baseIntake = isMale ? 2400.0 : 2100.0; // 2.1-2.4L for ages 9-13
    } else if (age < 18) {
      baseIntake = isMale ? 3300.0 : 2300.0; // 2.3-3.3L for ages 14-17
    } else {
      // Adults: Calculate using weight-based formula with minimum thresholds
      final weightBasedIntake = weightInKg * 35;
      baseIntake =
          isMale
              ? weightBasedIntake.clamp(3700.0, double.infinity)
              : weightBasedIntake.clamp(2700.0, double.infinity);
    }

    // 3. Apply goal-based adjustments
    if (goals.contains('Drink More Water')) {
      baseIntake += 200;
    }
    if (goals.contains('Improve digestion')) {
      baseIntake += 300;
    }
    if (goals.contains('Lose weight')) {
      baseIntake += 500;
    }

    // 4. Activity level adjustments (Fixed switch case)
    switch (activityLevel) {
      case 2: // Frequent
        baseIntake += 700;
      case 1: // Medium
        baseIntake += 400;
      case 0: // 2-3x Weekly
        baseIntake += 250;
    }

    // 5. Dietary adjustments (Fixed switch case)
    switch (vegetableIntake.toLowerCase()) {
      case 'regularly':
        baseIntake -= 200; // More hydration from food
      case 'rarely':
        baseIntake += 400; // Less hydration from food
    }

    switch (sugaryDrinks.toLowerCase()) {
      case 'regularly':
        baseIntake += 500; // Need more water to compensate
      case 'rarely':
        baseIntake += 200;
    }

    // 6. Weather/temperature adjustments (Fixed switch case)
    switch (weather.toLowerCase()) {
      case 'hot': // Above 25°C
        baseIntake += 500;
      case 'cold': // Below 20°C
        baseIntake -= 200;
    }

    // 7. Special conditions for females
    if (!isMale) {
      if (isPregnant) {
        baseIntake += 300;
      } else if (isBreastfeeding) {
        baseIntake += 700;
      }
    }

    // 8. Ensure minimum safe intake
    final minimumIntake = isMale ? 2000.0 : 1600.0;
    if (baseIntake < minimumIntake) {
      baseIntake = minimumIntake;
    }

    // Round to nearest 100ml for user-friendly number
    return (baseIntake / 100).round() * 100;
  }
}
