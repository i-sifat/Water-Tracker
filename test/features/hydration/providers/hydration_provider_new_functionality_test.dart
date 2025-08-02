import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/goal_factors.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_entry.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

void main() {
  group('HydrationProvider New Functionality Tests', () {
    late HydrationProvider provider;

    setUp(() {
      provider = HydrationProvider();
    });

    group('Hydration Entry Management', () {
      test('should add hydration entry using new model', () async {
        // Create a new hydration entry
        final entry = HydrationEntry(
          id: 'test-entry-1',
          amount: 250,
          type: DrinkType.water,
          timestamp: DateTime.now(),
          waterContentMl: 250,
        );

        // Add the entry
        await provider.addHydrationEntry(entry);

        // Verify the entry was added
        final todaysEntries = provider.getTodaysEntries();
        expect(todaysEntries, contains(entry));
        expect(provider.currentIntake, equals(250));
      });

      test("should get today's entries correctly", () async {
        final now = DateTime.now();
        final todayEntry = HydrationEntry(
          id: 'today-entry',
          amount: 300,
          type: DrinkType.water,
          timestamp: now,
          waterContentMl: 300,
        );

        final yesterdayEntry = HydrationEntry(
          id: 'yesterday-entry',
          amount: 200,
          type: DrinkType.water,
          timestamp: now.subtract(const Duration(days: 1)),
          waterContentMl: 200,
        );

        await provider.addHydrationEntry(todayEntry);
        await provider.addHydrationEntry(yesterdayEntry);

        final todaysEntries = provider.getTodaysEntries();
        expect(todaysEntries.length, equals(1));
        expect(todaysEntries.first.id, equals('today-entry'));
      });

      test('should get entries for specific date', () async {
        final targetDate = DateTime(2024, 1, 15);
        final entry = HydrationEntry(
          id: 'specific-date-entry',
          amount: 400,
          type: DrinkType.water,
          timestamp: targetDate,
          waterContentMl: 400,
        );

        await provider.addHydrationEntry(entry);

        final dateEntries = provider.getEntriesForDateNew(targetDate);
        expect(dateEntries.length, equals(1));
        expect(dateEntries.first.id, equals('specific-date-entry'));
      });
    });

    group('Goal Calculation and Factors', () {
      test('should update goal factors and recalculate daily goal', () async {
        const newFactors = GoalFactors(
          baseRequirement: 2000,
          activityAdjustment: 500,
          climateAdjustment: 200,
          healthAdjustment: 100,
        );

        await provider.updateGoalFactors(newFactors);

        expect(provider.goalFactors, equals(newFactors));
        expect(provider.dailyGoal, equals(newFactors.totalGoal));
      });

      test('should calculate goal factors correctly', () {
        const factors = GoalFactors(
          baseRequirement: 2000,
          activityAdjustment: 300,
          climateAdjustment: 150,
          healthAdjustment: 50,
        );

        expect(factors.totalGoal, equals(2500));
      });
    });

    group('Drink Type Support', () {
      test('should set selected drink type', () async {
        await provider.setSelectedDrinkType(DrinkType.coffee);
        expect(provider.selectedDrinkType, equals(DrinkType.coffee));
      });

      test('should calculate water content for different drink types', () {
        final waterEntry = HydrationEntry(
          id: 'water-entry',
          amount: 250,
          type: DrinkType.water,
          timestamp: DateTime.now(),
          waterContentMl: 250,
        );

        final coffeeEntry = HydrationEntry(
          id: 'coffee-entry',
          amount: 250,
          type: DrinkType.coffee,
          timestamp: DateTime.now(),
          waterContentMl: 225, // 90% water content
        );

        expect(waterEntry.waterContentMl, equals(250));
        expect(coffeeEntry.waterContentMl, equals(225));
      });

      test('should get most used drink types', () async {
        // Add entries with different drink types
        await provider.addHydrationEntry(
          HydrationEntry(
            id: 'water-1',
            amount: 250,
            type: DrinkType.water,
            timestamp: DateTime.now(),
            waterContentMl: 250,
          ),
        );

        await provider.addHydrationEntry(
          HydrationEntry(
            id: 'water-2',
            amount: 300,
            type: DrinkType.water,
            timestamp: DateTime.now(),
            waterContentMl: 300,
          ),
        );

        await provider.addHydrationEntry(
          HydrationEntry(
            id: 'coffee-1',
            amount: 200,
            type: DrinkType.coffee,
            timestamp: DateTime.now(),
            waterContentMl: 180,
          ),
        );

        final mostUsed = provider.getMostUsedDrinkTypes(limit: 2);
        expect(mostUsed.length, equals(2));
        expect(mostUsed.first['type'], equals(DrinkType.water));
      });
    });

    group('Progress Updates and Reminders', () {
      test('should update current progress', () async {
        final entry = HydrationEntry(
          id: 'progress-entry',
          amount: 500,
          type: DrinkType.water,
          timestamp: DateTime.now(),
          waterContentMl: 500,
        );

        await provider.addHydrationEntry(entry);

        final progress = provider.currentProgress;
        expect(progress, isNotNull);
        expect(progress!.currentIntake, equals(500));
        expect(progress.percentage, greaterThan(0));
      });

      test('should calculate next reminder time', () async {
        // Add some hydration but not reach goal
        await provider.addHydrationEntry(
          HydrationEntry(
            id: 'partial-entry',
            amount: 500,
            type: DrinkType.water,
            timestamp: DateTime.now(),
            waterContentMl: 500,
          ),
        );

        expect(provider.nextReminderTime, isNotNull);
        expect(provider.nextReminderTime!.isAfter(DateTime.now()), isTrue);
      });

      test('should update reminder time manually', () async {
        final newReminderTime = DateTime.now().add(const Duration(hours: 2));
        await provider.updateReminderTime(newReminderTime);

        expect(provider.nextReminderTime, equals(newReminderTime));
      });

      test('should get progress for specific date', () async {
        final targetDate = DateTime(2024, 1, 20);
        final entry = HydrationEntry(
          id: 'date-progress-entry',
          amount: 750,
          type: DrinkType.water,
          timestamp: targetDate,
          waterContentMl: 750,
        );

        await provider.addHydrationEntry(entry);

        final progress = provider.getProgressForDate(targetDate);
        expect(progress.currentIntake, equals(750));
        expect(progress.percentage, greaterThan(0));
      });
    });

    group('Weekly Data and Statistics', () {
      test('should get weekly hydration data', () async {
        final weekStart = DateTime(2024, 1, 15); // Monday

        // Add entries for different days of the week
        for (var i = 0; i < 7; i++) {
          final date = weekStart.add(Duration(days: i));
          await provider.addHydrationEntry(
            HydrationEntry(
              id: 'week-entry-$i',
              amount: 300 + (i * 50),
              type: DrinkType.water,
              timestamp: date,
              waterContentMl: 300 + (i * 50),
            ),
          );
        }

        final weeklyData = provider.getWeeklyData(weekStart);
        expect(weeklyData.length, equals(7));
        expect(weeklyData[weekStart], equals(300));
        expect(weeklyData[weekStart.add(const Duration(days: 6))], equals(600));
      });

      test('should handle empty weekly data', () {
        final weekStart = DateTime(2024, 2);
        final weeklyData = provider.getWeeklyData(weekStart);

        expect(weeklyData.length, equals(7));
        for (final value in weeklyData.values) {
          expect(value, equals(0));
        }
      });
    });

    group('Data Persistence', () {
      test('should refresh all data', () async {
        // Add some initial data
        await provider.addHydrationEntry(
          HydrationEntry(
            id: 'refresh-test-entry',
            amount: 400,
            type: DrinkType.water,
            timestamp: DateTime.now(),
            waterContentMl: 400,
          ),
        );

        // Refresh data
        await provider.refreshData();

        // Verify data is still available
        expect(provider.isInitialized, isTrue);
        expect(provider.currentIntake, greaterThanOrEqualTo(0));
      });

      test('should handle loading states during refresh', () async {
        expect(provider.isLoading, isFalse);

        // Start refresh (this will set loading to true temporarily)
        final refreshFuture = provider.refreshData();

        // Complete the refresh
        await refreshFuture;

        expect(provider.isLoading, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle invalid hydration entry gracefully', () async {
        // This test would need to be implemented based on specific validation rules
        // For now, we'll test that the provider doesn't crash with edge cases

        final entry = HydrationEntry(
          id: 'edge-case-entry',
          amount: 0, // Edge case: zero amount
          type: DrinkType.water,
          timestamp: DateTime.now(),
          waterContentMl: 0,
        );

        // Should not throw an exception
        await provider.addHydrationEntry(entry);
        expect(provider.getTodaysEntries(), contains(entry));
      });

      test('should maintain data consistency after errors', () async {
        final initialEntryCount = provider.getTodaysEntries().length;

        try {
          // Attempt an operation that might fail
          await provider.updateGoalFactors(
            const GoalFactors(
              baseRequirement: -1000, // Invalid negative value
              activityAdjustment: 0,
              climateAdjustment: 0,
            ),
          );
        } catch (e) {
          // Error is expected for invalid data
        }

        // Data should remain consistent
        expect(provider.getTodaysEntries().length, equals(initialEntryCount));
        expect(provider.dailyGoal, greaterThan(0));
      });
    });
  });
}
