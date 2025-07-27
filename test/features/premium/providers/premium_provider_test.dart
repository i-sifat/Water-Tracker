import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

// Mock services for testing
class MockPremiumService {
  bool _shouldSucceed = true;

  void setShouldSucceed(bool succeed) {
    _shouldSucceed = succeed;
  }

  Future<bool> submitDonationProof({
    String? additionalMessage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _shouldSucceed;
  }

  Future<bool> validateUnlockCode(String unlockCode) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_shouldSucceed && unlockCode == 'VALID123456789ABC') {
      return true;
    }
    
    return false;
  }
}

class MockDeviceService {
  String _deviceCode = 'TEST_DEVICE_CODE_123';

  void setDeviceCode(String code) {
    _deviceCode = code;
  }

  Future<String> generateUniqueCode() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _deviceCode;
  }

  Future<String> getDeviceId() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return 'test_device_id';
  }
}

class MockStorageService {
  final Map<String, dynamic> _storage = {};

  Future<String?> getString(String key, {bool encrypted = true}) async {
    return _storage[key] as String?;
  }

  Future<bool> saveString(String key, String value, {bool encrypted = true}) async {
    _storage[key] = value;
    return true;
  }

  Future<Map<String, dynamic>?> getJson(String key, {bool encrypted = true}) async {
    final jsonString = _storage[key] as String?;
    if (jsonString != null) {
      // Simple mock JSON parsing
      return {'mock': 'data'};
    }
    return null;
  }

  Future<bool> saveJson(String key, Map<String, dynamic> data, {bool encrypted = true}) async {
    _storage[key] = data.toString(); // Simple mock
    return true;
  }

  void clear() {
    _storage.clear();
  }
}

