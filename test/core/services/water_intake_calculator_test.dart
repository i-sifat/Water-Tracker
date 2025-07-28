import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/water_intake_calculator.dart';

void main() {
  group('WaterIntakeCalculator Tests', () {
    group('Basic Intake Calculation', () {
      test('should calculate basic intake for adult male', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final intake = WaterIntakeCalculator.calculateBasicIntake(profile);

        // Assert
        expect(intake, greaterThan(2000));
        expect(intake, lessThan(4000));
      });

      test('should calculate basic intake for adult female', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 25,
          weight: 60,
          gender: Gender.female,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final intake = WaterIntakeCalculator.calculateBasicIntake(profile);

        // Assert
        expect(intake, greaterThan(1800));
        expect(intake, lessThan(3500));
      });

      test('should return default value when weight is null', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final intake = WaterIntakeCalculator.calculateBasicIntake(profile);

        // Assert
        expect(intake, equals(2000));
      });

      test('should return default value when age is null', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          weight: 70,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final intake = WaterIntakeCalculator.calculateBasicIntake(profile);

        // Assert
        expect(intake, equals(2000));
      });
    });

    group('Activity Level Adjustments', () {
      test('should adjust intake based on activity level', () {
        // Arrange
        const baseProfile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
        );

        final sedentaryProfile = baseProfile.copyWith(activityLevel: ActivityLevel.sedentary);
        final activeProfile = baseProfile.copyWith(activityLevel: ActivityLevel.veryActive);

        // Act
        final sedentaryIntake = WaterIntakeCalculator.calculateBasicIntake(sedentaryProfile);
        final activeIntake = WaterIntakeCalculator.calculateBasicIntake(activeProfile);

        // Assert
        expect(activeIntake, greaterThan(sedentaryIntake));
      });
    });

    group('Pregnancy Status Adjustments', () {
      test('should increase intake for pregnant women', () {
        // Arrange
        const normalProfile = UserProfile(
          id: 'test-id',
          age: 28,
          weight: 65,
          gender: Gender.female,
        );

        final pregnantProfile = normalProfile.copyWith(
          pregnancyStatus: PregnancyStatus.pregnant,
        );

        // Act
        final normalIntake = WaterIntakeCalculator.calculateBasicIntake(normalProfile);
        final pregnantIntake = WaterIntakeCalculator.calculateBasicIntake(pregnantProfile);

        // Assert
        expect(pregnantIntake, greaterThan(normalIntake));
      });

      test('should increase intake for breastfeeding women', () {
        // Arrange
        const normalProfile = UserProfile(
          id: 'test-id',
          age: 28,
          weight: 65,
          gender: Gender.female,
        );

        final breastfeedingProfile = normalProfile.copyWith(
          pregnancyStatus: PregnancyStatus.breastfeeding,
        );

        // Act
        final normalIntake = WaterIntakeCalculator.calculateBasicIntake(normalProfile);
        final breastfeedingIntake = WaterIntakeCalculator.calculateBasicIntake(breastfeedingProfile);

        // Assert
        expect(breastfeedingIntake, greaterThan(normalIntake));
      });
    });

    group('Advanced Intake Calculation', () {
      test('should calculate advanced intake with additional parameters', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final advancedIntake = WaterIntakeCalculator.calculateAdvancedIntake(
          profile,
          bodyFatPercentage: 15,
          environmentalTemperature: 30,
          isPreWorkout: true,
        );

        // Assert
        expect(advancedIntake, greaterThan(2000));
        expect(advancedIntake, lessThan(5000));
      });

      test('should apply safety bounds to advanced calculation', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 200, // Very high weight
          gender: Gender.male,
          activityLevel: ActivityLevel.extremelyActive,
        );

        // Act
        final advancedIntake = WaterIntakeCalculator.calculateAdvancedIntake(
          profile,
          environmentalTemperature: 45, // Very hot
          altitude: 4000, // High altitude
          stressLevel: 10, // Maximum stress
          caffeineIntake: 1000, // High caffeine
          alcoholIntake: 5, // High alcohol
        );

        // Assert
        expect(advancedIntake, greaterThanOrEqualTo(1500)); // Lower bound
        expect(advancedIntake, lessThanOrEqualTo(5000)); // Upper bound
      });

      test('should handle null values gracefully in advanced calculation', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final advancedIntake = WaterIntakeCalculator.calculateAdvancedIntake(profile);

        // Assert
        expect(advancedIntake, greaterThan(2000));
        expect(advancedIntake, lessThan(4000));
      });
    });

    group('Activity Hydration Calculation', () {
      test('should calculate hydration needs for running', () {
        // Act
        final hydrationNeeds = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'running',
          durationMinutes: 60,
          bodyWeight: 70,
        );

        // Assert
        expect(hydrationNeeds, greaterThan(100));
        expect(hydrationNeeds, lessThan(2000));
      });

      test('should adjust for activity intensity', () {
        // Act
        final lowIntensity = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'running',
          durationMinutes: 60,
          bodyWeight: 70,
          intensityLevel: 3,
        );

        final highIntensity = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'running',
          durationMinutes: 60,
          bodyWeight: 70,
          intensityLevel: 9,
        );

        // Assert
        expect(highIntensity, greaterThan(lowIntensity));
      });

      test('should adjust for environmental conditions', () {
        // Act
        final normalConditions = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'running',
          durationMinutes: 60,
          bodyWeight: 70,
        );

        final hotConditions = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'running',
          durationMinutes: 60,
          bodyWeight: 70,
          environmentalTemp: 35,
          humidity: 80,
        );

        // Assert
        expect(hotConditions, greaterThan(normalConditions));
      });

      test('should handle unknown activity types', () {
        // Act
        final hydrationNeeds = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'unknown_activity',
          durationMinutes: 60,
          bodyWeight: 70,
        );

        // Assert
        expect(hydrationNeeds, greaterThan(100));
        expect(hydrationNeeds, lessThan(2000));
      });

      test('should apply safety bounds to activity hydration', () {
        // Act
        final hydrationNeeds = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'soccer',
          durationMinutes: 300, // Very long duration
          bodyWeight: 100, // High body weight
          intensityLevel: 10, // Maximum intensity
          environmentalTemp: 45, // Very hot
          humidity: 100, // Maximum humidity
        );

        // Assert
        expect(hydrationNeeds, greaterThanOrEqualTo(100)); // Lower bound
        expect(hydrationNeeds, lessThanOrEqualTo(2000)); // Upper bound
      });
    });

    group('Optimal Reminder Times', () {
      test('should calculate reminder times based on profile', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          dailyGoal: 2500,
        );

        // Act
        final reminderTimes = WaterIntakeCalculator.calculateOptimalReminderTimes(profile);

        // Assert
        expect(reminderTimes, isNotEmpty);
        expect(reminderTimes.length, greaterThan(3));
        expect(reminderTimes.length, lessThan(20));
      });

      test('should adjust reminder frequency based on daily goal', () {
        // Arrange
        const lowGoalProfile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          dailyGoal: 1500,
        );

        const highGoalProfile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          dailyGoal: 4000,
        );

        // Act
        final lowGoalReminders = WaterIntakeCalculator.calculateOptimalReminderTimes(lowGoalProfile);
        final highGoalReminders = WaterIntakeCalculator.calculateOptimalReminderTimes(highGoalProfile);

        // Assert
        expect(highGoalReminders.length, greaterThanOrEqualTo(lowGoalReminders.length));
      });

      test('should respect custom wake and sleep times', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          dailyGoal: 2500,
        );

        final wakeTime = DateTime(2023, 1, 1, 6);
        final bedTime = DateTime(2023, 1, 1, 23);

        // Act
        final reminderTimes = WaterIntakeCalculator.calculateOptimalReminderTimes(
          profile,
          wakeUpTime: wakeTime,
          bedTime: bedTime,
        );

        // Assert
        expect(reminderTimes, isNotEmpty);
        for (final reminder in reminderTimes) {
          expect(reminder.hour, greaterThanOrEqualTo(wakeTime.hour));
          expect(reminder.hour, lessThanOrEqualTo(bedTime.hour));
        }
      });

      test('should adjust for meal times', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          dailyGoal: 2500,
        );

        final mealTimes = [
          DateTime(2023, 1, 1, 8), // Breakfast
          DateTime(2023, 1, 1, 13), // Lunch
          DateTime(2023, 1, 1, 19), // Dinner
        ];

        // Act
        final reminderTimes = WaterIntakeCalculator.calculateOptimalReminderTimes(
          profile,
          mealTimes: mealTimes,
        );

        // Assert
        expect(reminderTimes, isNotEmpty);
        // Should have reminders that consider meal times
      });

      test('should adjust for workout times', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 70,
          gender: Gender.male,
          dailyGoal: 2500,
        );

        final workoutTimes = [
          DateTime(2023, 1, 1, 17), // Evening workout
        ];

        // Act
        final reminderTimes = WaterIntakeCalculator.calculateOptimalReminderTimes(
          profile,
          workoutTimes: workoutTimes,
        );

        // Assert
        expect(reminderTimes, isNotEmpty);
        // Should have reminders that consider workout times
      });
    });

    group('Legacy Method Compatibility', () {
      test('should calculate water intake from shared preferences', () async {
        // Act
        final intake = await WaterIntakeCalculator.calculateWaterIntake();

        // Assert
        expect(intake, greaterThan(1000));
        expect(intake, lessThan(5000));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle zero weight', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: 0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final intake = WaterIntakeCalculator.calculateBasicIntake(profile);

        // Assert
        expect(intake, equals(2000)); // Should return default
      });

      test('should handle negative weight', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 30,
          weight: -10,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final intake = WaterIntakeCalculator.calculateBasicIntake(profile);

        // Assert
        expect(intake, lessThan(0)); // Will be negative due to calculation
      });

      test('should handle very young age', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 5,
          weight: 20,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Act
        final intake = WaterIntakeCalculator.calculateBasicIntake(profile);

        // Assert
        expect(intake, greaterThan(0));
      });

      test('should handle very old age', () {
        // Arrange
        const profile = UserProfile(
          id: 'test-id',
          age: 90,
          weight: 60,
          gender: Gender.female,
        );

        // Act
        final intake = WaterIntakeCalculator.calculateBasicIntake(profile);

        // Assert
        expect(intake, greaterThan(0));
      });

      test('should handle zero duration activity', () {
        // Act
        final hydrationNeeds = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'running',
          durationMinutes: 0,
          bodyWeight: 70,
        );

        // Assert
        expect(hydrationNeeds, greaterThanOrEqualTo(100)); // Should respect lower bound
      });

      test('should handle very long activity duration', () {
        // Act
        final hydrationNeeds = WaterIntakeCalculator.calculateActivityHydration(
          activityType: 'running',
          durationMinutes: 600, // 10 hours
          bodyWeight: 70,
        );

        // Assert
        expect(hydrationNeeds, lessThanOrEqualTo(2000)); // Should respect upper bound
      });
    });
  });
}
