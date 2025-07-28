import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Data Persistence and Synchronization Tests', () {
    setUp(() async {
      // Set up completed onboarding
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
      });
    });

    testWidgets('Water intake data persistence across app sessions', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should be on home screen with 0 ml
      expect(find.text('0 ml'), findsOneWidget);

      // Add water intake
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Add 250ml
      await tester.tap(find.text('250ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify intake is updated
      expect(find.text('250 ml'), findsOneWidget);

      // Add more water
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('500ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should show total 750ml
      expect(find.text('750 ml'), findsOneWidget);

      // Simulate app restart
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );

      // Restart app
      app.main();
      await tester.pumpAndSettle();

      // Data should persist
      expect(find.text('750 ml'), findsOneWidget);

      // Check history screen for persistence
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Should show history entries
      expect(find.text('History'), findsOneWidget);
      expect(find.text('250ml'), findsWidgets);
      expect(find.text('500ml'), findsWidgets);
    });

    testWidgets('User profile data persistence', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Navigate to user profile
      await tester.tap(find.text('User Profile'));
      await tester.pumpAndSettle();

      // Should show current profile data
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('2000 ml'), findsOneWidget);

      // Modify profile data
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Change daily goal
      await tester.enterText(find.byType(TextField).first, '2500');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify change is reflected
      expect(find.text('2500 ml'), findsOneWidget);

      // Restart app to test persistence
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );

      app.main();
      await tester.pumpAndSettle();

      // Navigate back to profile
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('User Profile'));
      await tester.pumpAndSettle();

      // Profile changes should persist
      expect(find.text('2500 ml'), findsOneWidget);
    });

    testWidgets('Theme and settings persistence', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Change theme to dark mode
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      // Verify dark theme is applied
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, isNot(Colors.white));

      // Change language
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spanish'));
      await tester.pumpAndSettle();

      // Restart app
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );

      app.main();
      await tester.pumpAndSettle();

      // Settings should persist
      final newScaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(newScaffold.backgroundColor, isNot(Colors.white));
    });

    testWidgets('Data backup and restore functionality', (WidgetTester tester) async {
      // Set up some data first
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'hydration_data': '[{"amount":250,"timestamp":"2024-01-01T10:00:00.000Z"}]',
      });

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should show existing data
      expect(find.text('250 ml'), findsOneWidget);

      // Navigate to data management
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Management'));
      await tester.pumpAndSettle();

      // Test backup functionality
      await tester.tap(find.text('Backup Data'));
      await tester.pumpAndSettle();

      // Should show backup success message
      expect(find.text('Backup created successfully'), findsOneWidget);

      // Test data clear
      await tester.tap(find.text('Clear All Data'));
      await tester.pumpAndSettle();

      // Confirm clear
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Data should be cleared
      expect(find.text('0 ml'), findsOneWidget);

      // Test restore functionality
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Management'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore Data'));
      await tester.pumpAndSettle();

      // Should show restore success
      expect(find.text('Data restored successfully'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Data should be restored
      expect(find.text('250 ml'), findsOneWidget);
    });

    testWidgets('Offline data synchronization', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add water intake while "offline"
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('250ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Data should be stored locally
      expect(find.text('250 ml'), findsOneWidget);

      // Simulate going online and sync
      // This would typically involve network calls
      // For integration test, we can simulate the sync process

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Look for sync status
      await tester.scrollUntilVisible(
        find.text('Sync Status'),
        500,
      );

      // Should show sync pending or completed
      expect(find.textContaining('Sync'), findsOneWidget);

      // Test manual sync trigger
      await tester.tap(find.text('Sync Now'));
      await tester.pumpAndSettle();

      // Should show sync in progress or completed
      expect(find.text('Syncing...'), findsOneWidget);
    });

    testWidgets('Data migration on app update', (WidgetTester tester) async {
      // Set up old data format
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'old_data_format': 'legacy_data',
        'app_version': '0.1.0',
      });

      // Start the app (simulating update to new version)
      app.main();
      await tester.pumpAndSettle();

      // App should handle migration gracefully
      expect(find.text('0 ml'), findsOneWidget);

      // Check that migration completed
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_version'), isNot('0.1.0'));
      expect(prefs.containsKey('old_data_format'), isFalse);
    });
  });
}
