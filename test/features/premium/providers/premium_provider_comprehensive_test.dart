import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/models/premium_models.dart';
import 'package:watertracker/core/services/device_service.dart';
import 'package:watertracker/core/services/premium_service.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

import 'premium_provider_comprehensive_test.mocks.dart';

@GenerateMocks([PremiumService, DeviceService, StorageService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PremiumProvider Comprehensive Tests', () {
    late PremiumProvider premiumProvider;
    late MockPremiumService mockPremiumService;
    late MockDeviceService mockDeviceService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockPremiumService = MockPremiumService();
      mockDeviceService = MockDeviceService();
      mockStorageService = MockStorageService();

      // Setup default mock responses
      when(mockStorageService.getString(any, encrypted: anyNamed('encrypted')))
          .thenAnswer((_) async => null);
      when(mockStorageService.saveString(any, any, encrypted: anyNamed('encrypted')))
          .thenAnswer((_) async {});
      when(mockDeviceService.generateUniqueCode())
          .thenAnswer((_) async => 'test-device-code');
      when(mockPremiumService.isPremiumUnlocked())
          .thenAnswer((_) async => false);

      premiumProvider = PremiumProvider(
        premiumService: mockPremiumService,
        deviceService: mockDeviceService,
        storageService: mockStorageService,
      );
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Wait for initialization to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(premiumProvider.isInitialized, isTrue);
        expect(premiumProvider.deviceCode, equals('test-device-code'));
      });

      test('should generate device code if not exists', () async {
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        verify(mockDeviceService.generateUniqueCode()).called(1);
        verify(mockStorageService.saveString('device_code', 'test-device-code', encrypted: false)).called(1);
      });

      test('should load existing device code', () async {
        // Arrange
        when(mockStorageService.getString('device_code', encrypted: false))
            .thenAnswer((_) async => 'existing-code');

        // Create new provider to test loading
        final provider = PremiumProvider(
          premiumService: mockPremiumService,
          deviceService: mockDeviceService,
          storageService: mockStorageService,
        );

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(provider.deviceCode, equals('existing-code'));
        verifyNever(mockDeviceService.generateUniqueCode());
      });
    });

    group('Premium Status', () {
      test('should start with free status', () async {
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(premiumProvider.isPremium, isFalse);
        expect(premiumProvider.premiumStatus.isActive, isFalse);
      });

      test('should detect premium status from service', () async {
        // Arrange
        when(mockPremiumService.isPremiumUnlocked()).thenAnswer((_) async => true);
        when(mockPremiumService.getUnlockedFeatures()).thenAnswer((_) async => [
          PremiumFeature.advancedAnalytics,
          PremiumFeature.customReminders,
        ]);

        // Create new provider to test premium detection
        final provider = PremiumProvider(
          premiumService: mockPremiumService,
          deviceService: mockDeviceService,
          storageService: mockStorageService,
        );

        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(provider.isPremium, isTrue);
      });
    });

    group('Donation Proof Submission', () {
      test('should submit donation proof successfully', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 100));
        when(mockPremiumService.submitDonationProof(any, any, any))
            .thenAnswer((_) async => 'proof-id-123');

        // Act
        await premiumProvider.submitDonationProof(
          'charity-name',
          100.0,
          'receipt-image-data',
        );

        // Assert
        expect(premiumProvider.isSubmittingProof, isFalse);
        verify(mockPremiumService.submitDonationProof(
          'charity-name',
          100.0,
          'receipt-image-data',
        )).called(1);
      });

      test('should handle donation proof submission errors', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 100));
        when(mockPremiumService.submitDonationProof(any, any, any))
            .thenThrow(Exception('Submission failed'));

        // Act
        await premiumProvider.submitDonationProof(
          'charity-name',
          100.0,
          'receipt-image-data',
        );

        // Assert
        expect(premiumProvider.isSubmittingProof, isFalse);
        expect(premiumProvider.lastError, isNotNull);
      });
    });

    group('Unlock Code Validation', () {
      test('should validate unlock code successfully', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 100));
        when(mockPremiumService.validateUnlockCode(any))
            .thenAnswer((_) async => true);

        // Act
        final result = await premiumProvider.validateUnlockCode('valid-code');

        // Assert
        expect(result, isTrue);
        expect(premiumProvider.isValidatingCode, isFalse);
        verify(mockPremiumService.validateUnlockCode('valid-code')).called(1);
      });

      test('should handle invalid unlock codes', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 100));
        when(mockPremiumService.validateUnlockCode(any))
            .thenAnswer((_) async => false);

        // Act
        final result = await premiumProvider.validateUnlockCode('invalid-code');

        // Assert
        expect(result, isFalse);
        expect(premiumProvider.isValidatingCode, isFalse);
      });
    });

    group('Feature Access', () {
      test('should check feature access for free users', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        final hasAdvancedAnalytics = premiumProvider.hasFeature(PremiumFeature.advancedAnalytics);
        final hasCustomReminders = premiumProvider.hasFeature(PremiumFeature.customReminders);

        // Assert
        expect(hasAdvancedAnalytics, isFalse);
        expect(hasCustomReminders, isFalse);
      });

      test('should check feature access for premium users', () async {
        // Arrange
        when(mockPremiumService.isPremiumUnlocked()).thenAnswer((_) async => true);
        when(mockPremiumService.getUnlockedFeatures()).thenAnswer((_) async => [
          PremiumFeature.advancedAnalytics,
          PremiumFeature.customReminders,
        ]);

        final provider = PremiumProvider(
          premiumService: mockPremiumService,
          deviceService: mockDeviceService,
          storageService: mockStorageService,
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // Act
        final hasAdvancedAnalytics = provider.hasFeature(PremiumFeature.advancedAnalytics);
        final hasCustomReminders = provider.hasFeature(PremiumFeature.customReminders);
        final hasDataExport = provider.hasFeature(PremiumFeature.dataExport);

        // Assert
        expect(hasAdvancedAnalytics, isTrue);
        expect(hasCustomReminders, isTrue);
        expect(hasDataExport, isFalse);
      });
    });

    group('Premium Flow Navigation', () {
      test('should show premium flow', () {
        // Arrange
        final mockContext = MockBuildContext();

        // Act & Assert - Should not throw
        expect(() => premiumProvider.showPremiumFlow(mockContext), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle initialization errors gracefully', () async {
        // Arrange
        when(mockStorageService.getString(any, encrypted: anyNamed('encrypted')))
            .thenThrow(Exception('Storage error'));

        // Act
        final provider = PremiumProvider(
          premiumService: mockPremiumService,
          deviceService: mockDeviceService,
          storageService: mockStorageService,
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(provider.lastError, isNotNull);
        expect(provider.isInitialized, isFalse);
      });

      test('should handle service errors gracefully', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 100));
        when(mockPremiumService.isPremiumUnlocked())
            .thenThrow(Exception('Service error'));

        // Act
        await premiumProvider.refreshPremiumStatus();

        // Assert
        expect(premiumProvider.lastError, isNotNull);
      });
    });

    group('State Management', () {
      test('should notify listeners on state changes', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 100));
        var notificationCount = 0;
        premiumProvider.addListener(() => notificationCount++);

        // Act
        await premiumProvider.refreshPremiumStatus();

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test('should manage loading states correctly', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 100));
        expect(premiumProvider.isLoading, isFalse);

        // Act
        final future = premiumProvider.refreshPremiumStatus();
        expect(premiumProvider.isLoading, isTrue);
        
        await future;

        // Assert
        expect(premiumProvider.isLoading, isFalse);
      });
    });
  });
}

// Mock BuildContext for testing
class MockBuildContext extends Mock implements BuildContext {}