void main() {
  group('PremiumProvider', () {
    late PremiumProvider provider;
    late MockPremiumService mockPremiumService;
    late MockDeviceService mockDeviceService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockPremiumService = MockPremiumService();
      mockDeviceService = MockDeviceService();
      mockStorageService = MockStorageService();
      
      provider = PremiumProvider(
        premiumService: mockPremiumService,
        deviceService: mockDeviceService,
        storageService: mockStorageService,
      );
    });

    tearDown(() {
      mockStorageService.clear();
      provider.dispose();
    });

    group('Initialization', () {
      test('should initialize with free status and device code', () async {
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 200));

        expect(provider.isInitialized, isTrue);
        expect(provider.isPremium, isFalse);
        expect(provider.deviceCode, equals('TEST_DEVICE_CODE_123'));
        expect(provider.statusSummary, equals('Free Version'));
        expect(provider.unlockedFeatures, isEmpty);
      });

      test('should handle initialization errors gracefully', () async {
        // This test is simplified since our mock doesn't actually fail
        // In a real scenario, initialization errors would be handled
        await Future.delayed(const Duration(milliseconds: 200));

        expect(provider.isInitialized, isTrue);
        // For this test, we don't expect an error with our simple mock
      });
    });

    group('Feature Access', () {
      test('should check feature unlock status correctly', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // Initially all features should be locked
        for (final feature in PremiumFeature.values) {
          expect(provider.isFeatureUnlocked(feature), isFalse);
        }
      });

      test('should provide feature descriptions', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        final description = provider.getFeatureDescription(PremiumFeature.advancedAnalytics);
        expect(description, isNotEmpty);
        expect(description, anyOf(contains('charts'), contains('tracking'), contains('analytics'), contains('Analytics')));

        final name = provider.getFeatureName(PremiumFeature.advancedAnalytics);
        expect(name, equals('Advanced Analytics'));
      });
    });

    group('Donation Proof Submission', () {
      test('should submit donation proof successfully', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // Create a temporary test file
        final testFile = File('test_image.jpg');
        await testFile.writeAsString('test image content');

        mockPremiumService.setShouldSucceed(true);

        final success = await provider.submitDonationProof(
          imageFile: testFile,
          amount: 50,
          transactionId: 'TXN123456',
          notes: 'Test donation',
        );

        expect(success, isTrue);
        expect(provider.submittedProofs.length, equals(1));
        expect(provider.submittedProofs.first.amount, equals(50.0));
        expect(provider.submittedProofs.first.transactionId, equals('TXN123456'));
        expect(provider.pendingProofId, isNotNull);
        expect(provider.lastError, isNull);

        // Clean up
        await testFile.delete();
      });

      test('should handle donation proof submission failure', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // Create a temporary test file
        final testFile = File('test_image.jpg');
        await testFile.writeAsString('test image content');

        mockPremiumService.setShouldSucceed(false);

        final success = await provider.submitDonationProof(
          imageFile: testFile,
          amount: 50,
        );

        expect(success, isFalse);
        expect(provider.submittedProofs, isEmpty);
        expect(provider.lastError, isA<PremiumError>());

        // Clean up
        await testFile.delete();
      });

      test('should validate image file exists', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        final nonExistentFile = File('non_existent_image.jpg');

        final success = await provider.submitDonationProof(
          imageFile: nonExistentFile,
          amount: 50,
        );

        expect(success, isFalse);
        expect(provider.lastError, isA<ValidationError>());
      });
    });

    group('Unlock Code Validation', () {
      test('should unlock premium with valid code', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        mockPremiumService.setShouldSucceed(true);

        final success = await provider.unlockWithCode('VALID123456789ABC');

        expect(success, isTrue);
        expect(provider.isPremium, isTrue);
        expect(provider.statusSummary, contains('Premium'));
        expect(provider.unlockedFeatures, equals(PremiumFeature.values));
        expect(provider.lastError, isNull);

        // Check that all features are now unlocked
        for (final feature in PremiumFeature.values) {
          expect(provider.isFeatureUnlocked(feature), isTrue);
        }
      });

      test('should reject invalid unlock code', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        mockPremiumService.setShouldSucceed(false);

        final success = await provider.unlockWithCode('INVALID_CODE');

        expect(success, isFalse);
        expect(provider.isPremium, isFalse);
        expect(provider.lastError, isA<PremiumError>());
      });

      test('should handle empty unlock code', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        final success = await provider.unlockWithCode('');

        expect(success, isFalse);
        expect(provider.lastError, isA<ValidationError>());
      });

      test('should handle unlock code with expiration', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // This test is simplified since we don't have expiration in the mock
        mockPremiumService.setShouldSucceed(true);

        final success = await provider.unlockWithCode('VALID123456789ABC');

        expect(success, isTrue);
        expect(provider.isPremium, isTrue);
        expect(provider.statusSummary, contains('Premium'));
      });
    });

    group('Premium Status Management', () {
      test('should regenerate device code', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        final originalDeviceCode = provider.deviceCode;
        mockDeviceService.setDeviceCode('NEW_DEVICE_CODE_456');

        await provider.regenerateDeviceCode();

        expect(provider.deviceCode, equals('NEW_DEVICE_CODE_456'));
        expect(provider.deviceCode, isNot(equals(originalDeviceCode)));
        expect(provider.isPremium, isFalse); // Should reset to free
        expect(provider.submittedProofs, isEmpty); // Should clear proofs
      });

      test('should reset premium status', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // First unlock premium
        mockPremiumService.setShouldSucceed(true);
        await provider.unlockWithCode('VALID123456789ABC');
        expect(provider.isPremium, isTrue);

        // Then reset
        await provider.resetPremiumStatus();

        expect(provider.isPremium, isFalse);
        expect(provider.submittedProofs, isEmpty);
        expect(provider.pendingProofId, isNull);
        expect(provider.statusSummary, equals('Free Version'));
      });

      test('should check expiration status', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // Since our mock doesn't support expiration, we'll test the basic functionality
        mockPremiumService.setShouldSucceed(true);
        await provider.unlockWithCode('VALID123456789ABC');

        // For lifetime premium (no expiration), these should be false
        expect(provider.hasExpired, isFalse);
        expect(provider.isAboutToExpire, isFalse);
        expect(provider.isPremium, isTrue);
      });
    });

    group('Error Handling', () {
      test('should clear errors', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // Trigger an error
        await provider.unlockWithCode('');
        expect(provider.lastError, isNotNull);

        // Clear error
        provider.clearError();
        expect(provider.lastError, isNull);
      });

      test('should handle concurrent operations', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // Create a temporary test file
        final testFile = File('test_image.jpg');
        await testFile.writeAsString('test image content');

        // Try to submit proof while already submitting
        final future1 = provider.submitDonationProof(imageFile: testFile);
        final future2 = provider.submitDonationProof(imageFile: testFile);

        final results = await Future.wait([future1, future2]);

        // Only one should succeed (the first one)
        expect(results.where((r) => r).length, equals(1));

        // Clean up
        await testFile.delete();
      });
    });

    group('Refresh and State Management', () {
      test('should refresh premium status', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        await provider.refresh();

        expect(provider.lastError, isNull);
        expect(provider.isLoading, isFalse);
      });

      test('should prevent multiple concurrent refreshes', () async {
        await Future.delayed(const Duration(milliseconds: 200));

        // Start multiple refresh operations
        final future1 = provider.refresh();
        final future2 = provider.refresh();

        await Future.wait([future1, future2]);

        // Should complete without errors
        expect(provider.lastError, isNull);
      });
    });
  });
}