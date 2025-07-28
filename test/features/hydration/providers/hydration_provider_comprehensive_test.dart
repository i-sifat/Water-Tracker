import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

void main() {
  group('HydrationProvider Comprehensive Tests', () {
    late HydrationProvider hydrationProvider;

    setUp(() {
      hydrationProvider = HydrationProvider();
    });

    group('Basic Functionality', () {
      test('should create hydration provider', () {
        // Assert
        expect(hydrationProvider, isNotNull);
      });

      test('should have initial values', () {
        // Assert
        expect(hydrationProvider.todayIntake, equals(0));
        expect(hydrationProvider.dailyGoal, greaterThan(0));
      });
    });

    group('Water Intake Management', () {
      test('should add water intake', () {
        // Arrange
        const amount = 250;

        // Act
        hydrationProvider.addWater(amount);

        // Assert
        expect(hydrationProvider.todayIntake, equals(amount));
      });

      test('should accumulate water intake', () {
        // Arrange
        const amount1 = 250;
        const amount2 = 300;

        // Act
        hydrationProvider.addWater(amount1);
        hydrationProvider.addWater(amount2);

        // Assert
        expect(hydrationProvider.todayIntake, equals(amount1 + amount2));
      });

      test('should calculate progress percentage', () {
        // Arrange
        const amount = 500;
        hydrationProvider.setDailyGoal(2000);

        // Act
        hydrationProvider.addWater(amount);

        // Assert
        expect(hydrationProvider.progressPercentage, equals(25.0));
      });
    });

    group('Goal Management', () {
      test('should set daily goal', () {
        // Arrange
        const goal = 3000;

        // Act
        hydrationProvider.setDailyGoal(goal);

        // Assert
        expect(hydrationProvider.dailyGoal, equals(goal));
      });

      test('should check goal completion', () {
        // Arrange
        const goal = 2000;
        hydrationProvider.setDailyGoal(goal);

        // Act
        hydrationProvider.addWater(goal);

        // Assert
        expect(hydrationProvider.isGoalCompleted, isTrue);
      });
    });

    group('Data Persistence', () {
      test('should load data on initialization', () async {
        // Act
        await hydrationProvider.loadData();

        // Assert
        expect(hydrationProvider.todayIntake, greaterThanOrEqualTo(0));
      });

      test('should save data', () async {
        // Arrange
        hydrationProvider.addWater(250);

        // Act & Assert
        expect(() => hydrationProvider.saveData(), returnsNormally);
      });
    });

    group('History Management', () {
      test('should get history data', () {
        // Act
        final history = hydrationProvider.getHistory();

        // Assert
        expect(history, isNotNull);
        expect(history, isA<List>());
      });

      test('should get weekly summary', () {
        // Act
        final weeklySummary = hydrationProvider.getWeeklySummary();

        // Assert
        expect(weeklySummary, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle negative water amounts', () {
        // Act & Assert
        expect(() => hydrationProvider.addWater(-100), returnsNormally);
      });

      test('should handle zero amounts', () {
        // Act & Assert
        expect(() => hydrationProvider.addWater(0), returnsNormally);
      });

      test('should handle very large amounts', () {
        // Act & Assert
        expect(() => hydrationProvider.addWater(999999), returnsNormally);
      });
    });
  });
}
