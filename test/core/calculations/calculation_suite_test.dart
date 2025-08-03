import 'package:flutter_test/flutter_test.dart';

// Import all calculation test files
import 'water_goal_calculator_test.dart' as water_goal_tests;
import 'adjustment_factors_test.dart' as adjustment_factor_tests;
import 'advanced_water_calculator_test.dart' as advanced_calculator_tests;

/// Comprehensive test suite for all water calculation components
///
/// This test suite runs all calculation-related tests to ensure the
/// simplified and modular calculation system works correctly.
void main() {
  group('Water Calculation System Tests', () {
    group('WaterGoalCalculator Tests', () {
      water_goal_tests.main();
    });

    group('AdjustmentFactors Tests', () {
      adjustment_factor_tests.main();
    });

    group('AdvancedWaterCalculator Tests', () {
      advanced_calculator_tests.main();
    });
  });
}
