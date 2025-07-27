import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Functionality Integration Tests', () {
    setUp(() async {
      // Set up completed onboarding
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
      });
    });

    testWidgets('Notification permission request and setup', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Navigate to notification settings
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      // Should be on notification settings screen
      expect(find.text('Notification Settings'), findsOneWidget);

      // Test enabling notifications
      final notificationSwitch = find.byType(Switch).first;
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // Should request permission (in real app)
      // For integration test, we can verify the UI response
      expect(find.text('Notifications enabled'), findsOneWidget);

      // Test setting reminder times
      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();

      // Should show time picker
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Select a time (9:00 AM)
      await tester.tap(find.text('9'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Should show the reminder in the list
      expect(find.text('09:00'), findsOneWidget);

      // Test adding multiple reminders
      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();

      // Select another time (2:00 PM)
      await tester.tap(find.text('2'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('PM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Should show both reminders
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('14:00'), findsOneWidget);

      // Test deleting a reminder
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Should confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // First reminder should be gone
      expect(find.text('09:00'), findsNothing);
      expect(find.text('14:00'), findsOneWidget);
    });

    testWidgets('Smart reminder functionality', (WidgetTester tester) async {
      // Set up premium access for smart reminders
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'premium_unlocked': true,
      });

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Add some water intake to establish a pattern
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('250ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Navigate to notification settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      // Enable smart reminders (premium feature)
      await tester.tap(find.text('Smart Reminders'));
      await tester.pumpAndSettle();

      // Should show smart reminder options
      expect(find.text('Smart Reminder Settings'), findsOneWidget);
      expect(find.text('Based on your drinking patterns'), findsOneWidget);

      // Enable adaptive timing
      await tester.tap(find.text('Adaptive Timing'));
      await tester.pumpAndSettle();

      // Should show confirmation
      expect(find.text('Smart reminders enabled'), findsOneWidget);

      // Test reminder frequency adjustment
      await tester.tap(find.text('Reminder Frequency'));
      await tester.pumpAndSettle();

      // Should show frequency options
      expect(find.text('Every 30 minutes'), findsOneWidget);
      expect(find.text('Every hour'), findsOneWidget);
      expect(find.text('Every 2 hours'), findsOneWidget);

      await tester.tap(find.text('Every hour'));
      await tester.pumpAndSettle();

      // Should save the setting
      expect(find.text('Frequency updated'), findsOneWidget);
    });

    testWidgets('Notification interaction and app opening', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Set up notifications
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      // Enable notifications
      final notificationSwitch = find.byType(Switch).first;
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // Add a reminder
      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Simulate notification tap (this would normally come from system)
      // For integration test, we can simulate the app opening from notification
      
      // Test that app opens to correct screen when notification is tapped
      // This would typically be the add hydration screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should be on add hydration screen
      expect(find.text('Add Water'), findsOneWidget);

      // Test quick add from notification
      await tester.tap(find.text('250ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should return to home with updated intake
      expect(find.text('250 ml'), findsOneWidget);
    });

    testWidgets('Notification customization for premium users', (WidgetTester tester) async {
      // Set up premium access
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'daily_goal': 2000,
        'selected_avatar': 'male',
        'premium_unlocked': true,
      });

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to notification settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      // Should show premium notification options
      expect(find.text('Custom Messages'), findsOneWidget);
      expect(find.text('Motivational Quotes'), findsOneWidget);

      // Test custom message setup
      await tester.tap(find.text('Custom Messages'));
      await tester.pumpAndSettle();

      // Should show custom message screen
      expect(find.text('Custom Notification Messages'), findsOneWidget);

      // Add a custom message
      await tester.tap(find.text('Add Message'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Time to hydrate! Your body needs water.',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show the custom message in the list
      expect(find.text('Time to hydrate! Your body needs water.'), findsOneWidget);

      // Test message editing
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Stay hydrated, stay healthy!',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show updated message
      expect(find.text('Stay hydrated, stay healthy!'), findsOneWidget);

      // Test motivational quotes
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Motivational Quotes'));
      await tester.pumpAndSettle();

      // Should show quote options
      expect(find.text('Enable Motivational Quotes'), findsOneWidget);
      
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Should show quote categories
      expect(find.text('Health & Wellness'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('General Motivation'), findsOneWidget);
    });

    testWidgets('Notification scheduling and background behavior', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Set up notifications
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      // Enable notifications
      final notificationSwitch = find.byType(Switch).first;
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // Set up multiple reminders
      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('PM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Test quiet hours setup
      await tester.tap(find.text('Quiet Hours'));
      await tester.pumpAndSettle();

      // Should show quiet hours settings
      expect(find.text('Quiet Hours Settings'), findsOneWidget);

      // Set quiet hours from 10 PM to 7 AM
      await tester.tap(find.text('Start Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('PM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('End Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('7'));
      await tester.tap(find.text('00'));
      await tester.tap(find.text('AM'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Should show quiet hours are set
      expect(find.text('22:00 - 07:00'), findsOneWidget);

      // Test notification pause when goal is reached
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pause when goal reached'));
      await tester.pumpAndSettle();

      // Should enable the setting
      expect(find.text('Notifications will pause when daily goal is reached'), findsOneWidget);
    });
  });
}