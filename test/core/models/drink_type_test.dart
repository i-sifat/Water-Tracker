import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';

void main() {
  group('DrinkType', () {
    test('should have correct water content percentages', () {
      expect(DrinkType.water.waterContent, equals(1.0));
      expect(DrinkType.tea.waterContent, equals(0.95));
      expect(DrinkType.coffee.waterContent, equals(0.95));
      expect(DrinkType.juice.waterContent, equals(0.85));
      expect(DrinkType.soda.waterContent, equals(0.90));
      expect(DrinkType.sports.waterContent, equals(0.92));
      expect(DrinkType.other.waterContent, equals(0.80));
    });

    test('should have correct display names', () {
      expect(DrinkType.water.displayName, equals('Water'));
      expect(DrinkType.tea.displayName, equals('Tea'));
      expect(DrinkType.coffee.displayName, equals('Coffee'));
      expect(DrinkType.juice.displayName, equals('Juice'));
      expect(DrinkType.soda.displayName, equals('Soda'));
      expect(DrinkType.sports.displayName, equals('Sports Drink'));
      expect(DrinkType.other.displayName, equals('Other'));
    });

    test('should have correct icons', () {
      expect(DrinkType.water.icon, equals(Icons.water_drop));
      expect(DrinkType.tea.icon, equals(Icons.local_cafe));
      expect(DrinkType.coffee.icon, equals(Icons.coffee));
      expect(DrinkType.juice.icon, equals(Icons.local_drink));
      expect(DrinkType.soda.icon, equals(Icons.local_bar));
      expect(DrinkType.sports.icon, equals(Icons.sports_bar));
      expect(DrinkType.other.icon, equals(Icons.local_drink));
    });

    test('should have correct colors', () {
      expect(DrinkType.water.color, equals(const Color(0xFF2196F3))); // Blue
      expect(DrinkType.tea.color, equals(const Color(0xFF8D6E63))); // Brown
      expect(
        DrinkType.coffee.color,
        equals(const Color(0xFF5D4037)),
      ); // Dark Brown
      expect(DrinkType.juice.color, equals(const Color(0xFFFF9800))); // Orange
      expect(DrinkType.soda.color, equals(const Color(0xFF9C27B0))); // Purple
      expect(DrinkType.sports.color, equals(const Color(0xFF4CAF50))); // Green
      expect(
        DrinkType.other.color,
        equals(const Color(0xFF607D8B)),
      ); // Blue Grey
    });

    test('should have all enum values covered', () {
      // This test ensures we don't forget to add new enum values to the switch statements
      for (final drinkType in DrinkType.values) {
        expect(drinkType.waterContent, isA<double>());
        expect(drinkType.displayName, isA<String>());
        expect(drinkType.icon, isA<IconData>());
        expect(drinkType.color, isA<Color>());

        // Ensure none are empty/null
        expect(drinkType.displayName.isNotEmpty, isTrue);
        expect(drinkType.waterContent, greaterThan(0.0));
        expect(drinkType.waterContent, lessThanOrEqualTo(1.0));
      }
    });

    test('should maintain water content consistency', () {
      // Water should have the highest water content
      expect(DrinkType.water.waterContent, equals(1.0));

      // All other drinks should have less than 100% water content
      for (final drinkType in DrinkType.values) {
        if (drinkType != DrinkType.water) {
          expect(drinkType.waterContent, lessThan(1.0));
        }
      }
    });

    test('should have reasonable water content values', () {
      // All water content should be between 0 and 1
      for (final drinkType in DrinkType.values) {
        expect(drinkType.waterContent, greaterThanOrEqualTo(0.0));
        expect(drinkType.waterContent, lessThanOrEqualTo(1.0));
      }

      // Tea should have high water content (close to water)
      expect(DrinkType.tea.waterContent, greaterThan(0.9));

      // Coffee should have high water content
      expect(DrinkType.coffee.waterContent, greaterThan(0.85));
      expect(
        DrinkType.coffee.waterContent,
        lessThanOrEqualTo(DrinkType.tea.waterContent),
      );

      // Sports drinks should have high water content
      expect(DrinkType.sports.waterContent, greaterThan(0.9));
    });

    test('should have unique colors for visual distinction', () {
      final colors = DrinkType.values.map((type) => type.color).toList();
      final uniqueColors = colors.toSet();

      // All drink types should have unique colors for better UX
      expect(uniqueColors.length, equals(colors.length));
    });

    test('should have appropriate icons for each drink type', () {
      // Water should use water drop icon
      expect(DrinkType.water.icon, equals(Icons.water_drop));

      // Coffee and tea should use cafe-related icons
      expect(DrinkType.coffee.icon, equals(Icons.coffee));
      expect(DrinkType.tea.icon, equals(Icons.local_cafe));

      // Sports drink should use sports-related icon
      expect(DrinkType.sports.icon, equals(Icons.sports_bar));

      // Alcoholic/bar drinks should use bar icon
      expect(DrinkType.soda.icon, equals(Icons.local_bar));

      // Generic drinks should use drink icon
      expect(DrinkType.juice.icon, equals(Icons.local_drink));
      expect(DrinkType.other.icon, equals(Icons.local_drink));
    });
  });
}
