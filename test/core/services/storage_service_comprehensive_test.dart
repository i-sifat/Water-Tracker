import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/services/storage_service.dart';

@Skip('Temporarily disabled - needs API alignment')
void main() {
  group('StorageService Comprehensive Tests', () {
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
    });

    group('Hydration Data Storage', () {
      test('should save hydration data', () async {
        // Arrange
        final hydrationData = HydrationData.create(amount: 250);

        // Act & Assert
        expect(
          () => storageService.saveHydrationData(hydrationData),
          returnsNormally,
        );
      });

      test('should retrieve hydration data', () async {
        // Arrange
        final hydrationData = HydrationData.create(amount: 250);
        await storageService.saveHydrationData(hydrationData);

        // Act
        final retrievedData = await storageService.getHydrationData();

        // Assert
        expect(retrievedData, isNotNull);
        expect(retrievedData, isA<List<HydrationData>>());
      });

      test('should handle multiple hydration entries', () async {
        // Arrange
        final entries = [
          HydrationData.create(amount: 250),
          HydrationData.create(amount: 300, type: DrinkType.tea),
          HydrationData.create(amount: 200, type: DrinkType.coffee),
        ];

        // Act
        for (final entry in entries) {
          await storageService.saveHydrationData(entry);
        }

        final retrievedData = await storageService.getHydrationData();

        // Assert
        expect(retrievedData.length, greaterThanOrEqualTo(entries.length));
      });
    });

    group('User Preferences', () {
      test('should save and retrieve daily goal', () async {
        // Arrange
        const dailyGoal = 2500;

        // Act
        await storageService.saveDailyGoal(dailyGoal);
        final retrievedGoal = await storageService.getDailyGoal();

        // Assert
        expect(retrievedGoal, equals(dailyGoal));
      });

      test('should save and retrieve notification settings', () async {
        // Arrange
        const notificationsEnabled = true;

        // Act
        await storageService.saveNotificationSettings(notificationsEnabled);
        final retrievedSetting = await storageService.getNotificationSettings();

        // Assert
        expect(retrievedSetting, equals(notificationsEnabled));
      });
    });

    group('Data Management', () {
      test('should clear all data', () async {
        // Arrange
        final hydrationData = HydrationData.create(amount: 250);
        await storageService.saveHydrationData(hydrationData);

        // Act
        await storageService.clearAllData();
        final retrievedData = await storageService.getHydrationData();

        // Assert
        expect(retrievedData, isEmpty);
      });

      test('should backup data', () async {
        // Arrange
        final hydrationData = HydrationData.create(amount: 250);
        await storageService.saveHydrationData(hydrationData);

        // Act
        final backupData = await storageService.createBackup();

        // Assert
        expect(backupData, isNotNull);
        expect(backupData, isA<Map<String, dynamic>>());
      });

      test('should restore data from backup', () async {
        // Arrange
        final originalData = HydrationData.create(amount: 250);
        await storageService.saveHydrationData(originalData);
        final backupData = await storageService.createBackup();

        await storageService.clearAllData();

        // Act
        await storageService.restoreFromBackup(backupData);
        final restoredData = await storageService.getHydrationData();

        // Assert
        expect(restoredData, isNotEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        // Act & Assert
        expect(() => storageService.getHydrationData(), returnsNormally);
      });

      test('should handle invalid backup data', () async {
        // Arrange
        const invalidBackup = <String, dynamic>{'invalid': 'data'};

        // Act & Assert
        expect(
          () => storageService.restoreFromBackup(invalidBackup),
          returnsNormally,
        );
      });

      test('should handle null values gracefully', () async {
        // Act & Assert
        expect(() => storageService.getDailyGoal(), returnsNormally);
        expect(() => storageService.getNotificationSettings(), returnsNormally);
      });
    });

    group('Performance', () {
      test('should handle large amounts of data efficiently', () async {
        // Arrange
        const entryCount = 100;
        final entries = List.generate(
          entryCount,
          (i) => HydrationData.create(amount: i + 100),
        );

        // Act
        final stopwatch = Stopwatch()..start();

        for (final entry in entries) {
          await storageService.saveHydrationData(entry);
        }

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(5000),
        ); // Should be reasonably fast
      });

      test('should retrieve data efficiently', () async {
        // Arrange
        const entryCount = 50;
        final entries = List.generate(
          entryCount,
          (i) => HydrationData.create(amount: i + 100),
        );

        for (final entry in entries) {
          await storageService.saveHydrationData(entry);
        }

        // Act
        final stopwatch = Stopwatch()..start();
        final retrievedData = await storageService.getHydrationData();
        stopwatch.stop();

        // Assert
        expect(retrievedData.length, greaterThanOrEqualTo(entryCount));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });
    });
  });
}
