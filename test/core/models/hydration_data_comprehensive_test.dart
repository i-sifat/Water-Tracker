import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';

void main() {
  group('HydrationData Comprehensive Tests', () {
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
          type: drinkType,
        );

        // Assert
        expect(entry.amount, equals(amount));
        expect(entry.timestamp, equals(timestamp));
        expect(entry.type, equals(drinkType));
        expect(entry.id, equals('test-id'));
      });

      test('should create HydrationEntry with optional fields', () {
        // Arrange
        final timestamp = DateTime.now();
        const amount = 250.0;
        const drinkType = 'coffee';
        const temperature = DrinkTemperature.hot;
        const notes = 'Morning coffee';

        // Act
        final entry = HydrationEntry(
          amount: amount,
          timestamp: timestamp,
          drinkType: drinkType,
          temperature: temperature,
          notes: notes,
        );

        // Assert
        expect(entry.temperature, equals(temperature));
        expect(entry.notes, equals(notes));
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final timestamp = DateTime.now();
        final entry = HydrationEntry(
          amount: 250.0,
          timestamp: timestamp,
          drinkType: 'water',
          temperature: DrinkTemperature.cold,
          notes: 'Test entry',
        );

        // Act
        final json = entry.toJson();

        // Assert
        expect(json['amount'], equals(250.0));
        expect(json['timestamp'], equals(timestamp.millisecondsSinceEpoch));
        expect(json['drinkType'], equals('water'));
        expect(json['temperature'], equals('cold'));
        expect(json['notes'], equals('Test entry'));
        expect(json['id'], isNotNull);
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id',
          'amount': 300.0,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'drinkType': 'tea',
          'temperature': 'hot',
          'notes': 'Afternoon tea',
        };

        // Act
        final entry = HydrationEntry.fromJson(json);

        // Assert
        expect(entry.id, equals('test-id'));
        expect(entry.amount, equals(300.0));
        expect(entry.timestamp, equals(timestamp));
        expect(entry.drinkType, equals('tea'));
        expect(entry.temperature, equals(DrinkTemperature.hot));
        expect(entry.notes, equals('Afternoon tea'));
      });

      test('should handle missing optional fields in JSON', () {
        // Arrange
        final timestamp = DateTime.now();
        final json = {
          'id': 'test-id',
          'amount': 250.0,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'drinkType': 'water',
        };

        // Act
        final entry = HydrationEntry.fromJson(json);

        // Assert
        expect(entry.temperature, isNull);
        expect(entry.notes, isNull);
      });

      test('should calculate hydration value based on drink type', () {
        // Arrange
        final waterEntry = HydrationEntry(
          amount: 250.0,
          timestamp: DateTime.now(),
          drinkType: 'water',
        );
        final coffeeEntry = HydrationEntry(
          amount: 250.0,
          timestamp: DateTime.now(),
          drinkType: 'coffee',
        );

        // Act
        final waterValue = waterEntry.hydrationValue;
        final coffeeValue = coffeeEntry.hydrationValue;

        // Assert
        expect(waterValue, equals(250.0));
        expect(coffeeValue, lessThan(250.0));
      });

      test('should support equality comparison', () {
        // Arrange
        final timestamp = DateTime.now();
        final entry1 = HydrationEntry(
          id: 'same-id',
          amount: 250.0,
          timestamp: timestamp,
          drinkType: 'water',
        );
        final entry2 = HydrationEntry(
          id: 'same-id',
          amount: 250.0,
          timestamp: timestamp,
          drinkType: 'water',
        );
        final entry3 = HydrationEntry(
          id: 'different-id',
          amount: 250.0,
          timestamp: timestamp,
          drinkType: 'water',
        );

        // Act & Assert
        expect(entry1, equals(entry2));
        expect(entry1, isNot(equals(entry3)));
      });
    });

    group('DailyHydrationData', () {
      test('should create DailyHydrationData with entries', () {
        // Arrange
        final date = DateTime.now();
        final entries = [
          HydrationEntry(
            amount: 250.0,
            timestamp: date,
            drinkType: 'water',
          ),
          HydrationEntry(
            amount: 200.0,
            timestamp: date.add(const Duration(hours: 1)),
            drinkType: 'coffee',
          ),
        ];

        // Act
        final dailyData = DailyHydrationData(
          date: date,
          entries: entries,
          goalAmount: 2000.0,
        );

        // Assert
        expect(dailyData.date, equals(date));
        expect(dailyData.entries.length, equals(2));
        expect(dailyData.goalAmount, equals(2000.0));
      });

      test('should calculate total intake correctly', () {
        // Arrange
        final date = DateTime.now();
        final entries = [
          HydrationEntry(amount: 250.0, timestamp: date, drinkType: 'water'),
          HydrationEntry(amount: 300.0, timestamp: date, drinkType: 'water'),
          HydrationEntry(amount: 200.0, timestamp: date, drinkType: 'coffee'),
        ];
        final dailyData = DailyHydrationData(
          date: date,
          entries: entries,
          goalAmount: 2000.0,
        );

        // Act
        final totalIntake = dailyData.totalIntake;

        // Assert
        expect(totalIntake, equals(750.0));
      });

      test('should calculate progress percentage correctly', () {
        // Arrange
        final date = DateTime.now();
        final entries = [
          HydrationEntry(amount: 1000.0, timestamp: date, drinkType: 'water'),
        ];
        final dailyData = DailyHydrationData(
          date: date,
          entries: entries,
          goalAmount: 2000.0,
        );

        // Act
        final progress = dailyData.progressPercentage;

        // Assert
        expect(progress, equals(0.5));
      });

      test('should detect goal completion', () {
        // Arrange
        final date = DateTime.now();
        final completedEntries = [
          HydrationEntry(amount: 2000.0, timestamp: date, drinkType: 'water'),
        ];
        final incompleteEntries = [
          HydrationEntry(amount: 1000.0, timestamp: date, drinkType: 'water'),
        ];

        final completedData = DailyHydrationData(
          date: date,
          entries: completedEntries,
          goalAmount: 2000.0,
        );
        final incompleteData = DailyHydrationData(
          date: date,
          entries: incompleteEntries,
          goalAmount: 2000.0,
        );

        // Act & Assert
        expect(completedData.isGoalCompleted, isTrue);
        expect(incompleteData.isGoalCompleted, isFalse);
      });

      test('should add entries correctly', () {
        // Arrange
        final date = DateTime.now();
        final dailyData = DailyHydrationData(
          date: date,
          entries: [],
          goalAmount: 2000.0,
        );
        final newEntry = HydrationEntry(
          amount: 250.0,
          timestamp: date,
          drinkType: 'water',
        );

        // Act
        dailyData.addEntry(newEntry);

        // Assert
        expect(dailyData.entries.length, equals(1));
        expect(dailyData.entries.first, equals(newEntry));
      });

      test('should remove entries correctly', () {
        // Arrange
        final date = DateTime.now();
        final entry = HydrationEntry(
          amount: 250.0,
          timestamp: date,
          drinkType: 'water',
        );
        final dailyData = DailyHydrationData(
          date: date,
          entries: [entry],
          goalAmount: 2000.0,
        );

        // Act
        final removed = dailyData.removeEntry(entry.id);

        // Assert
        expect(removed, isTrue);
        expect(dailyData.entries.isEmpty, isTrue);
      });

      test('should get entries by drink type', () {
        // Arrange
        final date = DateTime.now();
        final entries = [
          HydrationEntry(amount: 250.0, timestamp: date, drinkType: 'water'),
          HydrationEntry(amount: 200.0, timestamp: date, drinkType: 'coffee'),
          HydrationEntry(amount: 300.0, timestamp: date, drinkType: 'water'),
        ];
        final dailyData = DailyHydrationData(
          date: date,
          entries: entries,
          goalAmount: 2000.0,
        );

        // Act
        final waterEntries = dailyData.getEntriesByType('water');
        final coffeeEntries = dailyData.getEntriesByType('coffee');

        // Assert
        expect(waterEntries.length, equals(2));
        expect(coffeeEntries.length, equals(1));
        expect(waterEntries.every((e) => e.drinkType == 'water'), isTrue);
        expect(coffeeEntries.every((e) => e.drinkType == 'coffee'), isTrue);
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final date = DateTime.now();
        final entries = [
          HydrationEntry(amount: 250.0, timestamp: date, drinkType: 'water'),
        ];
        final dailyData = DailyHydrationData(
          date: date,
          entries: entries,
          goalAmount: 2000.0,
        );

        // Act
        final json = dailyData.toJson();

        // Assert
        expect(json['date'], equals(date.toIso8601String()));
        expect(json['entries'], isA<List>());
        expect(json['goalAmount'], equals(2000.0));
        expect(json['totalIntake'], equals(250.0));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final date = DateTime.now();
        final json = {
          'date': date.toIso8601String(),
          'entries': [
            {
              'id': 'entry-1',
              'amount': 250.0,
              'timestamp': date.millisecondsSinceEpoch,
              'drinkType': 'water',
            }
          ],
          'goalAmount': 2000.0,
        };

        // Act
        final dailyData = DailyHydrationData.fromJson(json);

        // Assert
        expect(dailyData.date.day, equals(date.day));
        expect(dailyData.entries.length, equals(1));
        expect(dailyData.goalAmount, equals(2000.0));
      });
    });

    group('DrinkTemperature Enum', () {
      test('should convert to string correctly', () {
        // Act & Assert
        expect(DrinkTemperature.hot.toString(), contains('hot'));
        expect(DrinkTemperature.cold.toString(), contains('cold'));
        expect(DrinkTemperature.room.toString(), contains('room'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty entries list', () {
        // Arrange
        final dailyData = DailyHydrationData(
          date: DateTime.now(),
          entries: [],
          goalAmount: 2000.0,
        );

        // Act & Assert
        expect(dailyData.totalIntake, equals(0.0));
        expect(dailyData.progressPercentage, equals(0.0));
        expect(dailyData.isGoalCompleted, isFalse);
      });

      test('should handle zero goal amount', () {
        // Arrange
        final dailyData = DailyHydrationData(
          date: DateTime.now(),
          entries: [
            HydrationEntry(
              amount: 250.0,
              timestamp: DateTime.now(),
              drinkType: 'water',
            ),
          ],
          goalAmount: 0.0,
        );

        // Act & Assert
        expect(dailyData.progressPercentage, equals(0.0));
        expect(dailyData.isGoalCompleted, isFalse);
      });

      test('should handle very large amounts', () {
        // Arrange
        final entry = HydrationEntry(
          amount: 999999.0,
          timestamp: DateTime.now(),
          drinkType: 'water',
        );

        // Act & Assert
        expect(entry.amount, equals(999999.0));
        expect(() => entry.toJson(), returnsNormally);
      });
    });
  });
}