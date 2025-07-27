import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flow Integration Tests', () {
    testWidgets('Complete onboarding to tracking flow', (WidgetTester tester) async {
      // Clear any existing onboarding data
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start with welcome screen since onboarding is not completed
      expect(find.text('Welcome'), findsOneWidget);
      
      // Tap continue to start onboarding
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Goal selection screen
      expect(find.text('Select Your Goal'), findsOneWidget);
      await tester.tap(find.text('Lose Weight').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Gender selection screen
      expect(find.text('Select Your Gender'), findsOneWidget);
      await tester.tap(find.text('Male').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Skip through remaining onboarding screens quickly
      // Sugary beverages screen
      await tester.tap(find.text('Rarely'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Age selection screen
      expect(find.text('How old are you?'), findsOneWidget);
      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Weight selection screen
      expect(find.text('What is your weight?'), findsOneWidget);
      await tester.tap(find.text('70'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Pregnancy screen (should skip for male)
      // Exercise frequency screen
      await tester.tap(find.text('Moderate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Vegetables/fruits screen
      await tester.tap(find.text('Sometimes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Weather preference screen
      await tester.tap(find.text('Moderate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Notification setup screen
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Data summary screen
      expect(find.text('Your Daily Goal'), findsOneWidget);
      await tester.tap(find.text('Start Tracking'));
      await tester.pumpAndSettle();

      // Should now be on home screen
      expect(find.text('0 ml'), findsOneWidget);
      expect(find.text('Remaining:'), findsOneWidget);

      // Test adding water intake
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should be on add hydration screen
      expect(find.text('Add Water'), findsOneWidget);
      
      // Add 250ml of water
      await tester.tap(find.text('250ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should return to home screen with updated intake
      expect(find.text('250 ml'), findsOneWidget);

      // Test navigation to history screen
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Should be on history screen
      expect(find.text('History'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Test settings navigation
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should be on settings screen
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}