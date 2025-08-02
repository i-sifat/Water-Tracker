import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/goal_factors.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

class MockStorageService implements StorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> saveInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  Future<void> saveString(String key, String value, {bool encrypted = true}) async {
    _storage[key] = value;
  }

  @override
  Future<void> saveBool(String key, {required bool value}) async {
    _storage[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    return _storage[key] as int?;
  }

  @override
  Future<String?> getString(String key, {bool encrypted = true}) async {
    return _storage[key] as String?;
  }

  @override
  Future<bool?> getBool(String key) async {
    return _storage[key] as bool?;
  }

  @override
  Future<void> deleteKey(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _storage.clear();
  }
}

void main() {
  group('HydrationProvider Swipeable Interface Simple Tests', () {
    late HydrationProvider provider;
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      provider = HydrationProvider(storageService: mockStorageService);
    });

    test('should initialize provider', () {
      expect(provider, isNotNull);
      expect(provider.isInitialized, isTrue);
    });

    test('should add hydration entry', () async {
      await provider.addHydrationEntry(250);
      
      expect(provider.hydrationEntries.length, 1);
      expect(provider.hydrationEntries.first.amount, 250);
      expect(provider.currentIntake, 250);
    });

    test('should update goal factors', () async {
      const factors = GoalFactors(baseRequirement: 2000);
      await provider.updateGoalFactors(factors);
      
      expect(provider.goalFactors, factors);
      expect(provider.dailyGoal, 2000);
    });

    test('should set selected drink type', () async {
      await provider.setSelectedDrinkType(DrinkType.tea);
      expect(provider.selectedDrinkType, DrinkType.tea);
    });
  });
}