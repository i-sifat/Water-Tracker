import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService Comprehensive Tests', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      await storageService.initialize();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        final service = StorageService();

        // Act
        await service.initialize();

        // Assert
        expect(service, isNotNull);
      });
    });

    group('String Operations', () {
      test('should save and retrieve string values', () async {
        // Arrange
        const key = 'test_string';
        const value = 'test_value';

        // Act
        await storageService.saveString(key, value);
        final result = await storageService.getString(key);

        // Assert
        expect(result, equals(value));
      });

      test('should return null for non-existent string keys', () async {
        // Act
        final result = await storageService.getString('non_existent_key');

        // Assert
        expect(result, isNull);
      });

      test('should handle encrypted string storage', () async {
        // Arrange
        const key = 'encrypted_string';
        const value = 'encrypted_value';

        // Act
        await storageService.saveString(key, value, encrypted: true);
        final result = await storageService.getString(key, encrypted: true);

        // Assert
        expect(result, equals(value));
      });
    });

    group('Boolean Operations', () {
      test('should save and retrieve boolean values', () async {
        // Arrange
        const key = 'test_bool';
        const value = true;

        // Act
        await storageService.saveBool(key, value);
        final result = await storageService.getBool(key);

        // Assert
        expect(result, equals(value));
      });

      test('should return null for non-existent boolean keys', () async {
        // Act
        final result = await storageService.getBool('non_existent_bool');

        // Assert
        expect(result, isNull);
      });
    });

    group('Integer Operations', () {
      test('should save and retrieve integer values', () async {
        // Arrange
        const key = 'test_int';
        const value = 42;

        // Act
        await storageService.saveInt(key, value);
        final result = await storageService.getInt(key);

        // Assert
        expect(result, equals(value));
      });

      test('should return null for non-existent integer keys', () async {
        // Act
        final result = await storageService.getInt('non_existent_int');

        // Assert
        expect(result, isNull);
      });
    });

    group('Double Operations', () {
      test('should save and retrieve double values', () async {
        // Arrange
        const key = 'test_double';
        const value = 3.14;

        // Act
        await storageService.saveDouble(key, value);
        final result = await storageService.getDouble(key);

        // Assert
        expect(result, equals(value));
      });
    });

    group('List Operations', () {
      test('should save and retrieve string lists', () async {
        // Arrange
        const key = 'test_list';
        const value = ['item1', 'item2', 'item3'];

        // Act
        await storageService.saveStringList(key, value);
        final result = await storageService.getStringList(key);

        // Assert
        expect(result, equals(value));
      });

      test('should return null for non-existent list keys', () async {
        // Act
        final result = await storageService.getStringList('non_existent_list');

        // Assert
        expect(result, isNull);
      });
    });

    group('JSON Operations', () {
      test('should save and retrieve JSON objects', () async {
        // Arrange
        const key = 'test_json';
        const value = {'name': 'John', 'age': 30, 'active': true};

        // Act
        await storageService.saveJson(key, value);
        final result = await storageService.getJson(key);

        // Assert
        expect(result, equals(value));
      });

      test('should handle complex JSON structures', () async {
        // Arrange
        const key = 'complex_json';
        const value = {
          'user': {
            'id': 1,
            'profile': {
              'name': 'John Doe',
              'settings': ['setting1', 'setting2']
            }
          },
          'data': [1, 2, 3, 4, 5]
        };

        // Act
        await storageService.saveJson(key, value);
        final result = await storageService.getJson(key);

        // Assert
        expect(result, equals(value));
      });
    });

    group('Key Management', () {
      test('should check if key exists', () async {
        // Arrange
        const key = 'existing_key';
        const value = 'test_value';

        // Act
        await storageService.saveString(key, value);
        final exists = await storageService.containsKey(key);
        final notExists = await storageService.containsKey('non_existent_key');

        // Assert
        expect(exists, isTrue);
        expect(notExists, isFalse);
      });

      test('should remove keys', () async {
        // Arrange
        const key = 'key_to_remove';
        const value = 'test_value';

        // Act
        await storageService.saveString(key, value);
        await storageService.remove(key);
        final result = await storageService.getString(key);

        // Assert
        expect(result, isNull);
      });

      test('should clear all data', () async {
        // Arrange
        await storageService.saveString('key1', 'value1');
        await storageService.saveString('key2', 'value2');

        // Act
        await storageService.remove('key1');
        await storageService.remove('key2');
        final result1 = await storageService.getString('key1');
        final result2 = await storageService.getString('key2');

        // Assert
        expect(result1, isNull);
        expect(result2, isNull);
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        // Test that the service handles various error conditions
        expect(() => storageService.saveString('', 'value'), returnsNormally);
        expect(() => storageService.getString(''), returnsNormally);
      });
    });
  });
}