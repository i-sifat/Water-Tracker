import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/calculations/water_goal_calculator.dart';
import 'package:watertracker/core/calculations/adjustment_factors.dart';
import 'package:watertracker/core/calculations/advanced_water_calculator.dart';
import 'package:watertracker/core/models/user_profile.dart';

void main() {
  group('Calculation Property-Based Tests', () {
    final random = Random(42); // Fixed seed for reproducible tests

    group('Mathematical Properties', () {
      test('should satisfy monotonicity property for weight', () {
        // Property: Increasing weight should never decrease water goal
        for (int i = 0; i < 100; i++) {
          final baseWeight = 40 + random.nextDouble() * 100; // 40-140kg
          final higherWeight =
              baseWeight + 10 + random.nextDouble() * 50; // +10-60kg

          final baseProfile = UserProfile.create(id: 'mono_base_$i').copyWith(
            weight: baseWeight,
            age: 25,
            activityLevel: ActivityLevel.moderatelyActive,
          );

          final higherProfile = baseProfile.copyWith(weight: higherWeight);

          final baseResult = WaterGoalCalculator.calculateBasicGoal(
            baseProfile,
          );
          final higherResult = WaterGoalCalculator.calculateBasicGoal(
            higherProfile,
          );

          expect(
            higherResult,
            greaterThanOrEqualTo(baseResult),
            reason:
                'Weight $higherWeight should not produce lower goal than $baseWeight',
          );
        }
      });

      test('should satisfy monotonicity property for activity level', () {
        // Property: Higher activity level should never decrease water goal
        final activityLevels = ActivityLevel.values;

        for (int i = 0; i < 50; i++) {
          final weight = 50 + random.nextDouble() * 100;
          final age = 18 + random.nextInt(60);

          int previousResult = 0;

          for (final level in activityLevels) {
            final profile = UserProfile.create(
              id: 'activity_mono_$i',
            ).copyWith(weight: weight, age: age, activityLevel: level);

            final result = WaterGoalCalculator.calculateBasicGoal(profile);

            expect(
              result,
              greaterThanOrEqualTo(previousResult),
              reason:
                  'Activity level $level should not produce lower goal than previous level',
            );

            previousResult = result;
          }
        }
      });

      test('should satisfy scaling property', () {
        // Property: Doubling weight should approximately double the base calculation
        // (before adjustments and bounds)
        for (int i = 0; i < 50; i++) {
          final baseWeight = 50 + random.nextDouble() * 50; // 50-100kg
          final doubleWeight = baseWeight * 2;

          // Use minimal profile to avoid adjustment factors
          final baseProfile = UserProfile.create(id: 'scale_base_$i').copyWith(
            weight: baseWeight,
            age: 25,
            activityLevel: ActivityLevel.sedentary, // 1.0x multiplier
            pregnancyStatus: PregnancyStatus.notPregnant,
            goals: [],
            vegetableIntake: 5, // No dietary adjustment
            sugarDrinkIntake: 1,
            weatherPreference: WeatherPreference.moderate, // 1.0x multiplier
          );

          final doubleProfile = baseProfile.copyWith(weight: doubleWeight);

          final baseResult = WaterGoalCalculator.calculateBasicGoal(
            baseProfile,
          );
          final doubleResult = WaterGoalCalculator.calculateBasicGoal(
            doubleProfile,
          );

          // Allow for rounding and bounds, but should be approximately double
          if (doubleResult < WaterGoalCalculator.maximumDailyIntake) {
            final ratio = doubleResult / baseResult;
            expect(
              ratio,
              closeTo(2.0, 0.1),
              reason: 'Doubling weight should approximately double result',
            );
          }
        }
      });

      test('should satisfy bounds property', () {
        // Property: All calculations should be within defined bounds
        for (int i = 0; i < 200; i++) {
          final profile = _generateRandomProfile(random, i);

          final basicResult = WaterGoalCalculator.calculateBasicGoal(profile);
          final ageAdjustedResult =
              WaterGoalCalculator.calculateAgeAdjustedGoal(profile);
          final comprehensiveResult =
              WaterGoalCalculator.calculateComprehensiveGoal(profile);

          final results = [basicResult, ageAdjustedResult, comprehensiveResult];

          for (final result in results) {
            expect(
              result,
              greaterThanOrEqualTo(WaterGoalCalculator.minimumDailyIntake),
              reason: 'Result should not be below minimum',
            );
            expect(
              result,
              lessThanOrEqualTo(WaterGoalCalculator.maximumDailyIntake),
              reason: 'Result should not exceed maximum',
            );
          }
        }
      });

      test('should satisfy consistency property', () {
        // Property: Same input should always produce same output
        for (int i = 0; i < 50; i++) {
          final profile = _generateRandomProfile(random, i);

          final results = <int>[];

          // Calculate same profile multiple times
          for (int j = 0; j < 10; j++) {
            final result = WaterGoalCalculator.calculateComprehensiveGoal(
              profile,
            );
            results.add(result);
          }

          // All results should be identical
          expect(
            results.toSet().length,
            equals(1),
            reason: 'Same profile should always produce same result',
          );
        }
      });
    });

    group('Adjustment Factor Properties', () {
      test('should satisfy multiplier bounds property', () {
        // Property: All multipliers should be positive and reasonable
        for (int i = 0; i < 100; i++) {
          final profile = _generateRandomProfile(random, i);

          final factors = [
            const ActivityAdjustment(),
            const AgeAdjustment(),
            const HealthAdjustment(),
            const GoalAdjustment(),
            const DietaryAdjustment(),
            const EnvironmentalAdjustment(),
          ];

          for (final factor in factors) {
            final multiplier = factor.getMultiplier(profile);

            expect(
              multiplier,
              greaterThan(0),
              reason: '${factor.name} multiplier should be positive',
            );
            expect(
              multiplier,
              lessThan(3.0),
              reason: '${factor.name} multiplier should be reasonable',
            );
          }
        }
      });

      test('should satisfy combination property', () {
        // Property: Combined multiplier should equal product of individual multipliers
        for (int i = 0; i < 50; i++) {
          final profile = _generateRandomProfile(random, i);

          final combinedMultiplier =
              AdjustmentFactorCombiner.calculateCombinedMultiplier(profile);

          final factors = AdjustmentFactorCombiner.getApplicableFactors(
            profile,
          );
          final expectedMultiplier = factors.fold<double>(
            1.0,
            (product, factor) => product * factor.getMultiplier(profile),
          );

          expect(
            combinedMultiplier,
            closeTo(expectedMultiplier, 0.001),
            reason:
                'Combined multiplier should equal product of individual multipliers',
          );
        }
      });

      test('should satisfy identity property for default values', () {
        // Property: Default/neutral values should not change the base calculation
        final neutralProfile = UserProfile.create(id: 'neutral').copyWith(
          weight: 70,
          age: 30, // Adult age (1.0x)
          activityLevel: ActivityLevel.sedentary, // 1.0x
          pregnancyStatus: PregnancyStatus.notPregnant, // Doesn't apply
          goals: [], // Doesn't apply
          vegetableIntake: 5, // High (no adjustment)
          sugarDrinkIntake: 1, // Low (no adjustment)
          weatherPreference: WeatherPreference.moderate, // 1.0x
        );

        final basicResult = WaterGoalCalculator.calculateBasicGoal(
          neutralProfile,
        );
        final comprehensiveResult =
            WaterGoalCalculator.calculateComprehensiveGoal(neutralProfile);

        // Should be equal since no adjustments apply
        expect(basicResult, equals(comprehensiveResult));
      });
    });

    group('Advanced Calculator Properties', () {
      test('should satisfy environmental factor bounds', () {
        // Property: Environmental factors should produce reasonable multipliers
        for (int i = 0; i < 100; i++) {
          final temperature = -20 + random.nextDouble() * 70; // -20°C to 50°C
          final humidity = random.nextDouble() * 100; // 0% to 100%
          final altitude = random.nextInt(6000); // 0m to 6000m

          final tempFactor = TemperatureFactor(temperature);
          final humidityFactor = HumidityFactor(humidity);
          final altitudeFactor = AltitudeFactor(altitude);

          final tempMultiplier = tempFactor.getMultiplier();
          final humidityMultiplier = humidityFactor.getMultiplier();
          final altitudeMultiplier = altitudeFactor.getMultiplier();

          expect(tempMultiplier, greaterThan(0.5));
          expect(tempMultiplier, lessThan(2.0));
          expect(humidityMultiplier, greaterThanOrEqualTo(1.0));
          expect(humidityMultiplier, lessThan(1.5));
          expect(altitudeMultiplier, greaterThanOrEqualTo(1.0));
          expect(altitudeMultiplier, lessThan(1.5));
        }
      });

      test('should satisfy activity hydration scaling property', () {
        // Property: Longer duration should increase hydration needs
        final activityTypes = ActivityType.values;

        for (final activityType in activityTypes) {
          for (int i = 0; i < 20; i++) {
            final weight = 50 + random.nextDouble() * 100;
            final baseDuration = 30 + random.nextInt(60); // 30-90 minutes
            final longerDuration =
                baseDuration + 30 + random.nextInt(60); // +30-90 minutes

            final baseResult =
                AdvancedWaterCalculator.calculateActivityHydration(
                  activityType: activityType,
                  durationMinutes: baseDuration,
                  bodyWeight: weight,
                );

            final longerResult =
                AdvancedWaterCalculator.calculateActivityHydration(
                  activityType: activityType,
                  durationMinutes: longerDuration,
                  bodyWeight: weight,
                );

            expect(
              longerResult,
              greaterThanOrEqualTo(baseResult),
              reason: 'Longer duration should not decrease hydration needs',
            );
          }
        }
      });

      test('should satisfy activity hydration bounds property', () {
        // Property: Activity hydration should be within reasonable bounds
        for (int i = 0; i < 100; i++) {
          final activityType =
              ActivityType.values[random.nextInt(ActivityType.values.length)];
          final duration = 15 + random.nextInt(300); // 15-315 minutes
          final weight = 40 + random.nextDouble() * 160; // 40-200kg
          final intensity = 1 + random.nextInt(10); // 1-10

          final result = AdvancedWaterCalculator.calculateActivityHydration(
            activityType: activityType,
            durationMinutes: duration,
            bodyWeight: weight,
            intensityLevel: intensity,
          );

          expect(result, greaterThanOrEqualTo(0));
          expect(result, lessThanOrEqualTo(2000)); // Safety bound
        }
      });
    });

    group('Invariant Properties', () {
      test('should maintain calculation invariants under profile changes', () {
        // Property: Certain relationships should always hold
        for (int i = 0; i < 50; i++) {
          final baseProfile = _generateRandomProfile(random, i);

          // Create variations of the profile
          final lighterProfile = baseProfile.copyWith(
            weight: (baseProfile.weight ?? 70) * 0.8,
          );
          final heavierProfile = baseProfile.copyWith(
            weight: (baseProfile.weight ?? 70) * 1.2,
          );

          final lighterResult = WaterGoalCalculator.calculateBasicGoal(
            lighterProfile,
          );
          final baseResult = WaterGoalCalculator.calculateBasicGoal(
            baseProfile,
          );
          final heavierResult = WaterGoalCalculator.calculateBasicGoal(
            heavierProfile,
          );

          // Invariant: Results should be ordered by weight
          expect(lighterResult, lessThanOrEqualTo(baseResult));
          expect(baseResult, lessThanOrEqualTo(heavierResult));
        }
      });

      test('should maintain adjustment factor invariants', () {
        // Property: Adjustment factors should maintain certain relationships
        for (int i = 0; i < 50; i++) {
          final profile = _generateRandomProfile(random, i);

          const activityFactor = ActivityAdjustment();
          const ageFactor = AgeAdjustment();

          final activityMultiplier = activityFactor.getMultiplier(profile);
          final ageMultiplier = ageFactor.getMultiplier(profile);

          // Invariant: Activity factor should have more impact than age factor
          if (profile.activityLevel == ActivityLevel.extremelyActive) {
            expect(activityMultiplier, greaterThan(1.2));
          }

          // Invariant: Age factor should be close to 1.0 for most ages
          if (profile.age != null && profile.age! >= 18 && profile.age! <= 50) {
            expect(ageMultiplier, closeTo(1.0, 0.1));
          }
        }
      });
    });

    group('Regression Properties', () {
      test('should not regress on known good values', () {
        // Property: Known good combinations should produce expected results
        final knownGoodCases = [
          (
            70.0,
            30,
            ActivityLevel.moderatelyActive,
            2940,
          ), // 70 * 35 * 1.2 * 1.0
          (60.0, 25, ActivityLevel.sedentary, 2100), // 60 * 35 * 1.0 * 1.0
          (80.0, 35, ActivityLevel.veryActive, 3640), // 80 * 35 * 1.3 * 1.0
        ];

        for (final (weight, age, activity, expected) in knownGoodCases) {
          final profile = UserProfile.create(id: 'known_good').copyWith(
            weight: weight,
            age: age,
            activityLevel: activity,
            pregnancyStatus: PregnancyStatus.notPregnant,
            goals: [],
            vegetableIntake: 5,
            sugarDrinkIntake: 1,
            weatherPreference: WeatherPreference.moderate,
          );

          final result = WaterGoalCalculator.calculateBasicGoal(profile);

          expect(
            result,
            equals(expected),
            reason: 'Known good case should produce expected result',
          );
        }
      });

      test('should maintain backward compatibility', () {
        // Property: Results should be stable across different calculation methods
        for (int i = 0; i < 30; i++) {
          final profile = _generateRandomProfile(random, i);

          // Calculate using different methods
          final basicResult = WaterGoalCalculator.calculateBasicGoal(profile);
          final effectiveResult = WaterGoalCalculator.getEffectiveGoal(profile);

          // If no custom goal is set, effective should match calculated
          if (profile.customDailyGoal == null) {
            final comprehensiveResult =
                WaterGoalCalculator.calculateComprehensiveGoal(profile);
            expect(effectiveResult, equals(comprehensiveResult));
          }

          // Basic result should be foundation for other calculations
          expect(basicResult, greaterThan(0));
        }
      });
    });
  });
}

