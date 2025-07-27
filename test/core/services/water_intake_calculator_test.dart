import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/water_intake_calculator.dart';

void main() {
  group('WaterIntakeCalculator Tests', () {
    late WaterIntakeCalculator calculator;

    setUp(() {
      calculator = WaterIntakeCalculator();
    });

    group('Basic Goal Calculation', () {
      test('should calculate basic goal for adult male', () {
        // Arrange
        final profile = UserProfile(
          age: 30,
          weight: 70.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.temperate,
        );

        // Act
        final goal = calculator.calculateDailyGoal(profile);

        // Assert
        expect(goal, greaterThan(2000.0));
        expect(goal, lessThan(4000.0));
      });

      test('should calculate basic goal for adult female', () {
        // Arrange
        final profile = UserProfile(
          age: 25,
          weight: 60.0,
          gender: Gender.female,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.temperate,
        );

        // Act
        final goal = calculator.calculateDailyGoal(profile);

        // Assert
        expect(goal, greaterThan(1800.0));
        expect(goal, lessThan(3500.0));
      });
    });

    group('Weight-based Adjustments', () {
      test('should increase goal for higher weight', () {
        // Arrange
        final lightProfile = UserProfile(
          age: 30,
          weight: 50.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.temperate,
        );
        final heavyProfile = UserProfile(
          age: 30,
          weight: 90.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.temperate,
        );

        // Act
        final lightGoal = calculator.calculateDailyGoal(lightProfile);
        final heavyGoal = calculator.calculateDailyGoal(heavyProfile);

        // Assert
        expect(heavyGoal, greaterThan(lightGoal));
      });
    });

    group('Activity Level Adjustments', () {
      test('should increase goal for higher activity levels', () {
        // Arrange
        final sedentaryProfile = UserProfile(
          age: 30,
          weight: 70.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.sedentary,
          climate: Climate.temperate,
        );
        final activeProfile = UserProfile(
          age: 30,
          weight: 70.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.veryActive,
          climate: Climate.temperate,
        );

        // Act
        final sedentaryGoal = calculator.calculateDailyGoal(sedentaryProfile);
        final activeGoal = calculator.calculateDailyGoal(activeProfile);

        // Assert
        expect(activeGoal, greaterThan(sedentaryGoal));
      });
    });

    group('Climate Adjustments', () {
      test('should increase goal for hot climate', () {
        // Arrange
        final temperateProfile = UserProfile(
          age: 30,
          weight: 70.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.temperate,
        );
        final hotProfile = UserProfile(
          age: 30,
          weight: 70.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.hot,
        );

        // Act
        final temperateGoal = calculator.calculateDailyGoal(temperateProfile);
        final hotGoal = calculator.calculateDailyGoal(hotProfile);

        // Assert
        expect(hotGoal, greaterThan(temperateGoal));
      });
    });

    group('Age Adjustments', () {
      test('should adjust goal based on age groups', () {
        // Arrange
        final youngProfile = UserProfile(
          age: 25,
          weight: 70.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.temperate,
        );
        final elderlyProfile = UserProfile(
          age: 70,
          weight: 70.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.temperate,
        );

        // Act
        final youngGoal = calculator.calculateDailyGoal(youngProfile);
        final elderlyGoal = calculator.calculateDailyGoal(elderlyProfile);

        // Assert
        expect(youngGoal, isA<double>());
        expect(elderlyGoal, isA<double>());
        expect(youngGoal, greaterThan(0));
        expect(elderlyGoal, greaterThan(0));
      });
    });

    group('Hydration Efficiency', () {
      test('should calculate hydration efficiency for different drink types', () {
        // Act
        final waterEfficiency = calculator.getHydrationEfficiency('water');
        final coffeeEfficiency = calculator.getHydrationEfficiency('coffee');
        final alcoholEfficiency = calculator.getHydrationEfficiency('alcohol');

        // Assert
        expect(waterEfficiency, equals(1.0));
        expect(coffeeEfficiency, lessThan(1.0));
        expect(alcoholEfficiency, lessThan(coffeeEfficiency));
      });

      test('should handle unknown drink types', () {
        // Act
        final unknownEfficiency = calculator.getHydrationEfficiency('unknown_drink');

        // Assert
        expect(unknownEfficiency, equals(1.0)); // Default to water efficiency
      });
    });

    group('Intake Recommendations', () {
      test('should provide intake recommendations throughout the day', () {
        // Arrange
        final profile = UserProfile(
          age: 30,
          weight: 70.0,
          gender: Gender.male,
          activityLevel: ActivityLevel.moderate,
          climate: Climate.temperate,
        );

        // Act
        final recommendations = calculator.getIntakeRecommendations(profile);

        // Assert
        expect(recommendations, isA<List<Map<String, dynamic>>>());
        expect(recommendations.isNotEmpty, isTrue);
        
        // Check that recommendations cover the day
        final totalRecommended = recommendations.fold<double>(
          0.0, 
          (sum, rec) => sum + (rec['amount'] as double)
        );
        final dailyGoal = calculator.calculateDailyGoal(profile);
        expect(totalRecommended, closeTo(dailyGoal, 200.0));
      });
    });

    group('Progress Calculation', () {
      test('should calculate progress percentage correctly', () {
        // Arrange
        const currentIntake = 1500.0;
        const dailyGoal = 2000.0;

        // Act
        final progress = calculator.calculateProgress(currentIntake, dailyGoal);

        // Assert
        expect(progress, equals(0.75));
      });

      test('should handle progress over 100%', () {
        // Arrange
        const currentIntake = 2500.0;
        const dailyGoal = 2000.0;

        // Act
        final progress = calculator.calculateProgress(currentIntake, dailyGoal);

        // Assert
        expect(progress, equals(1.25));
      });

      test('should handle zero goal', () {
        // Arrange
        const currentIntake = 1500.0;
        const dailyGoal = 0.0;

        // Act
        final progress = calculator.calculateProgress(currentIntake, dailyGoal);

        // Assert
        expect(progress, equals(0.0));
      });
    });

    group('Validation', () {
      test('should validate reasonable intake amounts', () {
        // Act & Assert
        expect(calculator.isValidIntakeAmount(250.0), isTrue);
        expect(calculator.isValidIntakeAmount(1000.0), isTrue);
        expect(calculator.isValidIntakeAmount(-100.0), isFalse);
        expect(calculator.isValidIntakeAmount(0.0), isFalse);
        expect(calculator.isValidIntakeAmount(5000.0), isFalse);
      });

      test('should validate reasonable daily goals', () {
        // Act & Assert
        expect(calculator.isValidDailyGoal(2000.0), isTrue);
        expect(calculator.isValidDailyGoal(3500.0), isTrue);
        expect(calculator.isValidDailyGoal(500.0), isFalse);
        expect(calculator.isValidDailyGoal(8000.0), isFalse);
        expect(calculator.isValidDailyGoal(-1000.0), isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle extreme user profiles', () {
        // Arrange
        final extremeProfile = UserProfile(
          age: 100,
          weight: 40.0,
          gender: Gender.female,
          activityLevel: ActivityLevel.sedentary,
          climate: Climate.cold,
        );

        // Act & Assert
        expect(() => calculator.calculateDailyGoal(extremeProfile), returnsNormally);
        final goal = calculator.calculateDailyGoal(extremeProfile);
        expect(goal, greaterThan(0));
        expect(goal, lessThan(10000.0));
      });
    });
  });
}