import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';

void main() {
  group('HydrationData Tests', () {
    group('DrinkType', () {
      test('should have correct water content values', () {
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
    });

    group('HydrationData', () {
      test('should create HydrationData with required fields', () {
        // Arrange
        final timestamp = DateTime.now();
        const amount = 250;
        const drinkType = DrinkType.water;

        // Act
        final entry = HydrationData(
          id: 'test-id',
          amount: amount,
          timestamp: timestamp,
        );

        // Assert
        expect(entry.amount, equals(amount));
        expect(entry.timestamp, equals(timestamp));
        expect(entry.type, equals(drinkType));
        expect(entry.id, equals('test-id'));
        expect(entry.isSynced, isFalse);
        expect(entry.notes, isNull);
      });

      test('should create HydrationData with optional fields', () {
        // Arrange
        final timestamp = DateTime.now();
        const amount = 250;
        const drinkType = DrinkType.coffee;
        const notes = 'Morning coffee';

        // Act
        final entry = HydrationData(
          id: 'test-id',
          amount: amount,
          timestamp: timestamp,
          type: drinkType,
          isSynced: true,
          notes: notes,
        );

        // Assert
        expect(entry.type, equals(drinkType));
        expect(entry.isSynced, isTrue);
        expect(entry.notes, equals(notes));
      });

      test('should create HydrationData using factory constructor', () {
        // Act
        final entry = HydrationData.create(
          amount: 300,
          type: DrinkType.tea,
          notes: 'Afternoon tea',
        );

        // Assert
        expect(entry.amount, equals(300));
        expect(entry.type, equals(DrinkType.tea));
        expect(entry.notes, equals('Afternoon tea'));
        expect(entry.id, isNotNull);
        expect(entry.timestamp, isA<DateTime>());
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final timestamp = DateTime.now();
        final entry = HydrationData(
          id: 'test-id',
          amount: 250,
          timestamp: timestamp,
          isSynced: true,
          notes: 'Test entry',
        );

        // Act
        final json = entry.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['amount'], equals(250));
        expect(json['timestamp'], equals(timestamp.millisecondsSinceEpoch));
        expect(json['type'], equals('water'));
        expect(json['isSynced'], isTrue);
        expect(json['notes'], equals('Test entry'));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id',
          'amount': 300,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'type': 'tea',
          'isSynced': true,
          'notes': 'Afternoon tea',
        };

        // Act
        final entry = HydrationData.fromJson(json);

        // Assert
        expect(entry.id, equals('test-id'));
        expect(entry.amount, equals(300));
        expect(entry.timestamp.millisecondsSinceEpoch, equals(timestamp.millisecondsSinceEpoch));
        expect(entry.type, equals(DrinkType.tea));
        expect(entry.isSynced, isTrue);
        expect(entry.notes, equals('Afternoon tea'));
      });

      test('should handle missing optional fields in JSON', () {
        // Arrange
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id',
          'amount': 250,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'type': 'water',
        };

        // Act
        final entry = HydrationData.fromJson(json);

        // Assert
        expect(entry.isSynced, isFalse);
        expect(entry.notes, isNull);
      });

      test('should calculate water content correctly', () {
        // Arrange
        final waterEntry = HydrationData.create(amount: 250);
        final coffeeEntry = HydrationData.create(amount: 250, type: DrinkType.coffee);
        final juiceEntry = HydrationData.create(amount: 250, type: DrinkType.juice);

        // Act
        final waterContent = waterEntry.waterContent;
        final coffeeContent = coffeeEntry.waterContent;
        final juiceContent = juiceEntry.waterContent;

        // Assert
        expect(waterContent, equals(250)); // 250 * 1.0
        expect(coffeeContent, equals(238)); // 250 * 0.95 rounded
        expect(juiceContent, equals(213)); // 250 * 0.85 rounded
      });

      test('should support equality comparison', () {
        // Arrange
        final timestamp = DateTime.now();
        final entry1 = HydrationData(
          id: 'same-id',
          amount: 250,
          timestamp: timestamp,
        );
        final entry2 = HydrationData(
          id: 'same-id',
          amount: 250,
          timestamp: timestamp,
        );
        final entry3 = HydrationData(
          id: 'different-id',
          amount: 250,
          timestamp: timestamp,
        );

        // Act & Assert
        expect(entry1, equals(entry2));
        expect(entry1, isNot(equals(entry3)));
      });

      test('should create copy with updated fields', () {
        // Arrange
        final original = HydrationData.create(
          amount: 250,
          notes: 'Original notes',
        );

        // Act
        final updated = original.copyWith(
          amount: 300,
          notes: 'Updated notes',
        );

        // Assert
        expect(updated.amount, equals(300));
        expect(updated.notes, equals('Updated notes'));
        expect(updated.id, equals(original.id));
        expect(updated.type, equals(original.type));
        expect(updated.timestamp, equals(original.timestamp));
      });
    });

    group('Edge Cases', () {
      test('should handle unknown drink type in JSON', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'amount': 250,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'type': 'unknown_type',
        };

        // Act
        final entry = HydrationData.fromJson(json);

        // Assert
        expect(entry.type, equals(DrinkType.water)); // Should default to water
      });

      test('should handle very large amounts', () {
        // Arrange & Act
        final entry = HydrationData.create(amount: 999999);

        // Assert
        expect(entry.amount, equals(999999));
        expect(entry.toJson, returnsNormally);
      });

      test('should handle zero amount', () {
        // Arrange & Act
        final entry = HydrationData.create(amount: 0);

        // Assert
        expect(entry.amount, equals(0));
        expect(entry.waterContent, equals(0));
      });
    });
  });
}