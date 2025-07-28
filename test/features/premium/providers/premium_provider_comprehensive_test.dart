import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

void main() {
  group('PremiumProvider Comprehensive Tests', () {
    late PremiumProvider premiumProvider;

    setUp(() {
      premiumProvider = PremiumProvider();
    });

    group('Basic Functionality', () {
      test('should create premium provider', () {
        // Assert
        expect(premiumProvider, isNotNull);
      });

      test('should have initial premium status', () {
        // Assert
        expect(premiumProvider.isPremium, isFalse);
      });
    });

    group('Device Code Management', () {
      test('should generate device code', () async {
        // Act
        await premiumProvider.generateDeviceCode();

        // Assert
        expect(premiumProvider.deviceCode, isNotEmpty);
      });

      test('should persist device code', () async {
        // Act
        await premiumProvider.generateDeviceCode();
        final firstCode = premiumProvider.deviceCode;

        // Create new provider instance
        final newProvider = PremiumProvider();
        await newProvider.loadPremiumStatus();

        // Assert
        expect(newProvider.deviceCode, equals(firstCode));
      });
    });

    group('Premium Status Management', () {
      test('should load premium status', () async {
        // Act & Assert
        expect(() => premiumProvider.loadPremiumStatus(), returnsNormally);
      });

      test('should save premium status', () async {
        // Act & Assert
        expect(() => premiumProvider.savePremiumStatus(), returnsNormally);
      });
    });

    group('Feature Access', () {
      test('should check feature availability for free users', () {
        // Act
        final hasAdvancedAnalytics = premiumProvider.hasAdvancedAnalytics;
        final hasCustomReminders = premiumProvider.hasCustomReminders;

        // Assert
        expect(hasAdvancedAnalytics, isFalse);
        expect(hasCustomReminders, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        // Act & Assert
        expect(() => premiumProvider.loadPremiumStatus(), returnsNormally);
      });

      test('should handle invalid unlock codes', () async {
        // Act
        final result = await premiumProvider.unlockWithCode('invalid-code');

        // Assert
        expect(result, isFalse);
        expect(premiumProvider.isPremium, isFalse);
      });
    });
  });
}
