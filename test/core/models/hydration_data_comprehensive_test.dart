import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';

void main() {
  group('HydrationData Comprehensive Tests', () {
    group('Constructor and Basic Properties', () {
      test('should create HydrationData with all required properties', () {
        // Arrange
        final timestamp = DateTime.now();
        const amount = 250;
        const type = DrinkType.water;
        const notes = 'Morning hydration';

        // Act
        final hydrationData = HydrationData(
          id: 'test-id',
          amount: amount,
          timestamp: timestamp,
          notes: notes,
        );

        // Assert
        expect(hydrationData.amount, equals(amount));
        expect(hydrationData.timestamp, equals(timestamp));
        expect(hydrationData.type, equals(type));
        expect(hydrationData.notes, equals(notes));
        expect(hydrationData.id, isNotNull);
        expect(hydrationData.id, isNotEmpty);
      });

      test('should generate unique IDs for different instances', () {
        // Arrange & Act
        final hydration1 = HydrationData.create(amount: 250);

        final hydration2 = HydrationData.create(
          amount: 300,
          type: DrinkType.tea,
        );

        // Assert
        expect(hydration1.id, isNot(equals(hydration2.id)));
      });

      test('should handle optional parameters correctly', () {
        // Arrange
        final timestamp = DateTime.now();

        // Act
        final hydrationData = HydrationData(
          id: 'test-id',
          amount: 250,
          timestamp: timestamp,
        );

        // Assert
        expect(hydrationData.type, equals(DrinkType.water));
        expect(hydrationData.notes, isNull);
        expect(hydrationData.isSynced, isFalse);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly with all properties', () {
        // Arrange
        final timestamp = DateTime.now();
        final hydrationData = HydrationData(
          id: 'test-id',
          amount: 250,
          timestamp: timestamp,
          notes: 'Post-workout hydration',
          isSynced: true,
        );

        // Act
        final json = hydrationData.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['amount'], equals(250));
        expect(json['timestamp'], equals(timestamp.millisecondsSinceEpoch));
        expect(json['type'], equals('water'));
        expect(json['notes'], equals('Post-workout hydration'));
        expect(json['isSynced'], equals(true));
      });

      test('should serialize to JSON correctly with minimal properties', () {
        // Arrange
        final timestamp = DateTime.now();
        final hydrationData = HydrationData(
          id: 'test-id-2',
          amount: 300,
          timestamp: timestamp,
          type: DrinkType.tea,
        );

        // Act
        final json = hydrationData.toJson();

        // Assert
        expect(json['id'], equals('test-id-2'));
        expect(json['amount'], equals(300));
        expect(json['timestamp'], equals(timestamp.millisecondsSinceEpoch));
        expect(json['type'], equals('tea'));
        expect(json['notes'], isNull);
        expect(json['isSynced'], equals(false));
      });

      test('should deserialize from JSON correctly with all properties', () {
        // Arrange
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id-123',
          'amount': 400,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'type': 'coffee',
          'notes': 'Morning coffee',
          'isSynced': true,
        };

        // Act
        final hydrationData = HydrationData.fromJson(json);

        // Assert
        expect(hydrationData.id, equals('test-id-123'));
        expect(hydrationData.amount, equals(400));
        expect(hydrationData.timestamp, equals(timestamp));
        expect(hydrationData.type, equals(DrinkType.coffee));
        expect(hydrationData.notes, equals('Morning coffee'));
        expect(hydrationData.isSynced, equals(true));
      });

      test(
        'should deserialize from JSON correctly with minimal properties',
        () {
          // Arrange
          final timestamp = DateTime.now();
          final json = {
            'id': 'test-id-456',
            'amount': 200,
            'timestamp': timestamp.millisecondsSinceEpoch,
            'type': 'juice',
          };

          // Act
          final hydrationData = HydrationData.fromJson(json);

          // Assert
          expect(hydrationData.id, equals('test-id-456'));
          expect(hydrationData.amount, equals(200));
          expect(hydrationData.timestamp, equals(timestamp));
          expect(hydrationData.type, equals(DrinkType.juice));
          expect(hydrationData.notes, isNull);
          expect(hydrationData.isSynced, equals(false));
        },
      );

      test('should handle JSON serialization round trip', () {
        // Arrange
        final original = HydrationData.create(
          amount: 350,
          type: DrinkType.sports,
          notes: 'After gym session',
        );

        // Act
        final json = original.toJson();
        final deserialized = HydrationData.fromJson(json);

        // Assert
        expect(deserialized.id, equals(original.id));
        expect(deserialized.amount, equals(original.amount));
        expect(deserialized.timestamp, equals(original.timestamp));
        expect(deserialized.type, equals(original.type));
        expect(deserialized.notes, equals(original.notes));
        expect(deserialized.isSynced, equals(original.isSynced));
      });
    });

    group('Water Content Calculation', () {
      test(
        'should calculate water content correctly for different drink types',
        () {
          // Arrange & Act
          final waterData = HydrationData.create(amount: 1000);
          final teaData = HydrationData.create(
            amount: 1000,
            type: DrinkType.tea,
          );
          final coffeeData = HydrationData.create(
            amount: 1000,
            type: DrinkType.coffee,
          );
          final juiceData = HydrationData.create(
            amount: 1000,
            type: DrinkType.juice,
          );
          final sodaData = HydrationData.create(
            amount: 1000,
            type: DrinkType.soda,
          );
          final sportsData = HydrationData.create(
            amount: 1000,
            type: DrinkType.sports,
          );
          final otherData = HydrationData.create(
            amount: 1000,
            type: DrinkType.other,
          );

          // Assert
          expect(waterData.waterContent, equals(1000)); // 100%
          expect(teaData.waterContent, equals(950)); // 95%
          expect(coffeeData.waterContent, equals(950)); // 95%
          expect(juiceData.waterContent, equals(850)); // 85%
          expect(sodaData.waterContent, equals(900)); // 90%
          expect(sportsData.waterContent, equals(920)); // 92%
          expect(otherData.waterContent, equals(800)); // 80%
        },
      );
    });

    group('Date Utilities', () {
      test('should extract date correctly', () {
        // Arrange
        final timestamp = DateTime(2023, 6, 15, 14, 30, 45);
        final hydrationData = HydrationData(
          id: 'test-id',
          amount: 250,
          timestamp: timestamp,
        );

        // Act
        final date = hydrationData.date;

        // Assert
        expect(date.year, equals(2023));
        expect(date.month, equals(6));
        expect(date.day, equals(15));
        expect(date.hour, equals(0));
        expect(date.minute, equals(0));
        expect(date.second, equals(0));
      });
    });

    group('Copy With Method', () {
      test('should create copy with updated fields', () {
        // Arrange
        final original = HydrationData.create(
          amount: 250,
          notes: 'Original note',
        );

        // Act
        final updated = original.copyWith(
          amount: 500,
          type: DrinkType.tea,
          notes: 'Updated note',
          isSynced: true,
        );

        // Assert
        expect(updated.id, equals(original.id));
        expect(updated.amount, equals(500));
        expect(updated.type, equals(DrinkType.tea));
        expect(updated.notes, equals('Updated note'));
        expect(updated.isSynced, equals(true));
        expect(updated.timestamp, equals(original.timestamp));
      });

      test('should preserve original fields when not specified', () {
        // Arrange
        final original = HydrationData.create(
          amount: 250,
          type: DrinkType.coffee,
          notes: 'Morning coffee',
        );

        // Act
        final updated = original.copyWith(amount: 300);

        // Assert
        expect(updated.id, equals(original.id));
        expect(updated.amount, equals(300));
        expect(updated.type, equals(original.type));
        expect(updated.notes, equals(original.notes));
        expect(updated.isSynced, equals(original.isSynced));
        expect(updated.timestamp, equals(original.timestamp));
      });
    });

    group('Equality and Comparison', () {
      test('should be equal when all properties match', () {
        // Arrange
        final timestamp = DateTime.now();
        const id = 'same-id';

        final hydration1 = HydrationData(
          id: id,
          amount: 250,
          timestamp: timestamp,
          notes: 'Test note',
          isSynced: true,
        );

        final hydration2 = HydrationData(
          id: id,
          amount: 250,
          timestamp: timestamp,
          notes: 'Test note',
          isSynced: true,
        );

        // Act & Assert
        expect(hydration1, equals(hydration2));
        expect(hydration1.hashCode, equals(hydration2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final timestamp = DateTime.now();

        final hydration1 = HydrationData(
          id: 'id-1',
          amount: 250,
          timestamp: timestamp,
        );

        final hydration2 = HydrationData(
          id: 'id-2',
          amount: 300, // Different amount
          timestamp: timestamp,
        );

        // Act & Assert
        expect(hydration1, isNot(equals(hydration2)));
      });
    });

    group('Validation and Edge Cases', () {
      test('should handle zero amount', () {
        // Arrange & Act
        final hydrationData = HydrationData.create(amount: 0);

        // Assert
        expect(hydrationData.amount, equals(0));
        expect(hydrationData.waterContent, equals(0));
        expect(hydrationData.toJson, returnsNormally);
      });

      test('should handle very large amounts', () {
        // Arrange & Act
        final hydrationData = HydrationData.create(amount: 999999);

        // Assert
        expect(hydrationData.amount, equals(999999));
        expect(hydrationData.waterContent, equals(999999));
      });

      test('should handle very long notes', () {
        // Arrange
        final longString = 'A' * 1000;

        // Act
        final hydrationData = HydrationData.create(
          amount: 250,
          notes: longString,
        );

        // Assert
        expect(hydrationData.notes, equals(longString));
      });

      test('should handle past and future timestamps', () {
        // Arrange
        final pastDate = DateTime(2020);
        final futureDate = DateTime(2030, 12, 31);

        // Act
        final pastHydration = HydrationData(
          id: 'past-id',
          amount: 250,
          timestamp: pastDate,
        );

        final futureHydration = HydrationData(
          id: 'future-id',
          amount: 300,
          timestamp: futureDate,
        );

        // Assert
        expect(pastHydration.timestamp, equals(pastDate));
        expect(futureHydration.timestamp, equals(futureDate));
      });
    });

    group('toString Method', () {
      test('should provide meaningful string representation', () {
        // Arrange
        final hydrationData = HydrationData(
          id: 'test-id',
          amount: 250,
          timestamp: DateTime(2023, 6, 15, 10, 30),
          notes: 'Morning hydration',
        );

        // Act
        final stringRepresentation = hydrationData.toString();

        // Assert
        expect(stringRepresentation, contains('HydrationData'));
        expect(stringRepresentation, contains('250ml'));
        expect(stringRepresentation, contains('Water'));
      });
    });

    group('List Extensions', () {
      test('should calculate total water intake correctly', () {
        // Arrange
        final hydrationList = [
          HydrationData.create(amount: 1000), // 1000ml water
          HydrationData.create(
            amount: 1000,
            type: DrinkType.tea,
          ), // 950ml water
          HydrationData.create(
            amount: 1000,
            type: DrinkType.juice,
          ), // 850ml water
        ];

        // Act
        final totalWaterIntake = hydrationList.totalWaterIntake;

        // Assert
        expect(totalWaterIntake, equals(2800)); // 1000 + 950 + 850
      });

      test('should calculate total liquid intake correctly', () {
        // Arrange
        final hydrationList = [
          HydrationData.create(amount: 250),
          HydrationData.create(amount: 300),
          HydrationData.create(amount: 150),
        ];

        // Act
        final totalLiquidIntake = hydrationList.totalLiquidIntake;

        // Assert
        expect(totalLiquidIntake, equals(700)); // 250 + 300 + 150
      });

      test('should filter by date correctly', () {
        // Arrange
        final targetDate = DateTime(2023, 6, 15);
        final otherDate = DateTime(2023, 6, 16);

        final hydrationList = [
          HydrationData(id: '1', amount: 250, timestamp: targetDate),
          HydrationData(id: '2', amount: 300, timestamp: otherDate),
          HydrationData(id: '3', amount: 150, timestamp: targetDate),
        ];

        // Act
        final filteredList = hydrationList.forDate(targetDate);

        // Assert
        expect(filteredList.length, equals(2));
        expect(filteredList.every((data) => data.date == targetDate), isTrue);
      });

      test('should group by date correctly', () {
        // Arrange
        final date1 = DateTime(2023, 6, 15);
        final date2 = DateTime(2023, 6, 16);

        final hydrationList = [
          HydrationData(id: '1', amount: 250, timestamp: date1),
          HydrationData(id: '2', amount: 300, timestamp: date2),
          HydrationData(id: '3', amount: 150, timestamp: date1),
        ];

        // Act
        final groupedData = hydrationList.groupByDate();

        // Assert
        expect(groupedData.keys.length, equals(2));
        expect(groupedData[date1]?.length, equals(2));
        expect(groupedData[date2]?.length, equals(1));
      });

      test('should filter unsynced entries correctly', () {
        // Arrange
        final hydrationList = [
          HydrationData(
            id: '1',
            amount: 250,
            timestamp: DateTime.now(),
            isSynced: true,
          ),
          HydrationData(id: '2', amount: 300, timestamp: DateTime.now()),
          HydrationData(id: '3', amount: 150, timestamp: DateTime.now()),
        ];

        // Act
        final unsyncedEntries = hydrationList.unsyncedEntries;

        // Assert
        expect(unsyncedEntries.length, equals(2));
        expect(unsyncedEntries.every((data) => !data.isSynced), isTrue);
      });
    });

    group('Performance Tests', () {
      test('should handle creation of many instances efficiently', () {
        // Arrange
        const instanceCount = 1000;
        final instances = <HydrationData>[];

        // Act
        final stopwatch = Stopwatch()..start();

        for (var i = 0; i < instanceCount; i++) {
          instances.add(HydrationData.create(amount: i));
        }

        stopwatch.stop();

        // Assert
        expect(instances.length, equals(instanceCount));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });

      test(
        'should handle JSON serialization of many instances efficiently',
        () {
          // Arrange
          const instanceCount = 100;
          final instances = List.generate(
            instanceCount,
            (i) => HydrationData.create(amount: i),
          );

          // Act
          final stopwatch = Stopwatch()..start();

          final jsonList =
              instances.map((instance) => instance.toJson()).toList();

          stopwatch.stop();

          // Assert
          expect(jsonList.length, equals(instanceCount));
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(500),
          ); // Should be reasonably fast
        },
      );
    });

    group('Complex Scenarios', () {
      test('should handle mixed drink types', () {
        // Arrange
        const drinkTypes = DrinkType.values;
        final instances = <HydrationData>[];

        // Act
        for (final drinkType in drinkTypes) {
          instances.add(HydrationData.create(amount: 200, type: drinkType));
        }

        // Assert
        expect(instances.length, equals(drinkTypes.length));

        // Verify all drink types are present
        for (final drinkType in drinkTypes) {
          expect(
            instances.any((instance) => instance.type == drinkType),
            isTrue,
          );
        }
      });

      test('should maintain data integrity during multiple operations', () {
        // Arrange
        final original = HydrationData.create(
          amount: 250,
          notes: 'Test hydration',
        );

        // Act - Multiple serialization/deserialization cycles
        var current = original;
        for (var i = 0; i < 10; i++) {
          final json = current.toJson();
          current = HydrationData.fromJson(json);
        }

        // Assert
        expect(current.id, equals(original.id));
        expect(current.amount, equals(original.amount));
        expect(current.timestamp, equals(original.timestamp));
        expect(current.type, equals(original.type));
        expect(current.notes, equals(original.notes));
        expect(current.isSynced, equals(original.isSynced));
      });
    });
  });
}
