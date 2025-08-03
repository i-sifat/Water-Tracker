import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/calculations/adjustment_factors.dart';
import 'package:watertracker/core/models/user_profile.dart';

void main() {
  group('AdjustmentFactors', () {
    late UserProfile testProfile;

    setUp(() {
      testProfile = UserProfile.create(id: 'test').copyWith(
        weight: 70.0,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.moderatelyActive,
        pregnancyStatus: PregnancyStatus.notPregnant,
        weatherPreference: WeatherPreference.moderate,
        goals: [Goal.generalHealth],
        vegetableIntake: 3,
        sugarDrinkIntake: 1,
      );
    });

    group('ActivityAdjustment', () {
      const factor = ActivityAdjustment();

      test('returns correct multiplier for different activity levels', () {
        final sedentaryProfile = testProfile.copyWith(
          activityLevel: ActivityLevel.sedentary,
        );
        final veryActiveProfile = testProfile.copyWith(
          activityLevel: ActivityLevel.veryActive,
        );

        expect(factor.getMultiplier(sedentaryProfile), equals(1.0));
        expect(factor.getMultiplier(veryActiveProfile), equals(1.3));
      });

      test('provides correct description', () {
        final sedentaryProfile = testProfile.copyWith(
          activityLevel: ActivityLevel.sedentary,
        );
        final activeProfile = testProfile.copyWith(
          activityLevel: ActivityLevel.veryActive,
        );

        expect(
          factor.getDescription(sedentaryProfile),
          equals('No adjustment for Sedentary'),
        );
        expect(
          factor.getDescription(activeProfile),
          equals('+30% for Very Active'),
        );
      });

      test('always applies to any profile', () {
        expect(factor.appliesTo(testProfile), isTrue);
      });

      test('has correct name', () {
        expect(factor.name, equals('Activity Level'));
      });
    });

    group('AgeAdjustment', () {
      const factor = AgeAdjustment();

      test('returns correct multiplier for different ages', () {
        final childProfile = testProfile.copyWith(age: 15);
        final adultProfile = testProfile.copyWith(age: 30);
        final middleAgedProfile = testProfile.copyWith(age: 55);
        final seniorProfile = testProfile.copyWith(age: 70);

        expect(factor.getMultiplier(childProfile), equals(0.9));
        expect(factor.getMultiplier(adultProfile), equals(1.0));
        expect(factor.getMultiplier(middleAgedProfile), equals(1.05));
        expect(factor.getMultiplier(seniorProfile), equals(1.1));
      });

      test('returns 1.0 for null age', () {
        final profileWithoutAge = UserProfile.create(id: 'test');
        expect(factor.getMultiplier(profileWithoutAge), equals(1.0));
      });

      test('provides correct description', () {
        final childProfile = testProfile.copyWith(age: 15);
        final seniorProfile = testProfile.copyWith(age: 70);

        expect(
          factor.getDescription(childProfile),
          equals('-10% for child (age 15)'),
        );
        expect(
          factor.getDescription(seniorProfile),
          equals('+10% for senior (age 70)'),
        );
      });

      test('applies only when age is specified', () {
        final profileWithAge = testProfile.copyWith(age: 30);
        final profileWithoutAge = UserProfile.create(id: 'test');

        expect(factor.appliesTo(profileWithAge), isTrue);
        expect(factor.appliesTo(profileWithoutAge), isFalse);
      });

      test('has correct name', () {
        expect(factor.name, equals('Age'));
      });
    });

    group('HealthAdjustment', () {
      const factor = HealthAdjustment();

      test('returns correct multiplier for different health statuses', () {
        final notPregnantProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.notPregnant,
        );
        final pregnantProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.pregnant,
        );
        final breastfeedingProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.breastfeeding,
        );

        expect(factor.getMultiplier(notPregnantProfile), equals(1.0));
        expect(factor.getMultiplier(pregnantProfile), equals(1.3));
        expect(factor.getMultiplier(breastfeedingProfile), equals(1.5));
      });

      test('provides correct description', () {
        final pregnantProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.pregnant,
        );

        expect(
          factor.getDescription(pregnantProfile),
          equals('+30% for Pregnant'),
        );
      });

      test('applies only to pregnant or breastfeeding profiles', () {
        final notPregnantProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.notPregnant,
        );
        final pregnantProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.pregnant,
        );
        final preferNotToSayProfile = testProfile.copyWith(
          pregnancyStatus: PregnancyStatus.preferNotToSay,
        );

        expect(factor.appliesTo(notPregnantProfile), isFalse);
        expect(factor.appliesTo(pregnantProfile), isTrue);
        expect(factor.appliesTo(preferNotToSayProfile), isFalse);
      });

      test('has correct name', () {
        expect(factor.name, equals('Health Status'));
      });
    });

    group('GoalAdjustment', () {
      const factor = GoalAdjustment();

      test('returns correct multiplier for different goals', () {
        final generalHealthProfile = testProfile.copyWith(
          goals: [Goal.generalHealth],
        );
        final athleticProfile = testProfile.copyWith(
          goals: [Goal.athleticPerformance],
        );
        final multiGoalProfile = testProfile.copyWith(
          goals: [Goal.weightLoss, Goal.athleticPerformance, Goal.skinHealth],
        );

        expect(factor.getMultiplier(generalHealthProfile), equals(1.0));
        expect(factor.getMultiplier(athleticProfile), equals(1.3));
        // Should use highest multiplier (athletic performance = 1.3)
        expect(factor.getMultiplier(multiGoalProfile), equals(1.3));
      });

      test('returns 1.0 for empty goals', () {
        final noGoalsProfile = testProfile.copyWith(goals: []);
        expect(factor.getMultiplier(noGoalsProfile), equals(1.0));
      });

      test('provides correct description', () {
        final athleticProfile = testProfile.copyWith(
          goals: [Goal.athleticPerformance],
        );
        final multiGoalProfile = testProfile.copyWith(
          goals: [Goal.weightLoss, Goal.athleticPerformance],
        );

        expect(
          factor.getDescription(athleticProfile),
          equals('+30% for Athletic Performance'),
        );
        expect(
          factor.getDescription(multiGoalProfile),
          equals('+30% for Athletic Performance (primary goal)'),
        );
      });

      test('applies only when goals are specified', () {
        final profileWithGoals = testProfile.copyWith(goals: [Goal.weightLoss]);
        final profileWithoutGoals = testProfile.copyWith(goals: []);

        expect(factor.appliesTo(profileWithGoals), isTrue);
        expect(factor.appliesTo(profileWithoutGoals), isFalse);
      });

      test('has correct name', () {
        expect(factor.name, equals('Goals'));
      });
    });

    group('DietaryAdjustment', () {
      const factor = DietaryAdjustment();

      test('returns correct multiplier for dietary factors', () {
        final normalDietProfile = testProfile.copyWith(
          vegetableIntake: 5,
          sugarDrinkIntake: 1,
        );
        final lowVeggieProfile = testProfile.copyWith(
          vegetableIntake: 1,
          sugarDrinkIntake: 1,
        );
        final highSugarProfile = testProfile.copyWith(
          vegetableIntake: 5,
          sugarDrinkIntake: 4,
        );
        final bothProfile = testProfile.copyWith(
          vegetableIntake: 1,
          sugarDrinkIntake: 4,
        );

        expect(factor.getMultiplier(normalDietProfile), equals(1.0));
        expect(factor.getMultiplier(lowVeggieProfile), equals(1.05));
        expect(factor.getMultiplier(highSugarProfile), equals(1.1));
        // Both factors: 1.05 * 1.1 = 1.155
        expect(factor.getMultiplier(bothProfile), closeTo(1.155, 0.001));
      });

      test('provides correct description', () {
        final lowVeggieProfile = testProfile.copyWith(
          vegetableIntake: 1,
          sugarDrinkIntake: 1,
        );
        final bothProfile = testProfile.copyWith(
          vegetableIntake: 1,
          sugarDrinkIntake: 4,
        );

        expect(
          factor.getDescription(lowVeggieProfile),
          equals('+5% for low vegetable intake'),
        );
        expect(
          factor.getDescription(bothProfile),
          equals(
            '+5% for low vegetable intake, +10% for high sugar drink intake',
          ),
        );
      });

      test('applies when dietary factors are present', () {
        final normalProfile = testProfile.copyWith(
          vegetableIntake: 5,
          sugarDrinkIntake: 1,
        );
        final lowVeggieProfile = testProfile.copyWith(
          vegetableIntake: 1,
          sugarDrinkIntake: 1,
        );
        final highSugarProfile = testProfile.copyWith(
          vegetableIntake: 5,
          sugarDrinkIntake: 4,
        );

        expect(factor.appliesTo(normalProfile), isFalse);
        expect(factor.appliesTo(lowVeggieProfile), isTrue);
        expect(factor.appliesTo(highSugarProfile), isTrue);
      });

      test('has correct name', () {
        expect(factor.name, equals('Diet'));
      });
    });

    group('EnvironmentalAdjustment', () {
      const factor = EnvironmentalAdjustment();

      test('returns correct multiplier for weather preferences', () {
        final coldProfile = testProfile.copyWith(
          weatherPreference: WeatherPreference.cold,
        );
        final moderateProfile = testProfile.copyWith(
          weatherPreference: WeatherPreference.moderate,
        );
        final hotProfile = testProfile.copyWith(
          weatherPreference: WeatherPreference.hot,
        );

        expect(factor.getMultiplier(coldProfile), equals(0.9));
        expect(factor.getMultiplier(moderateProfile), equals(1.0));
        expect(factor.getMultiplier(hotProfile), equals(1.2));
      });

      test('provides correct description', () {
        final coldProfile = testProfile.copyWith(
          weatherPreference: WeatherPreference.cold,
        );
        final hotProfile = testProfile.copyWith(
          weatherPreference: WeatherPreference.hot,
        );

        expect(
          factor.getDescription(coldProfile),
          equals('-10% for Cold Weather'),
        );
        expect(
          factor.getDescription(hotProfile),
          equals('+20% for Hot Weather'),
        );
      });

      test('always applies to any profile', () {
        expect(factor.appliesTo(testProfile), isTrue);
      });

      test('has correct name', () {
        expect(factor.name, equals('Environment'));
      });
    });

    group('AdjustmentFactorCombiner', () {
      test('calculates combined multiplier correctly', () {
        final complexProfile = testProfile.copyWith(
          activityLevel: ActivityLevel.veryActive, // 1.3x
          age: 70, // 1.1x
          pregnancyStatus: PregnancyStatus.notPregnant, // 1.0x (doesn't apply)
          goals: [Goal.athleticPerformance], // 1.3x
          vegetableIntake: 1, // 1.05x (low veggies)
          sugarDrinkIntake: 4, // 1.1x (high sugar)
          weatherPreference: WeatherPreference.hot, // 1.2x
        );

        final result = AdjustmentFactorCombiner.calculateCombinedMultiplier(
          complexProfile,
        );

        // Expected: 1.3 * 1.1 * 1.3 * 1.05 * 1.1 * 1.2 = 2.5765740...
        expect(result, closeTo(2.577, 0.01));
      });

      test('returns 1.0 for profile with no applicable factors', () {
        // Create a profile where only non-applicable factors exist
        final minimalProfile = UserProfile.create(id: 'minimal').copyWith(
          activityLevel: ActivityLevel.sedentary, // 1.0x
          pregnancyStatus: PregnancyStatus.notPregnant, // doesn't apply
          weatherPreference: WeatherPreference.moderate, // 1.0x
          goals: [], // doesn't apply
          vegetableIntake: 5, // doesn't apply
          sugarDrinkIntake: 1, // doesn't apply
          // age is null, so doesn't apply
        );

        final result = AdjustmentFactorCombiner.calculateCombinedMultiplier(
          minimalProfile,
        );

        // Only activity (1.0) and environment (1.0) apply
        expect(result, equals(1.0));
      });

      test('gets adjustment breakdown correctly', () {
        final activeProfile = testProfile.copyWith(
          activityLevel: ActivityLevel.veryActive,
          age: 25,
          goals: [Goal.athleticPerformance],
        );

        final breakdown = AdjustmentFactorCombiner.getAdjustmentBreakdown(
          activeProfile,
        );

        expect(breakdown, hasLength(4)); // Activity, Age, Goals, Environment
        expect(breakdown['Activity Level']?.multiplier, equals(1.3));
        expect(breakdown['Age']?.multiplier, equals(1.0));
        expect(breakdown['Goals']?.multiplier, equals(1.3));
        expect(breakdown['Environment']?.multiplier, equals(1.0));
      });

      test('gets applicable factors correctly', () {
        final profileWithSomeFactors = testProfile.copyWith(
          age: 30, // applies
          pregnancyStatus: PregnancyStatus.notPregnant, // doesn't apply
          goals: [Goal.weightLoss], // applies
          vegetableIntake: 5, // doesn't apply
          sugarDrinkIntake: 1, // doesn't apply
        );

        final applicableFactors = AdjustmentFactorCombiner.getApplicableFactors(
          profileWithSomeFactors,
        );

        final factorNames = applicableFactors.map((f) => f.name).toList();
        expect(
          factorNames,
          containsAll(['Activity Level', 'Age', 'Goals', 'Environment']),
        );
        expect(factorNames, isNot(contains('Health Status')));
        expect(factorNames, isNot(contains('Diet')));
      });
    });

    group('AdjustmentFactorInfo', () {
      test('calculates percentage change correctly', () {
        const info1 = AdjustmentFactorInfo(
          name: 'Test',
          multiplier: 1.0,
          description: 'No change',
        );
        const info2 = AdjustmentFactorInfo(
          name: 'Test',
          multiplier: 1.3,
          description: 'Increase',
        );
        const info3 = AdjustmentFactorInfo(
          name: 'Test',
          multiplier: 0.9,
          description: 'Decrease',
        );

        expect(info1.percentageChange, equals('No change'));
        expect(info2.percentageChange, equals('+30%'));
        expect(info3.percentageChange, equals('-10%'));
      });

      test('toString provides readable format', () {
        const info = AdjustmentFactorInfo(
          name: 'Activity Level',
          multiplier: 1.3,
          description: 'Very Active',
        );

        expect(info.toString(), equals('Activity Level: +30% (Very Active)'));
      });
    });
  });
}
