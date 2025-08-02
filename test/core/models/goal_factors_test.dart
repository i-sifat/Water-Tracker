import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/goal_factors.dart';

void main() {
  group('ActivityLevel', () {
    test('should have correct display names', () {
      expect(ActivityLevel.sedentary.displayName, equals('Sedentary'));
      expect(ActivityLevel.lightlyActive.displayName, equals('Lightly Active'));
      expect(
        ActivityLevel.moderatelyActive.displayName,
        equals('Moderately Active'),
      );
      expect(ActivityLevel.veryActive.displayName, equals('Very Active'));
      expect(
        ActivityLevel.extremelyActive.displayName,
        equals('Extremely Active'),
      );
    });

    test('should have correct adjustment factors', () {
      expect(ActivityLevel.sedentary.adjustmentFactor, equals(0));
      expect(ActivityLevel.lightlyActive.adjustmentFactor, equals(200));
      expect(ActivityLevel.moderatelyActive.adjustmentFactor, equals(400));
      expect(ActivityLevel.veryActive.adjustmentFactor, equals(600));
      expect(ActivityLevel.extremelyActive.adjustmentFactor, equals(800));
    });
  });

  group('ClimateCondition', () {
    test('should have correct display names', () {
      expect(ClimateCondition.cold.displayName, equals('Cold'));
      expect(ClimateCondition.temperate.displayName, equals('Temperate'));
      expect(ClimateCondition.warm.displayName, equals('Warm'));
      expect(ClimateCondition.hot.displayName, equals('Hot'));
      expect(ClimateCondition.veryHot.displayName, equals('Very Hot'));
    });

    test('should have correct adjustment factors', () {
      expect(ClimateCondition.cold.adjustmentFactor, equals(-100));
      expect(ClimateCondition.temperate.adjustmentFactor, equals(0));
      expect(ClimateCondition.warm.adjustmentFactor, equals(200));
      expect(ClimateCondition.hot.adjustmentFactor, equals(400));
      expect(ClimateCondition.veryHot.adjustmentFactor, equals(600));
    });
  });

  group('GoalFactors', () {
    test('should create instance with required fields', () {
      const factors = GoalFactors(baseRequirement: 2000);

      expect(factors.baseRequirement, equals(2000));
      expect(factors.activityLevel, equals(ActivityLevel.moderatelyActive));
      expect(factors.climateCondition, equals(ClimateCondition.temperate));
      expect(factors.healthAdjustment, equals(0));
      expect(factors.customAdjustment, equals(0));
    });

    test('should create instance with all fields', () {
      const factors = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.veryActive,
        climateCondition: ClimateCondition.hot,
        healthAdjustment: 200,
        customAdjustment: 100,
      );

      expect(factors.baseRequirement, equals(2000));
      expect(factors.activityLevel, equals(ActivityLevel.veryActive));
      expect(factors.climateCondition, equals(ClimateCondition.hot));
      expect(factors.healthAdjustment, equals(200));
      expect(factors.customAdjustment, equals(100));
    });

    test('should calculate activity adjustment correctly', () {
      const factors = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.veryActive,
      );

      expect(factors.activityAdjustment, equals(600));
    });

    test('should calculate climate adjustment correctly', () {
      const factors = GoalFactors(
        baseRequirement: 2000,
        climateCondition: ClimateCondition.hot,
      );

      expect(factors.climateAdjustment, equals(400));
    });

    test('should calculate total goal correctly', () {
      const factors = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.veryActive, // +600
        climateCondition: ClimateCondition.hot, // +400
        healthAdjustment: 200,
        customAdjustment: 100,
      );

      // 2000 + 600 + 400 + 200 + 100 = 3300
      expect(factors.totalGoal, equals(3300));
    });

    test('should handle negative adjustments in total goal', () {
      const factors = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.sedentary, // +0
        climateCondition: ClimateCondition.cold, // -100
        healthAdjustment: -50,
        customAdjustment: -25,
      );

      // 2000 + 0 + (-100) + (-50) + (-25) = 1825
      expect(factors.totalGoal, equals(1825));
    });

    test('should provide correct breakdown', () {
      const factors = GoalFactors(
        baseRequirement: 2000,
        climateCondition: ClimateCondition.warm, // +200
        healthAdjustment: 100,
        customAdjustment: 50,
      );

      final breakdown = factors.breakdown;
      expect(breakdown['Base Requirement'], equals(2000));
      expect(breakdown['Activity Level'], equals(400));
      expect(breakdown['Climate'], equals(200));
      expect(breakdown['Health'], equals(100));
      expect(breakdown['Custom'], equals(50));
      expect(breakdown['Total'], equals(2750));
    });

    test('should create default factors for user', () {
      final factors = GoalFactors.defaultForUser();

      expect(factors.baseRequirement, equals(2450)); // 70kg * 35ml
      expect(factors.activityLevel, equals(ActivityLevel.moderatelyActive));
      expect(factors.climateCondition, equals(ClimateCondition.temperate));
      expect(factors.healthAdjustment, equals(0));
      expect(factors.customAdjustment, equals(0));
    });

    test('should create default factors for user with custom weight', () {
      final factors = GoalFactors.defaultForUser(weight: 80);

      expect(factors.baseRequirement, equals(2800)); // 80kg * 35ml
    });

    test('should create copy with updated fields', () {
      const original = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.sedentary,
        climateCondition: ClimateCondition.cold,
      );

      final copy = original.copyWith(
        activityLevel: ActivityLevel.veryActive,
        healthAdjustment: 200,
      );

      expect(copy.baseRequirement, equals(2000)); // unchanged
      expect(copy.activityLevel, equals(ActivityLevel.veryActive));
      expect(copy.climateCondition, equals(ClimateCondition.cold)); // unchanged
      expect(copy.healthAdjustment, equals(200));
      expect(copy.customAdjustment, equals(0)); // unchanged
    });

    test('should serialize to JSON correctly', () {
      const factors = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.veryActive,
        climateCondition: ClimateCondition.hot,
        healthAdjustment: 200,
        customAdjustment: 100,
      );

      final json = factors.toJson();
      expect(json['baseRequirement'], equals(2000));
      expect(json['activityLevel'], equals('veryActive'));
      expect(json['climateCondition'], equals('hot'));
      expect(json['healthAdjustment'], equals(200));
      expect(json['customAdjustment'], equals(100));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'baseRequirement': 2000,
        'activityLevel': 'veryActive',
        'climateCondition': 'hot',
        'healthAdjustment': 200,
        'customAdjustment': 100,
      };

      final factors = GoalFactors.fromJson(json);
      expect(factors.baseRequirement, equals(2000));
      expect(factors.activityLevel, equals(ActivityLevel.veryActive));
      expect(factors.climateCondition, equals(ClimateCondition.hot));
      expect(factors.healthAdjustment, equals(200));
      expect(factors.customAdjustment, equals(100));
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'baseRequirement': 2000,
        'activityLevel': 'moderatelyActive',
        'climateCondition': 'temperate',
      };

      final factors = GoalFactors.fromJson(json);
      expect(factors.baseRequirement, equals(2000));
      expect(factors.activityLevel, equals(ActivityLevel.moderatelyActive));
      expect(factors.climateCondition, equals(ClimateCondition.temperate));
      expect(factors.healthAdjustment, equals(0));
      expect(factors.customAdjustment, equals(0));
    });

    test('should handle invalid enum values in JSON', () {
      final json = {
        'baseRequirement': 2000,
        'activityLevel': 'invalidActivity',
        'climateCondition': 'invalidClimate',
      };

      final factors = GoalFactors.fromJson(json);
      expect(factors.baseRequirement, equals(2000));
      expect(
        factors.activityLevel,
        equals(ActivityLevel.moderatelyActive),
      ); // fallback
      expect(
        factors.climateCondition,
        equals(ClimateCondition.temperate),
      ); // fallback
    });

    test('should implement equality correctly', () {
      const factors1 = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.veryActive,
        climateCondition: ClimateCondition.hot,
      );

      const factors2 = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.veryActive,
        climateCondition: ClimateCondition.hot,
      );

      const factors3 = GoalFactors(
        baseRequirement: 2500,
        activityLevel: ActivityLevel.veryActive,
        climateCondition: ClimateCondition.hot,
      );

      expect(factors1, equals(factors2));
      expect(factors1, isNot(equals(factors3)));
    });

    test('should have meaningful toString', () {
      const factors = GoalFactors(
        baseRequirement: 2000,
        activityLevel: ActivityLevel.veryActive,
        climateCondition: ClimateCondition.hot,
      );

      final string = factors.toString();
      expect(string, contains('2000ml'));
      expect(string, contains('3000ml')); // total goal
      expect(string, contains('Very Active'));
      expect(string, contains('Hot'));
    });
  });
}
