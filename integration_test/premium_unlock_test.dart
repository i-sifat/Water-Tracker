import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Premium Unlock Process Integration Tests', () {
    setUp(() async {
      // Set up completed onboarding to skip to main app
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
      });
    });

    testWidgets('Complete premium unlock flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('0 ml'), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should be on settings screen
      expect(find.text('Settings'), findsOneWidget);

      // Look for premium features section
      await tester.scrollUntilVisible(
        find.text('Premium Features'),
        500,
      );

      // Tap on a premium feature (Advanced Analytics)
      await tester.tap(find.text('Advanced Analytics'));
      await tester.pumpAndSettle();

      // Should show donation info screen
      expect(find.text('Unlock Premium Features'), findsOneWidget);
      expect(find.text('bKash'), findsOneWidget);

      // Test device code generation
      expect(find.text('Your Device Code:'), findsOneWidget);
      final deviceCodeFinder = find.textContaining('WTR-');
      expect(deviceCodeFinder, findsOneWidget);

      // Tap submit donation proof
      await tester.tap(find.text('Submit Donation Proof'));
      await tester.pumpAndSettle();

      // Should be on donation proof screen
      expect(find.text('Submit Donation Proof'), findsOneWidget);
      expect(find.text('Upload Screenshot'), findsOneWidget);

      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Back to donation info screen
      expect(find.text('Unlock Premium Features'), findsOneWidget);

      // Tap "I have unlock code"
      await tester.tap(find.text('I have unlock code'));
      await tester.pumpAndSettle();

      // Should be on unlock code screen
      expect(find.text('Enter Unlock Code'), findsOneWidget);
      expect(find.text('Enter the unlock code'), findsOneWidget);

      // Test invalid unlock code
      await tester.enterText(find.byType(TextField), 'INVALID123');
      await tester.tap(find.text('Unlock Premium'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid unlock code'), findsOneWidget);

      // Test valid unlock code format (mock validation)
      await tester.enterText(find.byType(TextField), 'VALID1234567890AB');
      await tester.tap(find.text('Unlock Premium'));
      await tester.pumpAndSettle();

      // Note: In real scenario, this would validate against server
      // For integration test, we can mock the validation
    });

    testWidgets('Premium feature access after unlock', (WidgetTester tester) async {
      // Set up premium status as unlocked
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'premium_unlocked': true,
        'unlock_code': 'VALID1234567890AB',
      });

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Look for premium features section
      await tester.scrollUntilVisible(
        find.text('Premium Features'),
        500,
      );

      // Premium features should be accessible now
      await tester.tap(find.text('Advanced Analytics'));
      await tester.pumpAndSettle();

      // Should go directly to analytics screen, not donation screen
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Weekly Progress'), findsOneWidget);

      // Test other premium features
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test custom reminders
      await tester.scrollUntilVisible(
        find.text('Custom Reminders'),
        500,
      );
      await tester.tap(find.text('Custom Reminders'));
      await tester.pumpAndSettle();

      // Should access custom reminders screen
      expect(find.text('Custom Reminders'), findsOneWidget);
    });

    testWidgets('Premium status persistence across app restarts', (WidgetTester tester) async {
      // Set up premium status as unlocked
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'premium_unlocked': true,
        'unlock_code': 'VALID1234567890AB',
      });

      // Start the app first time
      app.main();
      await tester.pumpAndSettle();

      // Navigate to premium feature
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Advanced Analytics'),
        500,
      );
      await tester.tap(find.text('Advanced Analytics'));
      await tester.pumpAndSettle();

      // Should access premium feature
      expect(find.text('Analytics'), findsOneWidget);

      // Simulate app restart by restarting the widget
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );

      // Restart app
      app.main();
      await tester.pumpAndSettle();

      // Premium status should persist
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Advanced Analytics'),
        500,
      );
      await tester.tap(find.text('Advanced Analytics'));
      await tester.pumpAndSettle();

      // Should still access premium feature
      expect(find.text('Analytics'), findsOneWidget);
    });
  });
}
