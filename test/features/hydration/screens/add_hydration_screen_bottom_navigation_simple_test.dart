import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';

void main() {
  group('AddHydrationScreen Bottom Navigation Integration - Simple Tests', () {
    testWidgets(
      'should display bottom navigation bar with hydration section active',
      (WidgetTester tester) async {
        // Create a mock provider that doesn't require initialization
        final mockProvider = HydrationProvider();

        await tester.pumpWidget(
          ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: const MaterialApp(home: AddHydrationScreen()),
          ),
        );

        // Wait for initial build
        await tester.pump();

        // Verify bottom navigation bar is present
        expect(find.byType(CustomBottomNavigationBar), findsOneWidget);

        // Find the bottom navigation bar widget
        final bottomNavBar = tester.widget<CustomBottomNavigationBar>(
          find.byType(CustomBottomNavigationBar),
        );

        // Verify hydration section (index 1) is selected
        expect(bottomNavBar.selectedIndex, equals(1));
      },
    );

    testWidgets('should have proper navigation callback structure', (
      WidgetTester tester,
    ) async {
      final mockProvider = HydrationProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: const MaterialApp(home: AddHydrationScreen()),
        ),
      );

      await tester.pump();

      // Verify bottom navigation bar is present
      expect(find.byType(CustomBottomNavigationBar), findsOneWidget);

      // Find the bottom navigation bar widget
      final bottomNavBar = tester.widget<CustomBottomNavigationBar>(
        find.byType(CustomBottomNavigationBar),
      );

      // Verify it has an onItemTapped callback
      expect(bottomNavBar.onItemTapped, isNotNull);
    });

    testWidgets('should maintain scaffold structure with bottom navigation', (
      WidgetTester tester,
    ) async {
      final mockProvider = HydrationProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: const MaterialApp(home: AddHydrationScreen()),
        ),
      );

      await tester.pump();

      // Verify scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CustomBottomNavigationBar), findsOneWidget);

      // Verify the bottom navigation bar is positioned at the bottom
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isA<CustomBottomNavigationBar>());
    });

    testWidgets('should handle navigation item taps without crashing', (
      WidgetTester tester,
    ) async {
      final mockProvider = HydrationProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: const MaterialApp(home: AddHydrationScreen()),
        ),
      );

      await tester.pump();

      // Find navigation items
      final bottomNavBar = find.byType(CustomBottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);

      // Find gesture detectors (navigation items)
      final gestureDetectors = find.descendant(
        of: bottomNavBar,
        matching: find.byType(GestureDetector),
      );

      // Verify we have navigation items
      expect(gestureDetectors, findsWidgets);

      // Test tapping the hydration tab (should not crash)
      if (tester.widgetList(gestureDetectors).length >= 2) {
        await tester.tap(gestureDetectors.at(1)); // Hydration tab (index 1)
        await tester.pump();

        // Should still be on the same screen
        expect(find.byType(AddHydrationScreen), findsOneWidget);
      }
    });
  });
}
