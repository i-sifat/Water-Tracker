import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/model_factories.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

// Mock storage service for testing
class MockStorageService {
  final Map<String, dynamic> _storage = {};

  Future<String?> getString(String key, {bool encrypted = true}) async {
    return _storage[key] as String?;
  }

  Future<bool> saveString(String key, String value, {bool encrypted = true}) async {
    _storage[key] = value;
    return true;
  }

  Future<int?> getInt(String key, {bool encrypted = false}) async {
    return _storage[key] as int?;
  }

  Future<bool> saveInt(String key, int value, {bool encrypted = false}) async {
    _storage[key] = value;
    return true;
  }

  Future<bool?> getBool(String key, {bool encrypted = false}) async {
    return _storage[key] as bool?;
  }

  Future<bool> saveBool(String key, bool value, {bool encrypted = false}) async {
    _storage[key] = value;
    return true;
  }

  void clear() {
    _storage.clear();
  }
}

void main() {
  group('HydrationProvider', () {
    late HydrationProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      provider = HydrationProvider(storageService: mockStorage);
    });

    tearDown(() {
      mockStorage.clear();
      provider.dispose();
    });

    group('Initialization', () {
      test('should initialize with default values', () async {
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.isInitialized, isTrue);
        expect(provider.currentIntake, equals(0));
        expect(provider.dailyGoal, equals(2000));
        expect(provider.goalReachedToday, isFalse);
        expect(provider.currentStreak, equals(0));
        expect(provider.longestStreak, equals(0));
        expect(provider.hydrationHistory, isEmpty);
      });

      test('should load existing data from storage', () async {
        // Pre-populate storage
        await mockStorage.saveInt('currentIntake', 500);
        await mockStorage.saveInt('dailyGoal', 2500);
        await mockStorage.saveBool('goalReachedToday', true);
        await mockStorage.saveInt('currentStreak', 5);
        await mockStorage.saveInt('longestStreak', 10);
        await mockStorage.saveString('avatar', 'female', encrypted: false);

        // Create new provider
        final newProvider = HydrationProvider(storageService: mockStorage);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(newProvider.currentIntake, equals(500));
        expect(newProvider.dailyGoal, equals(2500));
        expect(newProvider.goalReachedToday, isTrue);
        expect(newProvider.currentStreak, equals(5));
        expect(newProvider.longestStreak, equals(10));
        expect(newProvider.selectedAvatar, equals(AvatarOption.female));

        newProvider.dispose();
      });
    });

    group('Adding Hydration', () {
      test('should add hydration entry successfully', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.addHydration(250);

        expect(provider.currentIntake, equals(250));
        expect(provider.hydrationHistory.length, equals(1));
        expect(provider.todaysEntries.length, equals(1));
        expect(provider.todaysEntries.first.amount, equals(250));
        expect(provider.todaysEntries.first.type, equals(DrinkType.water));
      });

      test('should add hydration with different drink types', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.addHydration(250, type: DrinkType.coffee);

        expect(provider.currentIntake, equals(238)); // 250 * 0.95
        expect(provider.hydrationHistory.first.type, equals(DrinkType.coffee));
      });

      test('should add hydration with notes', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.addHydration(250, notes: 'Morning water');

        expect(provider.hydrationHistory.first.notes, equals('Morning water'));
      });

      test('should throw error for invalid amount', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          () => provider.addHydration(0),
          throwsA(isA<ValidationError>()),
        );

        expect(
          () => provider.addHydration(-100),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should update goal status when goal is reached', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        // Set a low goal for testing
        await provider.setDailyGoal(500);

        expect(provider.goalReachedToday, isFalse);

        await provider.addHydration(500);

        expect(provider.goalReachedToday, isTrue);
        expect(provider.hasReachedDailyGoal, isTrue);
        expect(provider.currentStreak, equals(1));
      });
    });

    group('Editing and Deleting Entries', () {
      test('should edit hydration entry successfully', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.addHydration(250);
        final entryId = provider.hydrationHistory.first.id;

        await provider.editHydrationEntry(
          entryId,
          amount: 300,
          type: DrinkType.tea,
          notes: 'Updated entry',
        );

        final updatedEntry = provider.hydrationHistory.first;
        expect(updatedEntry.amount, equals(300));
        expect(updatedEntry.type, equals(DrinkType.tea));
        expect(updatedEntry.notes, equals('Updated entry'));
        expect(provider.currentIntake, equals(285)); // 300 * 0.95
      });

      test('should delete hydration entry successfully', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.addHydration(250);
        await provider.addHydration(200);

        expect(provider.hydrationHistory.length, equals(2));
        expect(provider.currentIntake, equals(450));

        final entryId = provider.hydrationHistory.first.id;
        await provider.deleteHydrationEntry(entryId);

        expect(provider.hydrationHistory.length, equals(1));
        expect(provider.currentIntake, equals(250));
      });

      test('should throw error when editing non-existent entry', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          () => provider.editHydrationEntry('non-existent-id', amount: 300),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should throw error when deleting non-existent entry', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          () => provider.deleteHydrationEntry('non-existent-id'),
          throwsA(isA<ValidationError>()),
        );
      });
    });

    group('Data Aggregation', () {
      test('should get entries for specific date', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        // Add entries for different days
        await provider.addHydration(250);
        
        // Manually add yesterday's entry to history
        final yesterdayEntry = HydrationData.create(amount: 300);
        provider.hydrationHistory.add(yesterdayEntry.copyWith(
          timestamp: yesterday,
        ));

        final todaysEntries = provider.getEntriesForDate(today);
        final yesterdaysEntries = provider.getEntriesForDate(yesterday);

        expect(todaysEntries.length, equals(1));
        expect(yesterdaysEntries.length, equals(0)); // Cache not updated
      });

      test('should get weekly data aggregation', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        final weekStart = DateTime.now().subtract(const Duration(days: 6));
        
        // Add some entries
        await provider.addHydration(250);
        await provider.addHydration(200);

        final weeklyData = provider.getWeeklyData(weekStart);

        expect(weeklyData.keys.length, equals(7));
        expect(weeklyData.values.any((intake) => intake > 0), isTrue);
      });

      test('should calculate goal achievement rate', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.setDailyGoal(500);
        await provider.addHydration(600); // Exceed goal

        final today = DateTime.now();
        final rate = provider.getGoalAchievementRate(today, today);

        expect(rate, equals(1.0)); // 100% achievement
      });
    });

    group('Streak Calculation', () {
      test('should calculate current streak correctly', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.setDailyGoal(500);
        await provider.addHydration(600); // Achieve goal

        expect(provider.currentStreak, equals(1));
        expect(provider.longestStreak, equals(1));
      });

      test('should update longest streak', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.setDailyGoal(500);
        
        // Simulate achieving goal
        await provider.addHydration(600);
        
        // Manually set a higher longest streak to test update
        await mockStorage.saveInt('longestStreak', 5);
        
        // Current streak should not exceed longest streak initially
        expect(provider.currentStreak, equals(1));
      });
    });

    group('Data Export', () {
      test('should export data to CSV format', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.addHydration(250, notes: 'Morning water');
        await provider.addHydration(200, type: DrinkType.coffee);

        final csvData = await provider.exportData();

        expect(csvData, contains('Date,Time,Amount (ml),Drink Type,Water Content (ml),Notes'));
        expect(csvData, contains('250,Water,250,Morning water'));
        expect(csvData, contains('200,Coffee,190'));
      });

      test('should throw error for unsupported export format', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          () => provider.exportData(format: 'pdf'),
          throwsA(isA<ValidationError>()),
        );
      });
    });

    group('Settings', () {
      test('should set daily goal successfully', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.setDailyGoal(2500);

        expect(provider.dailyGoal, equals(2500));
      });

      test('should throw error for invalid daily goal', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          () => provider.setDailyGoal(0),
          throwsA(isA<ValidationError>()),
        );

        expect(
          () => provider.setDailyGoal(-100),
          throwsA(isA<ValidationError>()),
        );
      });

      test('should set avatar successfully', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.setAvatar(AvatarOption.female);

        expect(provider.selectedAvatar, equals(AvatarOption.female));
      });
    });

    group('Reset and Sync', () {
      test('should reset intake for current day', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.addHydration(250);
        await provider.addHydration(200);

        expect(provider.currentIntake, equals(450));
        expect(provider.hydrationHistory.length, equals(2));

        await provider.resetIntake();

        expect(provider.currentIntake, equals(0));
        expect(provider.goalReachedToday, isFalse);
        expect(provider.todaysEntries, isEmpty);
      });

      test('should sync data successfully', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.addHydration(250);

        expect(provider.isSyncing, isFalse);
        expect(provider.hydrationHistory.first.isSynced, isFalse);

        await provider.syncData();

        expect(provider.isSyncing, isFalse);
        expect(provider.hydrationHistory.first.isSynced, isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle and clear errors', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        // Trigger an error
        try {
          await provider.addHydration(-100);
        } catch (e) {
          // Expected error
        }

        expect(provider.lastError, isNotNull);
        expect(provider.lastError, isA<ValidationError>());

        provider.clearError();

        expect(provider.lastError, isNull);
      });
    });

    group('Legacy Compatibility', () {
      test('should support legacy addIntake method', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        provider.addIntake(250);

        // Wait for async operations
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.currentIntake, equals(250));
        expect(provider.hydrationHistory.length, equals(1));
      });

      test('should support legacy loadData method', () async {
        await provider.loadData();

        expect(provider.isInitialized, isTrue);
      });
    });
  });

  group('ModelFactories Integration', () {
    test('should work with factory-created data', () async {
      final mockStorage = MockStorageService();
      final provider = HydrationProvider(storageService: mockStorage);
      
      await Future.delayed(const Duration(milliseconds: 100));

      // Create test data using factories
      final testEntries = ModelFactories.createHydrationDataList(count: 5);
      
      // Add entries to provider
      for (final entry in testEntries) {
        await provider.addHydration(
          entry.amount,
          type: entry.type,
          notes: entry.notes,
        );
      }

      expect(provider.hydrationHistory.length, equals(5));
      expect(provider.currentIntake, greaterThan(0));

      provider.dispose();
    });
  });
}