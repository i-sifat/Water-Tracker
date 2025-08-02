import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/goal_factors.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_entry.dart';
import 'package:watertracker/core/models/hydration_progress.dart';

void main() {
  group('Swipeable Hydration Models Integration', () {
    late List<HydrationEntry> sampleEntries;
    late GoalFactors goalFactors;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 14, 30);

      // Create sample hydration entries
      sampleEntries = [
        HydrationEntry.create(
          amount: 500,
          notes: 'Morning water',
        ),
        HydrationEntry.create(
          amount: 300,
          type: DrinkType.tea,
          notes: 'Green tea',
        ),
        HydrationEntry.create(
          amount: 250,
          type: DrinkType.coffee,
          notes: 'Afternoon coffee',
        ),
      ];

      // Create goal factors
      goalFactors = GoalFactors.defaultForUser(weight: 75, age: 30);
    });

    test('should integrate all models for complete hydration tracking', () {
      // Test goal calculation
      expect(goalFactors.baseRequirement, equals(2625)); // 75kg * 35ml
      expect(goalFactors.totalGoal, equals(3025)); // base + moderate activity

      // Test hydration entries
      expect(sampleEntries.length, equals(3));
      expect(sampleEntries.totalWaterIntake, equals(1023)); // 500 + 285 + 238
      expect(sampleEntries.totalLiquidIntake, equals(1050)); // 500 + 300 + 250

      // Test progress calculation
      final progress = HydrationProgress.fromEntries(
        todaysEntries: sampleEntries.map((e) => e.toHydrationData()).toList(),
        dailyGoal: goalFactors.totalGoal,
        nextReminderTime: testDate,
      );

      expect(progress.currentIntake, equals(1023));
      expect(progress.dailyGoal, equals(3025));
      expect(progress.percentage, closeTo(0.338, 0.001)); // 1023/3025
      expect(progress.remainingIntake, equals(2002));
      expect(progress.isGoalReached, isFalse);
    });

    test('should handle goal achievement scenario', () {
      // Create entries that exceed the goal
      final highIntakeEntries = [
        HydrationEntry.create(amount: 1000),
        HydrationEntry.create(amount: 1000),
        HydrationEntry.create(amount: 1000),
        HydrationEntry.create(amount: 500, type: DrinkType.tea), // 475ml water
      ];

      final progress = HydrationProgress.fromEntries(
        todaysEntries:
            highIntakeEntries.map((e) => e.toHydrationData()).toList(),
        dailyGoal: goalFactors.totalGoal,
      );

      expect(progress.currentIntake, equals(3475)); // 3000 + 475
      expect(progress.isGoalReached, isTrue);
      expect(progress.percentage, equals(1.0)); // Clamped to 1.0
      expect(progress.remainingIntake, equals(0));
      expect(progress.remainingText, equals('Goal achieved!'));
    });

    test('should handle different activity levels and climate conditions', () {
      final sedentaryFactors = goalFactors.copyWith(
        activityLevel: ActivityLevel.sedentary,
        climateCondition: ClimateCondition.cold,
      );

      final veryActiveFactors = goalFactors.copyWith(
        activityLevel: ActivityLevel.veryActive,
        climateCondition: ClimateCondition.veryHot,
      );

      // Sedentary in cold climate should have lower goal
      expect(sedentaryFactors.totalGoal, equals(2525)); // 2625 + 0 - 100

      // Very active in very hot climate should have higher goal
      expect(veryActiveFactors.totalGoal, equals(3825)); // 2625 + 600 + 600
    });

    test('should handle different drink types correctly', () {
      final mixedDrinkEntries = [
        HydrationEntry.create(
          amount: 500,
        ), // 500ml water
        HydrationEntry.create(
          amount: 300,
          type: DrinkType.juice,
        ), // 255ml water
        HydrationEntry.create(amount: 400, type: DrinkType.soda), // 360ml water
        HydrationEntry.create(
          amount: 250,
          type: DrinkType.sports,
        ), // 230ml water
      ];

      final totalWater = mixedDrinkEntries.totalWaterIntake;
      expect(totalWater, equals(1345)); // 500 + 255 + 360 + 230

      final progress = HydrationProgress.fromEntries(
        todaysEntries:
            mixedDrinkEntries.map((e) => e.toHydrationData()).toList(),
        dailyGoal: 2000,
      );

      expect(progress.currentIntake, equals(1345));
      expect(progress.percentage, closeTo(0.673, 0.001));
    });

    test('should format progress text correctly', () {
      final progress = HydrationProgress(
        currentIntake: 1750,
        dailyGoal: 2500,
        todaysEntries: const [],
        nextReminderTime: DateTime(2024, 1, 15, 16, 30),
      );

      expect(progress.progressText, equals('1.75 L drank so far'));
      expect(progress.goalText, equals('from a total of 2.5 L'));
      expect(progress.remainingText, equals('750 ml left before 4:30 PM'));
    });

    test('should handle edge cases gracefully', () {
      // Empty entries
      final emptyProgress = HydrationProgress.fromEntries(
        todaysEntries: const [],
        dailyGoal: 2000,
      );
      expect(emptyProgress.currentIntake, equals(0));
      expect(emptyProgress.percentage, equals(0.0));

      // Zero goal (edge case)
      const zeroGoalProgress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 0,
        todaysEntries: [],
      );
      expect(zeroGoalProgress.percentage, equals(0.0));

      // Very small amounts
      final smallEntry = HydrationEntry.create(
        amount: 1,
      );
      expect(smallEntry.waterContentMl, equals(1));
      expect(smallEntry.formattedAmount, equals('1 ml'));
    });

    test('should maintain data consistency between models', () {
      // Create entry and convert between models
      final originalEntry = HydrationEntry.create(
        amount: 300,
        type: DrinkType.coffee,
        notes: 'Test coffee',
      );

      final hydrationData = originalEntry.toHydrationData();
      final convertedEntry = HydrationEntry.fromHydrationData(hydrationData);

      // Should maintain all data
      expect(convertedEntry.id, equals(originalEntry.id));
      expect(convertedEntry.amount, equals(originalEntry.amount));
      expect(convertedEntry.type, equals(originalEntry.type));
      expect(convertedEntry.notes, equals(originalEntry.notes));
      expect(
        convertedEntry.waterContentMl,
        equals(originalEntry.waterContentMl),
      );
    });

    test('should support JSON serialization for all models', () {
      // Test HydrationEntry JSON
      final entry = sampleEntries.first;
      final entryJson = entry.toJson();
      final deserializedEntry = HydrationEntry.fromJson(entryJson);

      // Check all fields except timestamp precision
      expect(deserializedEntry.id, equals(entry.id));
      expect(deserializedEntry.amount, equals(entry.amount));
      expect(deserializedEntry.type, equals(entry.type));
      expect(deserializedEntry.notes, equals(entry.notes));
      expect(deserializedEntry.isSynced, equals(entry.isSynced));
      // Timestamp should be equal to millisecond precision
      expect(
        deserializedEntry.timestamp.millisecondsSinceEpoch,
        equals(entry.timestamp.millisecondsSinceEpoch),
      );

      // Test GoalFactors JSON
      final factorsJson = goalFactors.toJson();
      final deserializedFactors = GoalFactors.fromJson(factorsJson);
      expect(deserializedFactors, equals(goalFactors));
    });

    test('should calculate realistic hydration scenarios', () {
      // Scenario: Office worker, moderate activity, temperate climate
      const officeWorkerFactors = GoalFactors(
        baseRequirement: 2450, // 70kg person
        activityLevel: ActivityLevel.lightlyActive,
      );

      // Typical day entries
      final typicalDayEntries = [
        HydrationEntry.create(amount: 250), // Morning
        HydrationEntry.create(amount: 300, type: DrinkType.coffee), // Breakfast
        HydrationEntry.create(
          amount: 500,
        ), // Mid-morning
        HydrationEntry.create(amount: 400), // Lunch
        HydrationEntry.create(amount: 250, type: DrinkType.tea), // Afternoon
        HydrationEntry.create(amount: 600), // Evening
      ];

      final progress = HydrationProgress.fromEntries(
        todaysEntries:
            typicalDayEntries.map((e) => e.toHydrationData()).toList(),
        dailyGoal: officeWorkerFactors.totalGoal,
      );

      // Should be close to goal achievement
      expect(progress.currentIntake, greaterThan(2000));
      expect(progress.percentage, greaterThan(0.7));
      expect(officeWorkerFactors.totalGoal, equals(2650)); // 2450 + 200
    });
  });
}
