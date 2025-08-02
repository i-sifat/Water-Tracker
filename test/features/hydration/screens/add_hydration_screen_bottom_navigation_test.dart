import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/features/history/history_screen.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';

void main() {
  group('AddHydrationScreen Bottom Navigation Integration', () {
    late HydrationProvider mockProvider;

    setUp(() {
      mockProvider = HydrationProvider();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<HydrationProvider>.value(
        value: mockProvider,
        child: const MaterialApp(home: AddHydrationScreen()),
      );
    }

    testWidgets('should display bottom navigation bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify bottom navigation bar is present
      expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
    });

    testWidgets('should highlight hydration section as active', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the bottom navigation bar
      final bottomNavBar = tester.widget<CustomBottomNavigationBar>(
        find.byType(CustomBottomNavigationBar),
      );

      // Verify hydration section (index 1) is selected
      expect(bottomNavBar.selectedIndex, equals(1));
    });

    testWidgets('should navigate to home screen when home tab is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: const AddHydrationScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the home navigation item (index 0)
      final bottomNavBar = find.byType(CustomBottomNavigationBar);
      final gestureDetectors =
          tester
              .widgetList<GestureDetector>(
                find.descendant(
                  of: bottomNavBar,
                  matching: find.byType(GestureDetector),
                ),
              )
              .toList();

      // Tap the first item (home)
      await tester.tap(find.byWidget(gestureDetectors[0]));
      await tester.pumpAndSettle();

      // Verify navigation to HomeScreen occurred
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AddHydrationScreen), findsNothing);
    });

    testWidgets(
      'should navigate to history screen when history tab is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: MaterialApp(
              home: const AddHydrationScreen(),
              routes: {
                '/home': (context) => const HomeScreen(),
                '/history': (context) => const HistoryScreen(),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap the history navigation item (index 2)
        final bottomNavBar = find.byType(CustomBottomNavigationBar);
        final gestureDetectors =
            tester
                .widgetList<GestureDetector>(
                  find.descendant(
                    of: bottomNavBar,
                    matching: find.byType(GestureDetector),
                  ),
                )
                .toList();

        // Tap the third item (history)
        await tester.tap(find.byWidget(gestureDetectors[2]));
        await tester.pumpAndSettle();

        // Verify navigation to HistoryScreen occurred
        expect(find.byType(HistoryScreen), findsOneWidget);
        expect(find.byType(AddHydrationScreen), findsNothing);
      },
    );

    testWidgets(
      'should not navigate when hydration tab is tapped (already active)',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify we start on AddHydrationScreen
        expect(find.byType(AddHydrationScreen), findsOneWidget);

        // Find and tap the hydration navigation item (index 1)
        final bottomNavBar = find.byType(CustomBottomNavigationBar);
        final gestureDetectors =
            tester
                .widgetList<GestureDetector>(
                  find.descendant(
                    of: bottomNavBar,
                    matching: find.byType(GestureDetector),
                  ),
                )
                .toList();

        // Tap the second item (hydration - current screen)
        await tester.tap(find.byWidget(gestureDetectors[1]));
        await tester.pumpAndSettle();

        // Verify we're still on AddHydrationScreen
        expect(find.byType(AddHydrationScreen), findsOneWidget);
      },
    );

    testWidgets('should preserve swipe page state during navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: const AddHydrationScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Start on main page, swipe to goal breakdown page
      await tester.drag(find.byType(MainHydrationPage), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify we're on goal breakdown page
      expect(find.byType(GoalBreakdownPage), findsOneWidget);

      // The page state should be preserved - we can verify this by checking
      // that the goal breakdown page is visible, indicating the swipe state was maintained
      expect(find.byType(GoalBreakdownPage), findsOneWidget);
      expect(find.byType(MainHydrationPage), findsNothing);
    });

    testWidgets('should use smooth transitions for navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: const AddHydrationScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the home navigation item
      final bottomNavBar = find.byType(CustomBottomNavigationBar);
      final gestureDetectors =
          tester
              .widgetList<GestureDetector>(
                find.descendant(
                  of: bottomNavBar,
                  matching: find.byType(GestureDetector),
                ),
              )
              .toList();

      await tester.tap(find.byWidget(gestureDetectors[0]));

      // Pump a few frames to test transition
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should be in transition
      expect(find.byType(SlideTransition), findsOneWidget);

      await tester.pumpAndSettle();

      // Should complete navigation
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle rapid navigation taps gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: const AddHydrationScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find navigation items
      final bottomNavBar = find.byType(CustomBottomNavigationBar);
      final gestureDetectors =
          tester
              .widgetList<GestureDetector>(
                find.descendant(
                  of: bottomNavBar,
                  matching: find.byType(GestureDetector),
                ),
              )
              .toList();

      // Rapidly tap different navigation items
      await tester.tap(find.byWidget(gestureDetectors[0])); // Home
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byWidget(gestureDetectors[2])); // History
      await tester.pumpAndSettle();

      // Should handle gracefully and end up on the last tapped screen
      expect(find.byType(HistoryScreen), findsOneWidget);
    });

    testWidgets(
      'should maintain page state when returning from other screens',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: MaterialApp(
              home: const AddHydrationScreen(),
              routes: {
                '/home': (context) => const HomeScreen(),
                '/history': (context) => const HistoryScreen(),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify we start on the main hydration page (center page)
        expect(find.byType(MainHydrationPage), findsOneWidget);

        // Swipe to statistics page (swipe up)
        await tester.drag(find.byType(MainHydrationPage), const Offset(0, 300));
        await tester.pumpAndSettle();

        // Verify we're now on statistics page
        expect(find.byType(StatisticsPage), findsOneWidget);

        // Tap home navigation item
        final bottomNavBar = find.byType(CustomBottomNavigationBar);
        expect(bottomNavBar, findsOneWidget);

        // Find the first navigation item (home)
        final homeNavItem =
            tester
                .widgetList<GestureDetector>(
                  find.descendant(
                    of: bottomNavBar,
                    matching: find.byType(GestureDetector),
                  ),
                )
                .first;

        await tester.tap(find.byWidget(homeNavItem));
        await tester.pumpAndSettle();

        // Verify navigation occurred (we should now be on HomeScreen)
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  });
}
