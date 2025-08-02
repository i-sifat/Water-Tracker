import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_progress.dart';

void main() {
  group('HydrationProgress', () {
    late List<HydrationData> sampleEntries;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 14, 30);
      sampleEntries = [
        HydrationData(
          id: '1',
          amount: 500,
          timestamp: DateTime(2024, 1, 15, 8),
        ),
        HydrationData(
          id: '2',
          amount: 300,
          timestamp: DateTime(2024, 1, 15, 12),
          type: DrinkType.tea,
        ),
        HydrationData(
          id: '3',
          amount: 250,
          timestamp: DateTime(2024, 1, 15, 16),
          type: DrinkType.coffee,
        ),
      ];
    });

    test('should create instance with required fields', () {
      final progress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      expect(progress.currentIntake, equals(1000));
      expect(progress.dailyGoal, equals(2000));
      expect(progress.todaysEntries, equals(sampleEntries));
      expect(progress.nextReminderTime, isNull);
    });

    test('should calculate percentage correctly', () {
      final progress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      expect(progress.percentage, equals(0.5));
    });

    test('should handle percentage edge cases', () {
      // Zero goal
      final zeroGoalProgress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 0,
        todaysEntries: sampleEntries,
      );
      expect(zeroGoalProgress.percentage, equals(0.0));

      // Over 100%
      final overProgress = HydrationProgress(
        currentIntake: 2500,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );
      expect(overProgress.percentage, equals(1.0));
    });

    test('should calculate remaining intake correctly', () {
      final progress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      expect(progress.remainingIntake, equals(1000));
    });

    test('should handle remaining intake when goal is reached', () {
      final progress = HydrationProgress(
        currentIntake: 2500,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      expect(progress.remainingIntake, equals(0));
    });

    test('should detect when goal is reached', () {
      final notReachedProgress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );
      expect(notReachedProgress.isGoalReached, isFalse);

      final reachedProgress = HydrationProgress(
        currentIntake: 2000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );
      expect(reachedProgress.isGoalReached, isTrue);

      final exceededProgress = HydrationProgress(
        currentIntake: 2500,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );
      expect(exceededProgress.isGoalReached, isTrue);
    });

    test('should format progress text correctly', () {
      final progress = HydrationProgress(
        currentIntake: 1750,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      expect(progress.progressText, equals('1.75 L drank so far'));
    });

    test('should format goal text correctly', () {
      final progress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 3000,
        todaysEntries: sampleEntries,
      );

      expect(progress.goalText, equals('from a total of 3.0 L'));
    });

    test('should format remaining text without reminder time', () {
      final progress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      expect(progress.remainingText, equals('1000 ml remaining'));
    });

    test('should format remaining text with reminder time', () {
      final reminderTime = DateTime(2024, 1, 15, 16, 22);
      final progress = HydrationProgress(
        currentIntake: 1994,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
        nextReminderTime: reminderTime,
      );

      expect(progress.remainingText, equals('6 ml left before 4:22 PM'));
    });

    test('should format remaining text for morning reminder time', () {
      final reminderTime = DateTime(2024, 1, 15, 8, 30);
      final progress = HydrationProgress(
        currentIntake: 1500,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
        nextReminderTime: reminderTime,
      );

      expect(progress.remainingText, equals('500 ml left before 8:30 AM'));
    });

    test('should show goal achieved message when goal is reached', () {
      final progress = HydrationProgress(
        currentIntake: 2000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      expect(progress.remainingText, equals('Goal achieved!'));
    });

    test('should create from entries correctly', () {
      final progress = HydrationProgress.fromEntries(
        todaysEntries: sampleEntries,
        dailyGoal: 2000,
        nextReminderTime: testDate,
      );

      // Calculate expected water intake: 500ml water + 285ml tea + 225ml coffee = 1010ml
      final expectedIntake = sampleEntries.totalWaterIntake;
      expect(progress.currentIntake, equals(expectedIntake));
      expect(progress.dailyGoal, equals(2000));
      expect(progress.todaysEntries, equals(sampleEntries));
      expect(progress.nextReminderTime, equals(testDate));
    });

    test('should create copy with updated fields', () {
      final original = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      final copy = original.copyWith(
        currentIntake: 1500,
        nextReminderTime: testDate,
      );

      expect(copy.currentIntake, equals(1500));
      expect(copy.dailyGoal, equals(2000)); // unchanged
      expect(copy.todaysEntries, equals(sampleEntries)); // unchanged
      expect(copy.nextReminderTime, equals(testDate));
    });

    test('should implement equality correctly', () {
      final progress1 = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      final progress2 = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      final progress3 = HydrationProgress(
        currentIntake: 1500,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      expect(progress1, equals(progress2));
      expect(progress1, isNot(equals(progress3)));
    });

    test('should have meaningful toString', () {
      final progress = HydrationProgress(
        currentIntake: 1000,
        dailyGoal: 2000,
        todaysEntries: sampleEntries,
      );

      final string = progress.toString();
      expect(string, contains('1000ml'));
      expect(string, contains('2000ml'));
      expect(string, contains('50.0%'));
    });
  });
}
