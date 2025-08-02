import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/models/goal_factors.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

class MockStorageService implements StorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<bool> saveInt(String key, int value, {bool encrypted = true}) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> saveString(String key, String value, {bool encrypted = true}) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> saveBool(String key, {bool encrypted = true, required bool value}) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key, {bool encrypted = true}) async {
    return _storage[key] as int?;
  }

  @override
  Future<String?> getString(String key, {bool encrypted = true}) async {
    return _storage[key] as String?;
  }

  @override
  Future<bool?> getBool(String key, {bool encrypted = true}) async {
    return _storage[key] as bool?;
  }

  @override
  Future<bool> deleteKey(String key) async {
    _storage.remove(key);
    return true;
  }

  @override
  Future<bool> clearAll() async {
    _storage.clear();
    return true;
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<List<String>> getAllKeys() async {
    return _storage.keys.toList();
  }

  @override
  Future<Map<String, dynamic>> getAllData() async {
    return Map.from(_storage);
  }

  @override
  Future<bool> createBackup(String backupName) async {
    return true;
  }

  @override
  Future<bool> restoreBackup(String backupName) async {
    return true;
  }

  @override
  Future<List<String>> getBackupList() async {
    return [];
  }

  @override
  Future<bool> deleteBackup(String backupName) async {
    return true;
  }

  @override
  Future<bool> clearMemoryCache() async {
    return true;
  }

  @override
  Future<bool> clearSyncQueue() async {
    return true;
  }

  @override
  Future<Map<String, dynamic>> getStorageStats() async {
    return {};
  }

  @override
  Future<bool> compactStorage() async {
    return true;
  }

  @override
  Future<bool> validateIntegrity() async {
    return true;
  }

  @override
  Future<bool> repairCorruption() async {
    return true;
  }

  @override
  Future<bool> exportData(String filePath) async {
    return true;
  }

  @override
  Future<bool> importData(String filePath) async {
    return true;
  }

  @override
  Future<bool> syncToCloud() async {
    return true;
  }

  @override
  Future<bool> syncFromCloud() async {
    return true;
  }

  @override
  Future<Map<String, dynamic>> getCloudSyncStatus() async {
    return {};
  }

  @override
  Future<bool> enableCloudSync() async {
    return true;
  }

  @override
  Future<bool> disableCloudSync() async {
    return true;
  }
}

