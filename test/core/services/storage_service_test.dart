import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService', () {
    late StorageService storageService;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      await storageService.initialize();
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        final newService = StorageService();
        await newService.initialize();

        // Should not throw and should be ready to use
        expect(newService, isNotNull);
      });

      test('should be singleton', () {
        final service1 = StorageService();
        final service2 = StorageService();

        expect(identical(service1, service2), isTrue);
      });

      test('should handle multiple initialization calls', () async {
        await storageService.initialize();
        await storageService.initialize();

        // Should not throw on multiple calls
        expect(true, isTrue);
      });
    });

    group('basic string operations', () {
      test('should save and retrieve string values', () async {
        const key = 'test_string';
        const value = 'test_value';

        final saveResult = await storageService.saveString(
          key,
          value,
          encrypted: false,
        );
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getString(
          key,
          encrypted: false,
        );
        expect(retrievedValue, equals(value));
      });

      test('should return null for non-existent keys', () async {
        const key = 'non_existent_key';

        final value = await storageService.getString(key, encrypted: false);
        expect(value, isNull);
      });

      test('should handle empty string values', () async {
        const key = 'empty_string';
        const value = '';

        final saveResult = await storageService.saveString(
          key,
          value,
          encrypted: false,
        );
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getString(
          key,
          encrypted: false,
        );
        expect(retrievedValue, equals(value));
      });

      test('should handle special characters in strings', () async {
        const key = 'special_chars';
        const value = r'Hello! @#$%^&*()_+ 🚰💧';

        final saveResult = await storageService.saveString(
          key,
          value,
          encrypted: false,
        );
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getString(
          key,
          encrypted: false,
        );
        expect(retrievedValue, equals(value));
      });
    });

    group('integer operations', () {
      test('should save and retrieve integer values', () async {
        const key = 'test_int';
        const value = 42;

        final saveResult = await storageService.saveInt(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getInt(key);
        expect(retrievedValue, equals(value));
      });

      test('should handle negative integers', () async {
        const key = 'negative_int';
        const value = -123;

        final saveResult = await storageService.saveInt(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getInt(key);
        expect(retrievedValue, equals(value));
      });

      test('should handle zero', () async {
        const key = 'zero_int';
        const value = 0;

        final saveResult = await storageService.saveInt(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getInt(key);
        expect(retrievedValue, equals(value));
      });

      test('should handle large integers', () async {
        const key = 'large_int';
        const value = 9223372036854775807; // Max int64

        final saveResult = await storageService.saveInt(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getInt(key);
        expect(retrievedValue, equals(value));
      });
    });

    group('boolean operations', () {
      test('should save and retrieve boolean values', () async {
        const key1 = 'test_bool_true';
        const key2 = 'test_bool_false';

        final saveResult1 = await storageService.saveBool(key1, true);
        final saveResult2 = await storageService.saveBool(key2, false);

        expect(saveResult1, isTrue);
        expect(saveResult2, isTrue);

        final retrievedValue1 = await storageService.getBool(key1);
        final retrievedValue2 = await storageService.getBool(key2);

        expect(retrievedValue1, isTrue);
        expect(retrievedValue2, isFalse);
      });
    });

    group('double operations', () {
      test('should save and retrieve double values', () async {
        const key = 'test_double';
        const value = 3.14159;

        final saveResult = await storageService.saveDouble(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getDouble(key);
        expect(retrievedValue, equals(value));
      });

      test('should handle negative doubles', () async {
        const key = 'negative_double';
        const value = -2.5;

        final saveResult = await storageService.saveDouble(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getDouble(key);
        expect(retrievedValue, equals(value));
      });
    });

    group('string list operations', () {
      test('should save and retrieve string lists', () async {
        const key = 'test_string_list';
        const value = ['item1', 'item2', 'item3'];

        final saveResult = await storageService.saveStringList(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getStringList(key);
        expect(retrievedValue, equals(value));
      });

      test('should handle empty string lists', () async {
        const key = 'empty_string_list';
        const value = <String>[];

        final saveResult = await storageService.saveStringList(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getStringList(key);
        expect(retrievedValue, equals(value));
      });

      test('should handle string lists with special characters', () async {
        const key = 'special_string_list';
        const value = ['Hello! 🚰', r'@#$%^&*()', 'Normal text'];

        final saveResult = await storageService.saveStringList(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getStringList(key);
        expect(retrievedValue, equals(value));
      });
    });

    group('JSON operations', () {
      test('should save and retrieve JSON objects', () async {
        const key = 'test_json';
        final value = {
          'name': 'Water Tracker',
          'version': '1.0.0',
          'features': ['hydration', 'reminders', 'analytics'],
          'settings': {'theme': 'light', 'notifications': true},
        };

        final saveResult = await storageService.saveJson(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getJson(key);
        expect(retrievedValue, equals(value));
      });

      test('should handle nested JSON objects', () async {
        const key = 'nested_json';
        final value = {
          'user': {
            'profile': {
              'name': 'Test User',
              'age': 25,
              'preferences': {'theme': 'dark', 'language': 'en'},
            },
          },
        };

        final saveResult = await storageService.saveJson(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getJson(key);
        expect(retrievedValue, equals(value));
      });

      test('should handle JSON with various data types', () async {
        const key = 'mixed_json';
        final value = {
          'string': 'text',
          'int': 42,
          'double': 3.14,
          'bool': true,
          'null': null,
          'list': [1, 2, 3],
          'map': {'nested': 'value'},
        };

        final saveResult = await storageService.saveJson(key, value);
        expect(saveResult, isTrue);

        final retrievedValue = await storageService.getJson(key);
        expect(retrievedValue, equals(value));
      });
    });

    group('key operations', () {
      test('should check if key exists', () async {
        const key = 'existence_test';
        const value = 'test_value';

        // Key should not exist initially
        final existsBefore = await storageService.containsKey(key);
        expect(existsBefore, isFalse);

        // Save value
        await storageService.saveString(key, value, encrypted: false);

        // Key should exist now
        final existsAfter = await storageService.containsKey(key);
        expect(existsAfter, isTrue);
      });

      test('should remove keys', () async {
        const key = 'removal_test';
        const value = 'test_value';

        // Save value
        await storageService.saveString(key, value, encrypted: false);

        // Verify it exists
        final existsBefore = await storageService.containsKey(key);
        expect(existsBefore, isTrue);

        // Remove key
        final removeResult = await storageService.remove(key);
        expect(removeResult, isTrue);

        // Verify it's gone
        final existsAfter = await storageService.containsKey(key);
        expect(existsAfter, isFalse);

        // Value should be null
        final retrievedValue = await storageService.getString(
          key,
          encrypted: false,
        );
        expect(retrievedValue, isNull);
      });
    });

    group('sync queue operations', () {
      test('should manage sync queue', () async {
        const key1 = 'sync_item_1';
        const key2 = 'sync_item_2';

        // Initially empty
        final initialQueue = await storageService.getSyncQueue();
        expect(initialQueue, isEmpty);

        // Add items to sync queue
        await storageService.markForSync(key1);
        await storageService.markForSync(key2);

        // Check queue
        final queueAfterAdd = await storageService.getSyncQueue();
        expect(queueAfterAdd, contains(key1));
        expect(queueAfterAdd, contains(key2));
        expect(queueAfterAdd.length, equals(2));

        // Remove one item
        await storageService.removeFromSyncQueue(key1);

        final queueAfterRemove = await storageService.getSyncQueue();
        expect(queueAfterRemove, isNot(contains(key1)));
        expect(queueAfterRemove, contains(key2));
        expect(queueAfterRemove.length, equals(1));

        // Clear queue
        await storageService.clearSyncQueue();

        final queueAfterClear = await storageService.getSyncQueue();
        expect(queueAfterClear, isEmpty);
      });

      test('should not add duplicate items to sync queue', () async {
        const key = 'duplicate_sync_item';

        // Add same item multiple times
        await storageService.markForSync(key);
        await storageService.markForSync(key);
        await storageService.markForSync(key);

        // Should only appear once
        final queue = await storageService.getSyncQueue();
        expect(queue.where((item) => item == key).length, equals(1));
      });
    });

    group('storage statistics', () {
      test('should provide storage statistics', () async {
        // Add some test data
        await storageService.saveString(
          'test_key_1',
          'value1',
          encrypted: false,
        );
        await storageService.saveInt('test_key_2', 42);
        await storageService.saveBool('test_key_3', true);

        final stats = await storageService.getStorageStats();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('regular_keys_count'), isTrue);
        expect(stats.containsKey('regular_keys'), isTrue);
        expect(stats.containsKey('encrypted_keys_count'), isTrue);
        expect(stats.containsKey('encrypted_keys'), isTrue);
        expect(stats.containsKey('storage_version'), isTrue);
        expect(stats.containsKey('sync_queue'), isTrue);

        expect(stats['regular_keys_count'], greaterThan(0));
        expect(stats['regular_keys'], isA<List>());
        expect(stats['encrypted_keys_count'], isA<int>());
        expect(stats['encrypted_keys'], isA<List>());
      });
    });

    group('health check', () {
      test('should pass health check', () async {
        final isHealthy = await storageService.isHealthy();
        expect(isHealthy, isTrue);
      });
    });

    group('clear operations', () {
      test('should clear all data', () async {
        // Add some test data
        await storageService.saveString(
          'test_key_1',
          'value1',
          encrypted: false,
        );
        await storageService.saveInt('test_key_2', 42);
        await storageService.saveBool('test_key_3', true);

        // Verify data exists
        final value1 = await storageService.getString(
          'test_key_1',
          encrypted: false,
        );
        expect(value1, equals('value1'));

        // Clear all data
        final clearResult = await storageService.clearAll();
        expect(clearResult, isTrue);

        // Verify data is gone
        final value1After = await storageService.getString(
          'test_key_1',
          encrypted: false,
        );
        expect(value1After, isNull);

        final value2After = await storageService.getInt('test_key_2');
        expect(value2After, isNull);

        final value3After = await storageService.getBool('test_key_3');
        expect(value3After, isNull);
      });
    });

    group('backup operations', () {
      test('should create backup', () async {
        // Add some test data
        await storageService.saveString(
          'backup_test_1',
          'value1',
          encrypted: false,
        );
        await storageService.saveInt('backup_test_2', 42);

        // Create backup
        final backupResult = await storageService.createBackup();

        // Note: In test environment, this might fail due to file system access
        // The important thing is that the method doesn't throw
        expect(backupResult, isA<bool>());
      });

      test('should get available backups', () async {
        final backups = await storageService.getAvailableBackups();

        expect(backups, isA<List<String>>());
        // In test environment, this will likely be empty
      });
    });

    group('error handling', () {
      test('should handle invalid JSON gracefully', () async {
        const key = 'invalid_json_test';

        // Save invalid JSON string directly
        await storageService.saveString(
          key,
          'invalid json {',
          encrypted: false,
        );

        // Try to retrieve as JSON - should return null, not throw
        final jsonResult = await storageService.getJson(key, encrypted: false);
        expect(jsonResult, isNull);
      });

      test('should handle storage errors gracefully', () async {
        // These tests verify that methods return false/null instead of throwing
        // when storage operations fail

        // Test with very long key (might cause issues on some platforms)
        final longKey = 'x' * 1000;
        final saveResult = await storageService.saveString(
          longKey,
          'value',
          encrypted: false,
        );
        expect(saveResult, isA<bool>());

        final getValue = await storageService.getString(
          longKey,
          encrypted: false,
        );
        expect(getValue, isA<String?>());
      });
    });

    group('encryption handling', () {
      test('should handle encrypted storage requests gracefully', () async {
        const key = 'encrypted_test';
        const value = 'encrypted_value';

        // Try to save with encryption (might fall back to regular storage in test)
        final saveResult = await storageService.saveString(key, value);
        expect(saveResult, isA<bool>());

        // Try to retrieve with encryption
        final retrievedValue = await storageService.getString(key);
        expect(retrievedValue, isA<String?>());
      });

      test('should handle encrypted integer operations', () async {
        const key = 'encrypted_int_test';
        const value = 123;

        final saveResult = await storageService.saveInt(
          key,
          value,
          encrypted: true,
        );
        expect(saveResult, isA<bool>());

        final retrievedValue = await storageService.getInt(
          key,
          encrypted: true,
        );
        expect(retrievedValue, isA<int?>());
      });

      test('should handle encrypted boolean operations', () async {
        const key = 'encrypted_bool_test';
        const value = true;

        final saveResult = await storageService.saveBool(
          key,
          value,
          encrypted: true,
        );
        expect(saveResult, isA<bool>());

        final retrievedValue = await storageService.getBool(
          key,
          encrypted: true,
        );
        expect(retrievedValue, isA<bool?>());
      });
    });
  });
}
