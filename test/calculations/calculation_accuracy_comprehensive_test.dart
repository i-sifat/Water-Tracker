import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/calculations/water_goal_calculator.dart';
import 'package:watertracker/core/calculations/adjustment_factors.dart';
import 'package:watertracker/core/calculations/advanced_water_calculator.dart';
import 'package:watertracker/core/models/user_profile.dart';

void main() {
  group('Calculation Accuracy Comprehensive Tests', () {
    group('Boundary Value Analysis', () {
      group('Weight Boundaries', () {
        test('should handle minimum valid weight (30kg)', () {
          final profile = UserProfile.create(id: 'min_weight').copyWith(
            weight: 30,
            age: 25,
            activityLevel: ActivityLevel.sedentary,
          );

          final result = WaterGoalCalculator.calculateBasicGoal(profile);

          // 30kg * 35ml/kg * 1.0 (sedentary) = 1050ml
          // Should be adjusted to minimum daily intake
          expect(
            result,
            greaterThanOrEqualTo(WaterGoalCalculator.minimumDailyIntake),
          );
          expect(
            result,
            equals(WaterGoalCalculator.minimumDailyIntake),
          ); // Should use minimum
        });

        test('should handle maximum valid weight (200kg)', () {
          final profile = UserProfile.create(id: 'max_weight').copyWith(
            weight: 200,
            age: 25,
            activityLevel: ActivityLevel.extremelyActive,
            pregnancyStatus: PregnancyStatus.breastfeeding,
            goals: [Goal.athleticPerformance],
          );

          final result = WaterGoalCalculator.calculateComprehensiveGoal(
            profile,
          );

          // Should be capped at maximum daily intake
          expect(
            result,
            lessThanOrEqualTo(WaterGoalCalculator.maximumDailyIntake),
          );
        });

        test('should reject invalid weights', () {
          final invalidWeights = [0, -10, 300, 500];

          for (final weight in invalidWeights) {
            final profile = UserProfile.create(id: 'invalid_$weight').copyWith(
              weight: weight.toDouble(),
              age: 25,
              activityLevel: ActivityLevel.moderatelyActive,
            );

            final result = WaterGoalCalculator.calculateBasicGoal(profile);
            expect(result, equals(WaterGoalCalculator.defaultGoal));
          }
        });

        test('should handle edge case weights near boundaries', () {
          final edgeCases = [29.9, 30.1, 199.9, 200.1];

          for (final weight in edgeCases) {
            final profile = UserProfile.create(id: 'edge_$weight').copyWith(
              weight: weight,
              age: 25,
              activityLevel: ActivityLevel.moderatelyActive,
            );

            final result = WaterGoalCalculator.calculateBasicGoal(profile);

            if (weight < 30 || weight > 200) {
              expect(result, equals(WaterGoalCalculator.defaultGoal));
            } else {
              expect(result, greaterThan(0));
              expect(
                result,
                lessThanOrEqualTo(WaterGoalCalculator.maximumDailyIntake),
              );
            }
          }
        });
      });

      group('Age Boundaries', () {
        test('should handle minimum valid age (1 year)', () {
          final profile = UserProfile.create(id: 'min_age').copyWith(
            weight: 50,
            age: 1,
            activityLevel: ActivityLevel.sedentary,
          );

          final result = WaterGoalCalculator.calculateAgeAdjustedGoal(profile);

          // Should apply child adjustment (0.9x)
          expect(result, greaterThan(0));
          expect(
            result,
            lessThan(WaterGoalCalculator.calculateBasicGoal(profile)),
          );
        });

        test('should handle maximum valid age (120 years)', () {
          final profile = UserProfile.create(id: 'max_age').copyWith(
            weight: 70,
            age: 120,
            activityLevel: ActivityLevel.sedentary,
          );

          final result = WaterGoalCalculator.calculateAgeAdjustedGoal(profile);

          // Should apply senior adjustment (1.1x)
          expect(result, greaterThan(0));
          expect(
            result,
            greaterThan(WaterGoalCalculator.calculateBasicGoal(profile)),
          );
        });

        test('should reject invalid ages', () {
          final invalidAges = [0, -5, 150, 200];

          for (final age in invalidAges) {
            final profile = UserProfile.create(id: 'invalid_age_$age').copyWith(
              weight: 70,
              age: age,
              activityLevel: ActivityLevel.moderatelyActive,
            );

            final result = WaterGoalCalculator.calculateAgeAdjustedGoal(
              profile,
            );
            expect(result, equals(WaterGoalCalculator.defaultGoal));
          }
        });

        test('should handle age transition boundaries correctly', () {
          final ageTransitions = [
            (17, 18), // Child to adult
            (49, 50), // Adult to middle-aged
            (64, 65), // Middle-aged to senior
          ];

          for (final (youngAge, oldAge) in ageTransitions) {
            final youngProfile = UserProfile.create(
              id: 'young_$youngAge',
            ).copyWith(
              weight: 70,
              age: youngAge,
              activityLevel: ActivityLevel.moderatelyActive,
            );

            final oldProfile = UserProfile.create(id: 'old_$oldAge').copyWith(
              weight: 70,
              age: oldAge,
              activityLevel: ActivityLevel.moderatelyActive,
            );

            final youngResult = WaterGoalCalculator.calculateAgeAdjustedGoal(
              youngProfile,
            );
            final oldResult = WaterGoalCalculator.calculateAgeAdjustedGoal(
              oldProfile,
            );

            // Results should be different across age boundaries
            expect(youngResult, isNot(equals(oldResult)));
          }
        });
      });
    });

    group('Calculation Precision Tests', () {
      test('should maintain precision in complex calculations', () {
        final profile = UserProfile.create(id: 'precision_test').copyWith(
          weight: 73.5,
          age: 32,
          activityLevel: ActivityLevel.veryActive,
          pregnancyStatus: PregnancyStatus.pregnant,
          goals: [Goal.athleticPerformance],
          vegetableIntake: 2,
          sugarDrinkIntake: 3,
        );

        final result = WaterGoalCalculator.calculateComprehensiveGoal(profile);

        // Manual calculation:
        // Base: 73.5 * 35 = 2572.5ml
        // Activity (very active): 2572.5 * 1.3 = 3344.25ml
        // Pregnancy: 3344.25 * 1.3 = 4347.525ml
        // Age (32): 4347.525 * 1.0 = 4347.525ml
        // Goal (athletic): 4347.525 * 1.3 = 5651.7825ml (capped at max)
        // Dietary: low veggies (1.05) + high sugar (1.1) = 1.155
        // Final: min(5651.7825 * 1.155, max) = min(6527.8, 5000) = 5000ml

        expect(result, equals(WaterGoalCalculator.maximumDailyIntake));
      });

      test('should handle floating point precision correctly', () {
        final profile = UserProfile.create(id: 'float_test').copyWith(
          weight: 70.333333,
          age: 25,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        final result = WaterGoalCalculator.calculateBasicGoal(profile);

        // Should handle floating point without precision errors
        expect(result, isA<int>());
        expect(result, greaterThan(0));

        // Calculate expected value manually
        final expected = (70.333333 * 35 * 1.2).round();
        expect(result, equals(expected));
      });

      test('should produce consistent results for identical inputs', () {
        final profile = UserProfile.create(id: 'consistency_test').copyWith(
          weight: 75,
          age: 30,
          activityLevel: ActivityLevel.moderatelyActive,
          goals: [Goal.weightLoss],
        );

        final results = <int>[];

        // Calculate same profile multiple times
        for (int i = 0; i < 100; i++) {
          final result = WaterGoalCalculator.calculateComprehensiveGoal(
            profile,
          );
          results.add(result);
        }

        // All results should be identical
        expect(results.toSet().length, equals(1));
        expect(results.first, greaterThan(0));
      });
    });

    group('Edge Case Combinations', () {
      test('should handle extreme combination of factors', () {
        final extremeProfile = UserProfile.create(id: 'extreme').copyWith(
          weight: 200,
          age: 120,
          activityLevel: ActivityLevel.extremelyActive,
          pregnancyStatus: PregnancyStatus.breastfeeding,
          goals: [Goal.athleticPerformance, Goal.skinHealth],
          vegetableIntake: 1,
          sugarDrinkIntake: 5,
          weatherPreference: WeatherPreference.hot,
        );

        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          extremeProfile,
        );

        // Should be capped at maximum
        expect(result, equals(WaterGoalCalculator.maximumDailyIntake));
        expect(result, lessThanOrEqualTo(5000));
      });

      test('should handle minimal combination of factors', () {
        final minimalProfile = UserProfile.create(id: 'minimal').copyWith(
          weight: 30,
          age: 1,
          activityLevel: ActivityLevel.sedentary,
          pregnancyStatus: PregnancyStatus.notPregnant,
          goals: [],
          vegetableIntake: 5,
          sugarDrinkIntake: 0,
          weatherPreference: WeatherPreference.cold,
        );

        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          minimalProfile,
        );

        // Should be at minimum
        expect(result, equals(WaterGoalCalculator.minimumDailyIntake));
        expect(result, greaterThanOrEqualTo(1500));
      });

      test('should handle null and missing values gracefully', () {
        final incompleteProfile = UserProfile.create(id: 'incomplete');
        // Most fields are null by default

        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          incompleteProfile,
        );

        // Should return default goal
        expect(result, equals(WaterGoalCalculator.defaultGoal));
      });

      test('should handle contradictory profile data', () {
        final contradictoryProfile = UserProfile.create(
          id: 'contradictory',
        ).copyWith(
          weight: 40, // Very light
          age: 80, // Senior
          activityLevel:
              ActivityLevel.extremelyActive, // Very active despite age
          pregnancyStatus: PregnancyStatus.breastfeeding, // Unlikely at 80
          goals: [Goal.athleticPerformance], // Contradicts age
        );

        final result = WaterGoalCalculator.calculateComprehensiveGoal(
          contradictoryProfile,
        );

        // Should still produce a valid result
        expect(result, greaterThan(0));
        expect(
          result,
          lessThanOrEqualTo(WaterGoalCalculator.maximumDailyIntake),
        );
      });
    });

    group('Adjustment Factor Accuracy', () {
      test('should calculate activity adjustments precisely', () {
        final testCases = [
          (ActivityLevel.sedentary, 1.0),
          (ActivityLevel.lightlyActive, 1.1),
          (ActivityLevel.moderatelyActive, 1.2),
          (ActivityLevel.veryActive, 1.3),
          (ActivityLevel.extremelyActive, 1.4),
        ];

        for (final (level, expectedMultiplier) in testCases) {
          final profile = UserProfile.create(
            id: 'activity_test',
          ).copyWith(weight: 70, activityLevel: level);

          const factor = ActivityAdjustment();
          final multiplier = factor.getMultiplier(profile);

          expect(multiplier, equals(expectedMultiplier));
        }
      });

      test('should calculate age adjustments precisely', () {
        final testCases = [
          (15, 0.9), // Child
          (25, 1.0), // Young adult
          (35, 1.0), // Adult
          (55, 1.05), // Middle-aged
          (70, 1.1), // Senior
        ];

        for (final (age, expectedMultiplier) in testCases) {
          final profile = UserProfile.create(id: 'age_test').copyWith(age: age);

          const factor = AgeAdjustment();
          final multiplier = factor.getMultiplier(profile);

          expect(multiplier, equals(expectedMultiplier));
        }
      });

      test('should calculate combined adjustments correctly', () {
        final profile = UserProfile.create(id: 'combined_test').copyWith(
          weight: 70,
          age: 30,
          activityLevel: ActivityLevel.veryActive, // 1.3x
          pregnancyStatus: PregnancyStatus.pregnant, // 1.3x
          goals: [Goal.athleticPerformance], // 1.3x
          vegetableIntake: 1, // 1.05x
          sugarDrinkIntake: 4, // 1.1x
          weatherPreference: WeatherPreference.hot, // 1.2x
        );

        final combinedMultiplier =
            AdjustmentFactorCombiner.calculateCombinedMultiplier(profile);

        // Expected: 1.3 * 1.0 * 1.3 * 1.3 * 1.05 * 1.1 * 1.2 = 2.8765740
        expect(combinedMultiplier, closeTo(2.877, 0.01));
      });
    });

    group('Advanced Calculator Edge Cases', () {
      test('should handle extreme environmental conditions', () {
        final profile = UserProfile.create(id: 'env_test').copyWith(
          weight: 70,
          age: 30,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        final extremeFactors = [
          const TemperatureFactor(-40), // Extreme cold
          const HumidityFactor(100), // Maximum humidity
          const AltitudeFactor(8000), // Very high altitude
        ];

        final result = AdvancedWaterCalculator.calculateAdvancedIntake(
          profile,
          environmentalFactors: extremeFactors,
        );

        // Should still produce reasonable result
        expect(result, greaterThan(1000));
        expect(result, lessThanOrEqualTo(5000));
      });

      test('should handle invalid activity parameters', () {
        final invalidCases = [
          (ActivityType.running, 0, 70.0), // Zero duration
          (ActivityType.running, 60, 0.0), // Zero weight
          (ActivityType.running, -30, 70.0), // Negative duration
          (ActivityType.running, 60, -70.0), // Negative weight
        ];

        for (final (type, duration, weight) in invalidCases) {
          final result = AdvancedWaterCalculator.calculateActivityHydration(
            activityType: type,
            durationMinutes: duration,
            bodyWeight: weight,
          );

          expect(result, equals(0));
        }
      });

      test('should handle extreme activity parameters', () {
        final result = AdvancedWaterCalculator.calculateActivityHydration(
          activityType: ActivityType.running,
          durationMinutes: 600, // 10 hours
          bodyWeight: 150,
          intensityLevel: 10,
        );

        // Should be capped at safety limit
        expect(result, lessThanOrEqualTo(2000));
      });
    });

    group('Input Validation Tests', () {
      test('should validate weight input ranges', () {
        final validWeights = [30, 50, 70, 100, 150, 200];
        final invalidWeights = [-10, 0, 29, 201, 500, 1000];

        for (final weight in validWeights) {
          final profile = UserProfile.create(id: 'valid_$weight').copyWith(
            weight: weight.toDouble(),
            age: 30,
            activityLevel: ActivityLevel.moderatelyActive,
          );

          final result = WaterGoalCalculator.calculateBasicGoal(profile);
          expect(result, isNot(equals(WaterGoalCalculator.defaultGoal)));
        }

        for (final weight in invalidWeights) {
          final profile = UserProfile.create(id: 'invalid_$weight').copyWith(
            weight: weight.toDouble(),
            age: 30,
            activityLevel: ActivityLevel.moderatelyActive,
          );

          final result = WaterGoalCalculator.calculateBasicGoal(profile);
          expect(result, equals(WaterGoalCalculator.defaultGoal));
        }
      });

      test('should validate age input ranges', () {
        final validAges = [1, 5, 18, 30, 50, 65, 80, 120];
        final invalidAges = [-5, 0, 121, 150, 200];

        for (final age in validAges) {
          final profile = UserProfile.create(id: 'valid_age_$age').copyWith(
            weight: 70,
            age: age,
            activityLevel: ActivityLevel.moderatelyActive,
          );

          final result = WaterGoalCalculator.calculateAgeAdjustedGoal(profile);
          expect(result, isNot(equals(WaterGoalCalculator.defaultGoal)));
        }

        for (final age in invalidAges) {
          final profile = UserProfile.create(id: 'invalid_age_$age').copyWith(
            weight: 70,
            age: age,
            activityLevel: ActivityLevel.moderatelyActive,
          );

          final result = WaterGoalCalculator.calculateAgeAdjustedGoal(profile);
          expect(result, equals(WaterGoalCalculator.defaultGoal));
        }
      });

      test('should handle special numeric values', () {
        final specialValues = [
          double.nan,
          double.infinity,
          double.negativeInfinity,
        ];

        for (final value in specialValues) {
          final profile = UserProfile.create(id: 'special_$value').copyWith(
            weight: value,
            age: 30,
            activityLevel: ActivityLevel.moderatelyActive,
          );

          final result = WaterGoalCalculator.calculateBasicGoal(profile);
          expect(result, equals(WaterGoalCalculator.defaultGoal));
        }
      });
    });

    group('Calculation Consistency Tests', () {
      test('should maintain calculation order independence', () {
        final profile = UserProfile.create(id: 'order_test').copyWith(
          weight: 70,
          age: 30,
          activityLevel: ActivityLevel.veryActive,
          pregnancyStatus: PregnancyStatus.pregnant,
          goals: [Goal.athleticPerformance],
        );

        // Calculate using different methods
        final basicResult = WaterGoalCalculator.calculateBasicGoal(profile);
        final ageAdjustedResult = WaterGoalCalculator.calculateAgeAdjustedGoal(
          profile,
        );
        final comprehensiveResult =
            WaterGoalCalculator.calculateComprehensiveGoal(profile);

        // Results should follow expected hierarchy
        expect(basicResult, lessThanOrEqualTo(ageAdjustedResult));
        expect(ageAdjustedResult, lessThanOrEqualTo(comprehensiveResult));
      });

      test('should produce monotonic results for increasing factors', () {
        final baseProfile = UserProfile.create(
          id: 'monotonic_test',
        ).copyWith(weight: 70, age: 30, activityLevel: ActivityLevel.sedentary);

        final activityLevels = [
          ActivityLevel.sedentary,
          ActivityLevel.lightlyActive,
          ActivityLevel.moderatelyActive,
          ActivityLevel.veryActive,
          ActivityLevel.extremelyActive,
        ];

        int previousResult = 0;

        for (final level in activityLevels) {
          final profile = baseProfile.copyWith(activityLevel: level);
          final result = WaterGoalCalculator.calculateBasicGoal(profile);

          expect(result, greaterThanOrEqualTo(previousResult));
          previousResult = result;
        }
      });
    });

    group('Performance Under Edge Conditions', () {
      test('should handle large number of calculations efficiently', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          final profile = UserProfile.create(id: 'perf_test_$i').copyWith(
            weight: 50 + (i % 100),
            age: 20 + (i % 80),
            activityLevel:
                ActivityLevel.values[i % ActivityLevel.values.length],
          );

          WaterGoalCalculator.calculateComprehensiveGoal(profile);
        }

        stopwatch.stop();

        // Should complete within reasonable time (less than 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should handle concurrent calculations correctly', () {
        final futures = <Future<int>>[];

        for (int i = 0; i < 100; i++) {
          final future = Future(() {
            final profile = UserProfile.create(id: 'concurrent_$i').copyWith(
              weight: (60 + i).toDouble(),
              age: 25,
              activityLevel: ActivityLevel.moderatelyActive,
            );

            return WaterGoalCalculator.calculateBasicGoal(profile);
          });

          futures.add(future);
        }

        return Future.wait(futures).then((results) {
          // All results should be valid
          for (final result in results) {
            expect(result, greaterThan(0));
            expect(
              result,
              lessThanOrEqualTo(WaterGoalCalculator.maximumDailyIntake),
            );
          }

          // Results should be different (different weights)
          expect(results.toSet().length, greaterThan(1));
        });
      });
    });
  });
}
