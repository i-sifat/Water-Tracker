/// Comprehensive integration test for complete swipeable hydration user flows
/// Tests the entire user journey from opening the app to tracking hydration
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

void main() {
  group('Complete Swipeable Hydration Flow Integration Tests', () {
    late HydrationProvider hydrationProvider;

    setUp(() {
      hydrationProvider = HydrationProvider();
    });

    testWidgets(
      'Complete user flow: Open app → Add hydration → View statistics → Check goals',
      (WidgetTester tester) async {
        // Build the complete app with provider
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<HydrationProvider>(
              create: (_) => hydrationProvider,
              child: const AddHydrationScreen(),
            ),
          ),
        );

        // Verify initial state - main hydration page is displayed
        expect(find.byType(SwipeablePageView), findsOneWidget);
        expect(find.byType(MainHydrationPage), findsOneWidget);
        expect(find.byType(CircularProgressSection), findsOneWidget);
        expect(find.byType(QuickAddButtonGrid), findsOneWidget);
        expect(find.byType(DrinkTypeSelector), findsOneWidget);

        // Step 1: Verify initial progress shows 0
        expect(find.text('0.0 L drank so far'), findsOneWidget);

        // Step 2: Add hydration using quick add button (500ml)
        final quickAdd500Button = find.text('500 ml');
        expect(quickAdd500Button, findsOneWidget);
        await tester.tap(quickAdd500Button);
        await tester.pumpAndSettle();

        // Verify progress updated
        expect(find.text('0.5 L drank so far'), findsOneWidget);

        // Step 3: Change drink type to tea
        final drinkTypeSelector = find.byType(DrinkTypeSelector);
        await tester.tap(drinkTypeSelector);
        await tester.pumpAndSettle();

        // Select tea from dropdown (assuming it exists)
        final teaOption = find.text('Tea').last;
        if (tester.any(teaOption)) {
          await tester.tap(teaOption);
          await tester.pumpAndSettle();
        }

        // Step 4: Add more hydration with tea (300ml)
        final quickAdd300Button = find.text('300 ml');
        await tester.tap(quickAdd300Button);
        await tester.pumpAndSettle();

        // Step 5: Swipe up to view statistics
        await tester.drag(
          find.byType(SwipeablePageView),
          const Offset(0, -300), // Swipe up
        );
        await tester.pumpAndSettle();

        // Verify statistics page is displayed
        expect(find.byType(StatisticsPage), findsOneWidget);
        expect(find.text('Statistics'), findsOneWidget);

        // Verify statistics show data
        expect(find.text('WEEKLY'), findsOneWidget);
        expect(find.text('MONTHLY'), findsOneWidget);
        expect(find.text('YEARLY'), findsOneWidget);

        // Step 6: Switch to monthly view
        final monthlyTab = find.text('MONTHLY');
        await tester.tap(monthlyTab);
        await tester.pumpAndSettle();

        // Step 7: Swipe down twice to reach goal breakdown page
        await tester.drag(
          find.byType(SwipeablePageView),
          const Offset(0, 300), // Swipe down to main page
        );
        await tester.pumpAndSettle();

        expect(find.byType(MainHydrationPage), findsOneWidget);

        await tester.drag(
          find.byType(SwipeablePageView),
          const Offset(0, 300), // Swipe down to goal breakdown
        );
        await tester.pumpAndSettle();

        // Verify goal breakdown page is displayed
        expect(find.byType(GoalBreakdownPage), findsOneWidget);

        // Step 8: Return to main page
        await tester.drag(
          find.byType(SwipeablePageView),
          const Offset(0, -300), // Swipe up to main page
        );
        await tester.pumpAndSettle();

        expect(find.byType(MainHydrationPage), findsOneWidget);

        // Step 9: Add final hydration amount (250ml water)
        // First change back to water
        await tester.tap(find.byType(DrinkTypeSelector));
        await tester.pumpAndSettle();

        final waterOption = find.text('Water').last;
        if (tester.any(waterOption)) {
          await tester.tap(waterOption);
          await tester.pumpAndSettle();
        }

        final quickAdd250Button = find.text('250 ml');
        await tester.tap(quickAdd250Button);
        await tester.pumpAndSettle();

        // Verify final state - should show updated progress
        // Total: 500ml water + 300ml tea (285ml water) + 250ml water = 1035ml water
        expect(find.text('1.04 L drank so far'), findsOneWidget);
      },
    );

    testWidgets('Error handling flow: Network issues and data persistence', (
      WidgetTester tester,
    ) async {
      // Simulate network issues by using a provider that throws errors
      final errorProvider = _ErrorHydrationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => errorProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Try to add hydration when network is down
      final quickAddButton = find.text('500 ml');
      await tester.tap(quickAddButton);
      await tester.pumpAndSettle();

      // Should show error message or handle gracefully
      // The exact behavior depends on error handling implementation
      expect(find.byType(MainHydrationPage), findsOneWidget);
    });

    testWidgets('Performance flow: Rapid interactions and animations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Rapid swipe gestures
      for (var i = 0; i < 5; i++) {
        await tester.drag(
          find.byType(SwipeablePageView),
          const Offset(0, -300),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await tester.drag(find.byType(SwipeablePageView), const Offset(0, 300));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should still be responsive
      expect(find.byType(MainHydrationPage), findsOneWidget);

      // Rapid button taps
      final quickAddButton = find.text('500 ml');
      for (var i = 0; i < 10; i++) {
        await tester.tap(quickAddButton);
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Should handle rapid taps gracefully
      expect(find.byType(MainHydrationPage), findsOneWidget);
    });

    testWidgets('Accessibility flow: Screen reader and keyboard navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test semantic labels exist
      expect(find.bySemanticsLabel('Add 500 ml of water'), findsOneWidget);
      expect(find.bySemanticsLabel('Add 250 ml of water'), findsOneWidget);
      expect(find.bySemanticsLabel('Add 400 ml of water'), findsOneWidget);
      expect(find.bySemanticsLabel('Add 100 ml of water'), findsOneWidget);

      // Test progress announcements
      expect(
        find.bySemanticsLabel(RegExp('Hydration progress.*')),
        findsOneWidget,
      );

      // Test drink type selector accessibility
      expect(find.bySemanticsLabel('Select drink type'), findsOneWidget);
    });

    testWidgets('Data persistence flow: App lifecycle and state restoration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Add some hydration data
      await tester.tap(find.text('500 ml'));
      await tester.pumpAndSettle();

      // Simulate app going to background and returning
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/lifecycle'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      // Simulate app state changes
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('AppLifecycleState.paused'),
        ),
        (data) {},
      );

      await tester.pump();

      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('AppLifecycleState.resumed'),
        ),
        (data) {},
      );

      await tester.pumpAndSettle();

      // Data should still be there
      expect(find.text('0.5 L drank so far'), findsOneWidget);
    });

    testWidgets('Edge cases flow: Boundary conditions and extreme values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test maximum hydration scenario
      // Add hydration multiple times to exceed daily goal
      final quickAddButton = find.text('500 ml');
      for (var i = 0; i < 10; i++) {
        await tester.tap(quickAddButton);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      // Should handle over-achievement gracefully
      expect(find.byType(CircularProgressSection), findsOneWidget);

      // Test swipe boundaries
      // Try to swipe beyond available pages
      for (var i = 0; i < 5; i++) {
        await tester.drag(
          find.byType(SwipeablePageView),
          const Offset(0, -500), // Large swipe up
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      // Should not crash or get stuck
      expect(find.byType(SwipeablePageView), findsOneWidget);
    });
  });
}

/// Mock provider that simulates network errors for testing error handling
class _ErrorHydrationProvider extends HydrationProvider {
  @override
  Future<void> addHydration(int amount, DrinkType type) async {
    // Simulate network error
    throw Exception('Network error: Unable to save hydration data');
  }

  @override
  Future<void> loadTodaysData() async {
    // Simulate loading error
    throw Exception('Network error: Unable to load data');
  }
}
