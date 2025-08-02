import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/goal_factors.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_entry.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

void main() {
  group('HydrationProvider Task 12 - New Functionality Tests', () {
    late HydrationProvider provider;

    setUp(() {
      provider = HydrationProvider();
    });

    group('Hydration Entry Management', () {
      test('should manage hydration entries and progress', () async {
        // Test adding hydration using existing method
        await provider.addHydration(250);

        expect(provider.currentIntake, equals(250));
        expect(provider.intakePercentage, greaterThan(0));
      });

      test('should support different drink types and water content', () async {
        // Test water (100% water content)
        await provider.addHydration(250);
        final waterIntake = provider.currentIntake;

        // Reset for next test
        provider.resetDailyData();

        // Test coffee (90% water content)
        await provider.addHydration(250, type: DrinkType.coffee);
        final coffeeIntake = provider.currentIntake;

        // Coffee should contribute less water content than pure water
        expect(coffeeIntake, lessThan(waterIntake));
      });
    });

    group('Goal Calculation Logic', () {
      test('should handle goal factors', () {
        // Test default goal factors
        final factors = provider.goalFactors;
        expect(factors, isNotNull);
        expect(factors.baseRequirement, greaterThan(0));
      });

      test('should calculate daily goal correctly', () {
        final dailyGoal = provider.dailyGoal;
        expect(dailyGoal, greaterThan(0));
        expect(dailyGoal, lessThanOrEqualTo(5000)); // Reasonable upper limit
      });

      test('should update goal factors', () async {
        const newFactors = GoalFactors(
          baseRequirement: 2500,
          activityLevel: ActivityLevel.veryActive,
          climateCondition: ClimateCondition.hot,
        );

        await provider.updateGoalFactors(newFactors);

        expect(provider.goalFactors.baseRequirement, equals(2500));
        expect(
          provider.goalFactors.activityLevel,
          equals(ActivityLevel.veryActive),
        );
        expect(
          provider.goalFactors.climateCondition,
          equals(ClimateCondition.hot),
        );
      });
    });

    group('Data Persistence', () {
      test('should persist entries and user preferences', () async {
        // Add some hydration
        await provider.addHydration(300, type: DrinkType.tea);

        // Set drink type preference
        await provider.setSelectedDrinkType(DrinkType.juice);

        expect(provider.currentIntake, equals(300));
        expect(provider.selectedDrinkType, equals(DrinkType.juice));
      });

      test('should handle data refresh', () async {
        // Add initial data
        await provider.addHydration(200);
        final initialIntake = provider.currentIntake;

        // Refresh data
        await provider.refreshData();

        // Data should be maintained
        expect(provider.isInitialized, isTrue);
        expect(provider.currentIntake, equals(initialIntake));
      });
    });

    group('Real-time Progress Updates', () {
      test('should update progress in real-time', () async {
        final initialProgress = provider.intakePercentage;

        // Add hydration
        await provider.addHydration(500);

        final updatedProgress = provider.intakePercentage;
        expect(updatedProgress, greaterThan(initialProgress));
      });

      test('should calculate reminder times', () async {
        // Add some hydration but not reach goal
        await provider.addHydration(500);

        // Should have a next reminder time if goal not reached
        if (!provider.goalReachedToday) {
          expect(provider.nextReminderTime, isNotNull);
        }
      });
    });

    group('Statistics and Analytics', () {
      test('should provide weekly data', () {
        final weekStart = DateTime.now().subtract(const Duration(days: 7));
        final weeklyData = provider.getWeeklyData(weekStart);

        expect(weeklyData, isNotNull);
        expect(weeklyData.length, equals(7));
      });

      test('should track most used drink types', () {
        final mostUsed = provider.getMostUsedDrinkTypes();

        expect(mostUsed, isNotNull);
        expect(mostUsed.length, lessThanOrEqualTo(3));
      });

      test('should track streaks', () {
        expect(provider.currentStreak, greaterThanOrEqualTo(0));
        expect(
          provider.longestStreak,
          greaterThanOrEqualTo(provider.currentStreak),
        );
      });
    });

    group('Error Handling', () {
      test('should handle invalid amounts gracefully', () async {
        // Test with zero amount
        await provider.addHydration(0);

        // Should not crash
        expect(provider.currentIntake, greaterThanOrEqualTo(0));
      });

      test('should maintain data consistency', () {
        final initialGoal = provider.dailyGoal;
        final initialIntake = provider.currentIntake;

        // Data should be consistent
        expect(initialGoal, greaterThan(0));
        expect(initialIntake, greaterThanOrEqualTo(0));
        expect(provider.remainingIntake, greaterThanOrEqualTo(0));
      });
    });
  });
}