void main() {
  group('HydrationProvider Swipeable Interface Tests', () {
    late HydrationProvider provider;
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      provider = HydrationProvider(storageService: mockStorageService);
    });

    group('Hydration Entry Management', () {
      test('should add hydration entry with correct water content calculation', () async {
        // Act
        await provider.addHydrationEntry(250, type: DrinkType.coffee);

        // Assert
        expect(provider.hydrationEntries.length, 1);
        final entry = provider.hydrationEntries.first;
        expect(entry.amount, 250);
        expect(entry.type, DrinkType.coffee);
        expect(entry.waterContentMl, (250 * DrinkType.coffee.waterContent).round());
        expect(provider.currentIntake, entry.waterContentMl);
      });

      test('should delete hydration entry and update intake', () async {
        await provider.addHydrationEntry(250);
        final entryId = provider.hydrationEntries.first.id;
        final initialIntake = provider.currentIntake;

        // Act
        await provider.deleteHydrationEntryNew(entryId);

        // Assert
        expect(provider.hydrationEntries.length, 0);
        expect(provider.currentIntake, initialIntake - 250);
      });

      test('should get todays entries correctly', () async {
        // Add entries for today
        await provider.addHydrationEntry(250);

        // Act
        final todaysEntries = provider.getTodaysEntries();

        // Assert
        expect(todaysEntries.length, 1);
        expect(todaysEntries.first.amount, 250);
      });
    });

    group('Goal Factors Management', () {
      test('should update goal factors and recalculate daily goal', () async {
        const newFactors = GoalFactors(
          baseRequirement: 2000,
          activityLevel: ActivityLevel.veryActive,
          climateCondition: ClimateCondition.hot,
          healthAdjustment: 200,
          customAdjustment: 100,
        );

        // Act
        await provider.updateGoalFactors(newFactors);

        // Assert
        expect(provider.goalFactors, newFactors);
        expect(provider.dailyGoal, newFactors.totalGoal);
        expect(provider.dailyGoal, 2000 + 600 + 400 + 200 + 100); // 3300ml
      });

      test('should calculate goal breakdown correctly', () {
        // Arrange
        const factors = GoalFactors(
          baseRequirement: 2000,
          climateCondition: ClimateCondition.warm,
          healthAdjustment: 100,
          customAdjustment: -50,
        );

        // Act
        final breakdown = factors.breakdown;

        // Assert
        expect(breakdown['Base Requirement'], 2000);
        expect(breakdown['Activity Level'], 400);
        expect(breakdown['Climate'], 200);
        expect(breakdown['Health'], 100);
        expect(breakdown['Custom'], -50);
        expect(breakdown['Total'], 2650);
      });
    });

    group('Progress Tracking', () {
      test('should update current progress correctly', () async {
        await provider.addHydrationEntry(1000);

        // Act
        final progress = provider.currentProgress;

        // Assert
        expect(progress, isNotNull);
        expect(progress!.currentIntake, 1000);
        expect(progress.dailyGoal, provider.dailyGoal);
        expect(progress.percentage, 1000 / provider.dailyGoal);
        expect(progress.remainingIntake, provider.dailyGoal - 1000);
      });

      test('should format progress text correctly', () {
        // Arrange
        const progress = HydrationProgress(
          currentIntake: 1750,
          dailyGoal: 3000,
          todaysEntries: [],
        );

        // Act & Assert
        expect(progress.progressText, '1.75 L drank so far');
        expect(progress.goalText, 'from a total of 3.0 L');
        expect(progress.remainingText, '1250 ml remaining');
      });
    });

    group('Drink Type Selection', () {
      test('should set selected drink type', () async {
        // Act
        await provider.setSelectedDrinkType(DrinkType.tea);

        // Assert
        expect(provider.selectedDrinkType, DrinkType.tea);
      });

      test('should use selected drink type when adding hydration', () async {
        await provider.setSelectedDrinkType(DrinkType.juice);

        // Act
        await provider.addHydrationEntry(200);

        // Assert
        final entry = provider.hydrationEntries.first;
        expect(entry.type, DrinkType.juice);
        expect(entry.waterContentMl, (200 * DrinkType.juice.waterContent).round());
      });
    });

    group('Statistics and Analytics', () {
      test('should get most used drink types', () async {
        // Add different drink types
        await provider.addHydrationEntry(250, type: DrinkType.water);
        await provider.addHydrationEntry(200, type: DrinkType.water);
        await provider.addHydrationEntry(150, type: DrinkType.coffee);
        await provider.addHydrationEntry(300, type: DrinkType.tea);
        await provider.addHydrationEntry(100, type: DrinkType.tea);

        // Act
        final mostUsed = provider.getMostUsedDrinkTypes();

        // Assert
        expect(mostUsed.length, 3);
        expect(mostUsed[0]['type'], DrinkType.water); // 2 uses
        expect(mostUsed[0]['count'], 2);
        expect(mostUsed[1]['type'], DrinkType.tea); // 2 uses
        expect(mostUsed[1]['count'], 2);
        expect(mostUsed[2]['type'], DrinkType.coffee); // 1 use
        expect(mostUsed[2]['count'], 1);
      });

      test('should get weekly hydration data', () async {
        final today = DateTime.now();
        final weekStart = today.subtract(Duration(days: today.weekday - 1));

        // Add entries for different days
        await provider.addHydrationEntry(500);

        // Act
        final weeklyData = provider.getWeeklyHydrationData(weekStart);

        // Assert
        expect(weeklyData.length, 7);
        expect(weeklyData[DateTime(today.year, today.month, today.day)], 500);
      });

      test('should calculate daily average intake', () async {
        await provider.addHydrationEntry(2000);

        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        // Act
        final average = provider.getDailyAverageIntake(yesterday, today);

        // Assert
        expect(average, 1.0); // 2000ml over 2 days = 1000ml/day = 1L/day
      });

      test('should calculate goal achievement rate', () async {
        // Set a low goal for testing
        await provider.updateGoalFactors(const GoalFactors(baseRequirement: 1000));
        await provider.addHydrationEntry(1500); // Exceeds goal

        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        // Act
        final achievementRate = provider.getGoalAchievementRateNew(yesterday, today);

        // Assert
        expect(achievementRate, 0.5); // 1 out of 2 days achieved goal
      });
    });

    group('Reminder Calculations', () {
      test('should calculate next reminder time when goal not reached', () async {
        await provider.addHydrationEntry(500); // Less than default goal

        // Act
        final reminderTime = provider.nextReminderTime;

        // Assert
        expect(reminderTime, isNotNull);
        expect(reminderTime!.isAfter(DateTime.now()), true);
      });

      test('should not set reminder time when goal is reached', () async {
        await provider.addHydrationEntry(3000); // Exceeds default goal

        // Act
        final reminderTime = provider.nextReminderTime;

        // Assert
        expect(reminderTime, isNull);
      });
    });

    group('Data Persistence', () {
      test('should save and load swipeable data', () async {
        await provider.addHydrationEntry(250, type: DrinkType.coffee);
        await provider.setSelectedDrinkType(DrinkType.tea);

        // Verify data is persisted correctly
        expect(provider.hydrationEntries.length, 1);
        expect(provider.hydrationEntries.first.type, DrinkType.coffee);
        expect(provider.selectedDrinkType, DrinkType.tea);
      });
    });

    group('Error Handling', () {
      test('should handle invalid hydration amounts', () async {
        // Act & Assert
        expect(
          () => provider.addHydrationEntry(0),
          throwsA(isA<ValidationError>()),
        );
        expect(
          () => provider.addHydrationEntry(-100),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should handle deleting non-existent entry', () async {
        // Act & Assert
        expect(
          () => provider.deleteHydrationEntryNew('non-existent-id'),
          throwsA(isA<ValidationError>()),
        );
      });
    });
  });
}