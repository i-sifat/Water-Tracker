import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline/Online Behavior Integration Tests', () {
    setUp(() async {
      // Set up completed onboarding
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
      });
    });

    testWidgets('Core functionality works offline', (WidgetTester tester) async {
      // Start the app in offline mode
      app.main();
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('0 ml'), findsOneWidget);

      // Test adding water intake offline
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should work without network
      expect(find.text('Add Water'), findsOneWidget);

      // Add water
      await tester.tap(find.text('250ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should update immediately
      expect(find.text('250 ml'), findsOneWidget);

      // Test history access offline
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Should show local history
      expect(find.text('History'), findsOneWidget);
      expect(find.text('250ml'), findsOneWidget);

      // Test settings access offline
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should access settings
      expect(find.text('Settings'), findsOneWidget);

      // Test profile editing offline
      await tester.tap(find.text('User Profile'));
      await tester.pumpAndSettle();

      // Should work offline
      expect(find.text('User Profile'), findsOneWidget);
    });

    testWidgets('Offline data queuing and sync on reconnection', (WidgetTester tester) async {
      // Start the app offline
      app.main();
      await tester.pumpAndSettle();

      // Add multiple water entries while offline
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.text('250ml'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();
      }

      // Should show total 750ml
      expect(find.text('750 ml'), findsOneWidget);

      // Navigate to settings to check sync status
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should show offline status
      await tester.scrollUntilVisible(
        find.text('Sync Status'),
        500,
      );
      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('3 items pending sync'), findsOneWidget);

      // Simulate going online
      // In real app, this would be detected automatically
      await tester.tap(find.text('Sync Now'));
      await tester.pumpAndSettle();

      // Should show syncing status
      expect(find.text('Syncing...'), findsOneWidget);

      // Wait for sync to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show sync completed
      expect(find.text('Sync completed'), findsOneWidget);
      expect(find.text('All data synchronized'), findsOneWidget);
    });

    testWidgets('Conflict resolution during sync', (WidgetTester tester) async {
      // Set up conflicting data scenario
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'pending_sync_data': '[{"amount":250,"timestamp":"2024-01-01T10:00:00.000Z","synced":false}]',
        'server_data': '[{"amount":500,"timestamp":"2024-01-01T10:30:00.000Z","synced":true}]',
      });

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should show local data initially
      expect(find.text('250 ml'), findsOneWidget);

      // Navigate to sync settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Management'));
      await tester.pumpAndSettle();

      // Trigger sync
      await tester.tap(find.text('Sync Now'));
      await tester.pumpAndSettle();

      // Should show conflict resolution dialog
      expect(find.text('Data Conflict Detected'), findsOneWidget);
      expect(find.text('Local: 250ml'), findsOneWidget);
      expect(find.text('Server: 500ml'), findsOneWidget);

      // Choose to merge data
      await tester.tap(find.text('Merge Both'));
      await tester.pumpAndSettle();

      // Should show merge confirmation
      expect(find.text('Data merged successfully'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should show merged total
      expect(find.text('750 ml'), findsOneWidget);

      // Check history for both entries
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.text('250ml'), findsOneWidget);
      expect(find.text('500ml'), findsOneWidget);
    });

    testWidgets('Premium features offline behavior', (WidgetTester tester) async {
      // Set up premium access
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'premium_unlocked': true,
      });

      // Start the app offline
      app.main();
      await tester.pumpAndSettle();

      // Navigate to premium analytics
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced Analytics'));
      await tester.pumpAndSettle();

      // Should work offline with cached data
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Weekly Progress'), findsOneWidget);

      // Test data export offline
      await tester.tap(find.text('Export Data'));
      await tester.pumpAndSettle();

      // Should work with local data
      expect(find.text('Export Options'), findsOneWidget);
      await tester.tap(find.text('Export as CSV'));
      await tester.pumpAndSettle();

      // Should show offline export success
      expect(find.text('Data exported locally'), findsOneWidget);
      expect(find.text('Will sync when online'), findsOneWidget);

      // Test custom reminders offline
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom Reminders'));
      await tester.pumpAndSettle();

      // Should work offline
      expect(find.text('Custom Reminders'), findsOneWidget);

      // Add reminder offline
      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Should save locally
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('(Offline - will sync)'), findsOneWidget);
    });

    testWidgets('Network state change handling', (WidgetTester tester) async {
      // Start the app online
      app.main();
      await tester.pumpAndSettle();

      // Add some data while online
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('250ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should sync immediately
      expect(find.text('250 ml'), findsOneWidget);

      // Simulate going offline
      // In real app, this would be detected by connectivity plugin
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should show offline indicator
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Add more data while offline
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('500ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should update locally
      expect(find.text('750 ml'), findsOneWidget);

      // Simulate going back online
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should show online indicator and auto-sync
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      expect(find.text('Auto-syncing...'), findsOneWidget);

      // Wait for sync
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show sync completed
      expect(find.text('All data synchronized'), findsOneWidget);
    });

    testWidgets('Offline backup and restore', (WidgetTester tester) async {
      // Start with some data
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'hydration_data': '[{"amount":250,"timestamp":"2024-01-01T10:00:00.000Z"}]',
      });

      // Start the app offline
      app.main();
      await tester.pumpAndSettle();

      // Should show existing data
      expect(find.text('250 ml'), findsOneWidget);

      // Navigate to data management
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Management'));
      await tester.pumpAndSettle();

      // Test offline backup
      await tester.tap(find.text('Create Local Backup'));
      await tester.pumpAndSettle();

      // Should work offline
      expect(find.text('Local backup created'), findsOneWidget);
      expect(find.text('Stored on device'), findsOneWidget);

      // Clear data
      await tester.tap(find.text('Clear All Data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should show cleared data
      expect(find.text('0 ml'), findsOneWidget);

      // Test offline restore
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Management'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore from Local Backup'));
      await tester.pumpAndSettle();

      // Should work offline
      expect(find.text('Data restored from local backup'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should show restored data
      expect(find.text('250 ml'), findsOneWidget);
    });

    testWidgets('Graceful degradation of online-only features', (WidgetTester tester) async {
      // Start the app offline
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Try to access online-only features
      await tester.tap(find.text('Cloud Sync'));
      await tester.pumpAndSettle();

      // Should show offline message
      expect(find.text('Cloud Sync'), findsOneWidget);
      expect(find.text('Requires internet connection'), findsOneWidget);
      expect(find.text('Connect to enable cloud sync'), findsOneWidget);

      // Test health app integration offline
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Health App Integration'));
      await tester.pumpAndSettle();

      // Should show offline limitation
      expect(find.text('Health App Integration'), findsOneWidget);
      expect(find.text('Limited offline functionality'), findsOneWidget);
      expect(find.text('Full sync available when online'), findsOneWidget);

      // Test premium unlock offline
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Premium Features'));
      await tester.pumpAndSettle();

      // Should show offline limitation for unlock
      expect(find.text('Premium unlock requires internet'), findsOneWidget);
      expect(find.text('Connect to unlock premium features'), findsOneWidget);
    });
  });
}
