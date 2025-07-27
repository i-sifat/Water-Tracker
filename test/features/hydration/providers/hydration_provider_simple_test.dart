import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

// Simple mock storage service for testing
class SimpleStorageService {
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
  group('HydrationProvider Basic Tests', () {
    late HydrationProvider provider;
    late SimpleStorageService mockStorage;

    setUp(() {
      mockStorage = SimpleStorageService();
      provider = HydrationProvider(storageService: mockStorage);
    });

    tearDown(() {
      mockStorage.clear();
      provider.dispose();
    });

    test('should initialize with default values', () async {
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 200));

      expect(provider.isInitialized, isTrue);
      expect(provider.currentIntake, equals(0));
      expect(provider.dailyGoal, equals(2000));
      expect(provider.goalReachedToday, isFalse);
      expect(provider.currentStreak, equals(0));
      expect(provider.longestStreak, equals(0));
      expect(provider.hydrationHistory, isEmpty);
    });

    test('should add hydration entry successfully', () async {
      await Future.delayed(const Duration(milliseconds: 200));

      await provider.addHydration(250);

      expect(provider.currentIntake, equals(250));
      expect(provider.hydrationHistory.length, equals(1));
      expect(provider.todaysEntries.length, equals(1));
      expect(provider.todaysEntries.first.amount, equals(250));
      expect(provider.todaysEntries.first.type, equals(DrinkType.water));
    });

    test('should add hydration with different drink types', () async {
      await Future.delayed(const Duration(milliseconds: 200));

      await provider.addHydration(250, type: DrinkType.coffee);

      expect(provider.currentIntake, equals(238)); // 250 * 0.95
      expect(provider.hydrationHistory.first.type, equals(DrinkType.coffee));
    });

    test('should set daily goal successfully', () async {
      await Future.delayed(const Duration(milliseconds: 200));

      await provider.setDailyGoal(2500);

      expect(provider.dailyGoal, equals(2500));
    });

    test('should set avatar successfully', () async {
      await Future.delayed(const Duration(milliseconds: 200));

      await provider.setAvatar(AvatarOption.female);

      expect(provider.selectedAvatar, equals(AvatarOption.female));
    });

    test('should calculate intake percentage correctly', () async {
      await Future.delayed(const Duration(milliseconds: 200));

      await provider.setDailyGoal(1000);
      await provider.addHydration(250);

      expect(provider.intakePercentage, equals(0.25)); // 250/1000 = 0.25
    });

    test('should update goal status when goal is reached', () async {
      await Future.delayed(const Duration(milliseconds: 200));

      // Set a low goal for testing
      await provider.setDailyGoal(500);

      expect(provider.goalReachedToday, isFalse);

      await provider.addHydration(500);

      expect(provider.goalReachedToday, isTrue);
      expect(provider.hasReachedDailyGoal, isTrue);
    });

    test('should support legacy addIntake method', () async {
      await Future.delayed(const Duration(milliseconds: 200));

      provider.addIntake(250);

      // Wait for async operations
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.currentIntake, equals(250));
      expect(provider.hydrationHistory.length, equals(1));
    });
  });
}