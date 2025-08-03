import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/calculations/water_goal_calculator.dart';
import 'package:watertracker/core/models/user_profile.dart';

void main() {
  group('WaterGoalCalculator', () {
    late UserProfile testProfile;

    setUp(() {
      testProfile = UserProfile.create(id: 'test').copyWith(
        weight: 70.0,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.moderatelyActive,
        pregnancyStatus: PregnancyStatus.notPregnant,
        goals: [Goal.generalHealth],
        vegetableIntake: 3,
        sugarDrinkIntake: 1,
      );
    });

    group('calculateBasicGoal', () {
      test('calculates correct basic goal for valid profile', () {
        final result = WaterGoalCalculator.calculateBasicGoal(testProfile);

        // Expected: 70kg * 35ml/kg * 1.2 (moderately active) * 1.0 (not pregnant)
        // = 2450 * 1.2 = 2940ml
        expect(result, equals(2940));
      });

      test('returns default goal for null weight', () {
        final profileWithoutWeight = UserProfile.create(id: 'test').copyWith(
          age: 30,
          activityLevel: ActivityLevel.moderatelyActive,
          // weight is null by default
        );
        final result = WaterGoalCalculator.calculateBasicGoal(
          profileWithoutWeight,
        );

        expect(result, equals(WaterGoalCalculator.defaultGoal));
      });

      test('returns default goal for invalid weight', () {
        final profileWithInvalidWeight = testProfile.copyWith(weight: 0.0);
        final result = WaterGoalCalculator.calculateBasicGoal(
          profileWithInvalidWeight,
        );

        expect(result, equals(WaterGoalCalculator.defaultGoal));
      });

      test('applies activity level multipliers correctly', () {
        final sedentaryProfile = testProfile.copyWith(
          activityLevel: ActivityLevel.sedentary,
        );
        final veryActiveProfile = testProfile.copyWith(
          activityLevel: ActivityLevel.veryActive,
        );

        final sedentaryResult = WaterGoalCalculator.calculateBasicGoal(
          sedentaryProfile,
        );
        final veryActiveResult = WaterGoalCalculator.calculateBasicGoal(
          veryActiveProfile,
        );

        // Sedentary: 70 * 35 * 1.0 = 2450ml
        expect(sedentaryResult, equals(2450));

        // Very active: 70 * 35 * 1.3 = 3185ml
        expect(veryActiveResult, equals(3185));
      });

      test('applies pregnancy status multipliers correctly', () {
        final pregnantProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.pregnant,
        );
        final breastfeedingProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.breastfeeding,
        );

        final pregnantResult = WaterGoalCalculator.calculateBasicGoal(
          pregnantProfile,
        );
        final breastfeedingResult = WaterGoalCalculator.calculateBasicGoal(
          breastfeedingProfile,
        );

        // Pregnant: 70 * 35 * 1.2 * 1.3 = 3822ml
        expect(pregnantResult, equals(3822));

        // Breastfeeding: 70 * 35 * 1.2 * 1.5 = 4410ml
        expect(breastfeedingResult, equals(4410));
      });
    });

    group('calculateAgeAdjustedGoal', () {
      test('calculates correct goal with age adjustments', () {
        final result = WaterGoalCalculator.calculateAgeAdjustedGoal(
          testProfile,
        );

        // Expected: 70kg * 35ml/kg * 1.2 (activity) * 1.0 (not pregnant) * 1.0 (age 30)
        // = 2940ml
        expect(result, equals(2940));
      });

      test('applies child age adjustment correctly', () {
        final childProfile = testProfile.copyWith(age: 15);
        final result = WaterGoalCalculator.calculateAgeAdjustedGoal(
          childProfile,
        );

        // Expected: 70 * 35 * 1.2 * 1.0 * 0.9 = 2646ml
        expect(result, equals(2646));
      });

      test('applies senior age adjustment correctly', () {
        final seniorProfile = testProfile.copyWith(age: 70);
        final result = WaterGoalCalculator.calculateAgeAdjustedGoal(
          seniorProfile,
        );

        // Expected: 70 * 35 * 1.2 * 1.0 * 1.1 = 3234ml
        expect(result, equals(3234));
      });

      test('applies middle-aged adjustment correctly', () {
        final middleAgedProfile = testProfile.copyWith(age: 55);
        final result = WaterGoalCalculator.calculateAgeAdjustedGoal(
          middleAgedProfile,
        );

        // Expected: 70 * 35 * 1.2 * 1.0 * 1.05 = 3087ml
        expect(result, equals(3087));
      });

      test('returns default goal for invalid age', () {
        final profileWithInvalidAge = UserProfile.create(id: 'test').copyWith(
          weight: 70.0,
          activityLevel: ActivityLevel.moderatelyActive,
          // age is null by default
        );
        final result = WaterGoalCalculator.calculateAgeAdjustedGoal(
          profileWithInvalidAge,
        );

        expect(result, equals(WaterGoalCalculator.defaultGoal));
      });
    });

    group('calculateComprehensiveGoal', () {
      test('calculates correct comprehensive goal', () {
        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          testProfile,
        );

        // Expected: 70 * 35 * 1.2 (activity) * 1.0 (not pregnant) * 1.0 (age 30)
        //          * 1.0 (general health goal) * 1.0 (dietary factors)
        // = 2940ml
        expect(result, equals(2940));
      });

      test('applies goal multipliers correctly', () {
        final athleticProfile = testProfile.copyWith(
          goals: [Goal.athleticPerformance],
        );
        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          athleticProfile,
        );

        // Expected: 70 * 35 * 1.2 * 1.0 * 1.0 * 1.3 (athletic) * 1.0
        // = 3822ml
        expect(result, equals(3822));
      });

      test('uses highest goal multiplier when multiple goals', () {
        final multiGoalProfile = testProfile.copyWith(
          goals: [Goal.weightLoss, Goal.athleticPerformance, Goal.skinHealth],
        );
        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          multiGoalProfile,
        );

        // Should use athletic performance multiplier (1.3) as it's highest
        // Expected: 70 * 35 * 1.2 * 1.0 * 1.0 * 1.3 * 1.0 = 3822ml
        expect(result, equals(3822));
      });

      test('applies dietary adjustments correctly', () {
        final lowVeggieProfile = testProfile.copyWith(
          vegetableIntake: 1, // Low vegetable intake
          sugarDrinkIntake: 3, // High sugar drink intake
        );
        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          lowVeggieProfile,
        );

        // Expected: 70 * 35 * 1.2 * 1.0 * 1.0 * 1.0 * (1.05 * 1.1)
        // = 2940 * 1.155 = 3395.7 ≈ 3396ml
        expect(result, equals(3396));
      });
    });

    group('getEffectiveGoal', () {
      test('returns custom goal when set', () {
        final profileWithCustomGoal = testProfile.copyWith(
          customDailyGoal: 3500,
        );
        final result = WaterGoalCalculator.getEffectiveGoal(
          profileWithCustomGoal,
        );

        expect(result, equals(3500));
      });

      test('returns calculated goal when no custom goal', () {
        final result = WaterGoalCalculator.getEffectiveGoal(testProfile);

        // Should return comprehensive calculation
        expect(result, equals(2940));
      });
    });

    group('boundary checking', () {
      test('enforces minimum daily intake', () {
        final lightProfile = UserProfile.create(id: 'light').copyWith(
          weight: 30.0, // Very light weight
          age: 25,
          activityLevel: ActivityLevel.sedentary,
        );

        final result = WaterGoalCalculator.calculateBasicGoal(lightProfile);

        // Should not go below minimum
        expect(
          result,
          greaterThanOrEqualTo(WaterGoalCalculator.minimumDailyIntake),
        );
      });

      test('enforces maximum daily intake', () {
        final heavyProfile = UserProfile.create(id: 'heavy').copyWith(
          weight: 150.0, // Very heavy weight
          age: 25,
          activityLevel: ActivityLevel.extremelyActive,
          pregnancyStatus: PregnancyStatus.breastfeeding,
          goals: [Goal.athleticPerformance],
        );

        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          heavyProfile,
        );

        // Should not exceed maximum
        expect(
          result,
          lessThanOrEqualTo(WaterGoalCalculator.maximumDailyIntake),
        );
      });
    });

    group('edge cases', () {
      test('handles extreme weight values', () {
        final extremeProfile = testProfile.copyWith(
          weight: 600.0,
        ); // Invalid weight
        final result = WaterGoalCalculator.calculateBasicGoal(extremeProfile);

        expect(result, equals(WaterGoalCalculator.defaultGoal));
      });

      test('handles extreme age values', () {
        final extremeProfile = testProfile.copyWith(age: 200); // Invalid age
        final result = WaterGoalCalculator.calculateAgeAdjustedGoal(
          extremeProfile,
        );

        expect(result, equals(WaterGoalCalculator.defaultGoal));
      });

      test('handles empty goals list', () {
        final noGoalsProfile = testProfile.copyWith(goals: []);
        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          noGoalsProfile,
        );

        // Should work without goals (no goal multiplier applied)
        expect(result, equals(2940));
      });
    });
  });
}
