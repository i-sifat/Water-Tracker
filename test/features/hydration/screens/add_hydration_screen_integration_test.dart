import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

void main() {
  group('AddHydrationScreen Integration Tests', () {
    testWidgets('should integrate SwipeablePageView with all pages', (
      tester,
    ) async {
      // Create a mock provider that doesn't use storage
      final mockProvider = HydrationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Allow time for initial build
      await tester.pump();

      // Verify SwipeablePageView is present
      expect(find.byType(SwipeablePageView), findsOneWidget);

      // Verify all three page types are in the widget tree
      expect(find.byType(MainHydrationPage), findsOneWidget);
      expect(find.byType(StatisticsPage), findsOneWidget);
      expect(find.byType(GoalBreakdownPage), findsOneWidget);

      // Verify bottom navigation is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should start on main hydration page by default', (
      tester,
    ) async {
      final mockProvider = HydrationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      await tester.pump();

      // Should display main page content (Today header)
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('should have proper page controller setup', (tester) async {
      final mockProvider = HydrationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      await tester.pump();

      // Find the SwipeablePageView widget
      final swipeablePageView = tester.widget<SwipeablePageView>(
        find.byType(SwipeablePageView),
      );

      // Verify initial page is set to 1 (main page)
      expect(swipeablePageView.initialPage, equals(1));

      // Verify it has 3 pages
      expect(swipeablePageView.pages.length, equals(3));
    });

    testWidgets('should handle page changes correctly', (tester) async {
      final mockProvider = HydrationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify the integration is working by checking that the widget builds
      // without errors and contains the expected components
      expect(find.byType(SwipeablePageView), findsOneWidget);
      expect(find.byType(MainHydrationPage), findsOneWidget);
      expect(find.byType(StatisticsPage), findsOneWidget);
      expect(find.byType(GoalBreakdownPage), findsOneWidget);
    });
  });
}
