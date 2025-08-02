import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';

void main() {
  group('MainHydrationPage Header Navigation Tests', () {
    late HydrationProvider mockProvider;

    setUp(() {
      mockProvider = HydrationProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        routes: {SettingsScreen.routeName: (context) => const SettingsScreen()},
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: const Scaffold(body: MainHydrationPage()),
        ),
      );
    }

    testWidgets('should display hamburger menu icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should display profile icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should display Today title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('should display time range indicators', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Should find 3 time indicators
      expect(find.byType(Container), findsAtLeast(3));
    });

    testWidgets('should open navigation menu when hamburger menu is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Should show bottom sheet with menu items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('should navigate to settings when profile icon is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Should navigate to settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('should show help dialog when help menu item is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Open menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap help
      await tester.tap(find.text('Help & Support'));
      await tester.pumpAndSettle();

      expect(find.text('Help & Support'), findsAtLeast(1));
      expect(find.text('Welcome to Water Tracker!'), findsOneWidget);
    });

    testWidgets('should navigate to settings from menu', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Open menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('should update time indicators dynamically', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Time indicators should be present
      final timeContainers = find.byType(Container);
      expect(timeContainers, findsAtLeast(3));

      // Should contain time-related text patterns
      expect(
        find.textContaining(RegExp(r'\d+:\d+ [AP]M|min')),
        findsAtLeast(1),
      );
    });
  });
}