// Helper function to generate random but valid profiles
UserProfile _generateRandomProfile(Random random, int seed) {
  return UserProfile.create(id: 'random_$seed').copyWith(
    weight: 40 + random.nextDouble() * 160, // 40-200kg
    age: 1 + random.nextInt(120), // 1-120 years
    gender: Gender.values[random.nextInt(Gender.values.length)],
    activityLevel:
        ActivityLevel.values[random.nextInt(ActivityLevel.values.length)],
    pregnancyStatus:
        PregnancyStatus.values[random.nextInt(PregnancyStatus.values.length)],
    goals: _generateRandomGoals(random),
    vegetableIntake: random.nextInt(6), // 0-5
    sugarDrinkIntake: random.nextInt(6), // 0-5
    weatherPreference:
        WeatherPreference.values[random.nextInt(
          WeatherPreference.values.length,
        )],
    customDailyGoal: random.nextBool() ? 2000 + random.nextInt(2000) : null,
  );
}

List<Goal> _generateRandomGoals(Random random) {
  final allGoals = Goal.values;
  final goalCount = random.nextInt(4); // 0-3 goals
  final selectedGoals = <Goal>[];

  for (int i = 0; i < goalCount; i++) {
    final goal = allGoals[random.nextInt(allGoals.length)];
    if (!selectedGoals.contains(goal)) {
      selectedGoals.add(goal);
    }
  }

  return selectedGoals;
}
