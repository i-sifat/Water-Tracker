import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

void main() {
  group('SwipeablePageView Integration Tests', () {
    late HydrationProvider mockProvider;

    setUp(() {
      mockProvider = HydrationProvider();
      // Add some test data
      mockProvider.setDailyGoal(3000);
    });

    Widget createTestWidget({
      int initialPage = 1,
      PageController? controller,
      ValueChanged<int>? onPageChanged,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: Scaffold(
            body: SwipeablePageView(
              pages: const [
                StatisticsPage(),
                MainHydrationPage(),
                GoalBreakdownPage(),
              ],
              initialPage: initialPage,
              controller: controller,
              onPageChanged: onPageChanged,
            ),
          ),
        ),
      );
    }

    testWidgets('should display all three pages correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should start on main page (index 1)
      expect(find.text('Today'), findsOneWidget);
      expect(find.byType(MainHydrationPage), findsOneWidget);
    });

    testWidgets('should navigate to statistics page on swipe up', (
      tester,
    ) async {
      final pageController = PageController(initialPage: 1);
      var currentPage = 1;

      await tester.pumpWidget(
        createTestWidget(
          controller: pageController,
          onPageChanged: (page) => currentPage = page,
        ),
      );
      await tester.pumpAndSettle();

      // Simulate swipe up gesture (drag down on screen)
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, 200));
      await tester.pumpAndSettle();

      // Should navigate to statistics page (index 0)
      expect(currentPage, equals(0));
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.byType(StatisticsPage), findsOneWidget);

      pageController.dispose();
    });

    testWidgets('should navigate to goal breakdown page on swipe down', (
      tester,
    ) async {
      final pageController = PageController(initialPage: 1);
      var currentPage = 1;

      await tester.pumpWidget(
        createTestWidget(
          controller: pageController,
          onPageChanged: (page) => currentPage = page,
        ),
      );
      await tester.pumpAndSettle();

      // Simulate swipe down gesture (drag up on screen)
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Should navigate to goal breakdown page (index 2)
      expect(currentPage, equals(2));
      expect(find.text('Goal Breakdown'), findsOneWidget);
      expect(find.byType(GoalBreakdownPage), findsOneWidget);

      pageController.dispose();
    });

    testWidgets('should update page indicators correctly', (tester) async {
      final pageController = PageController(initialPage: 1);

      await tester.pumpWidget(createTestWidget(controller: pageController));
      await tester.pumpAndSettle();

      // Find page indicators
      final indicators = find.byType(Container).evaluate().where((element) {
        final widget = element.widget as Container;
        final decoration = widget.decoration as BoxDecoration?;
        return decoration?.shape == BoxShape.circle;
      });

      // Should have 3 page indicators
      expect(indicators.length, greaterThanOrEqualTo(3));

      pageController.dispose();
    });

    testWidgets('should handle page controller changes', (tester) async {
      final pageController = PageController(initialPage: 1);
      var currentPage = 1;

      await tester.pumpWidget(
        createTestWidget(
          controller: pageController,
          onPageChanged: (page) => currentPage = page,
        ),
      );
      await tester.pumpAndSettle();

      // Programmatically navigate to statistics page
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      expect(currentPage, equals(0));
      expect(find.text('Statistics'), findsOneWidget);

      // Navigate to goal breakdown page
      pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      expect(currentPage, equals(2));
      expect(find.text('Goal Breakdown'), findsOneWidget);

      pageController.dispose();
    });

    testWidgets('should maintain state across page changes', (tester) async {
      final pageController = PageController(initialPage: 1);

      await tester.pumpWidget(createTestWidget(controller: pageController));
      await tester.pumpAndSettle();

      // Add some hydration data
      await mockProvider.addHydration(500);
      await tester.pumpAndSettle();

      // Navigate to statistics page
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      // Navigate back to main page
      pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      // Should still show the added hydration
      expect(mockProvider.currentIntake, equals(500));

      pageController.dispose();
    });

    testWidgets('should handle boundary conditions correctly', (tester) async {
      final pageController = PageController();

      await tester.pumpWidget(createTestWidget(controller: pageController));
      await tester.pumpAndSettle();

      // Try to swipe up from statistics page (should not go beyond boundary)
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, 200));
      await tester.pumpAndSettle();

      // Should still be on statistics page
      expect(find.text('Statistics'), findsOneWidget);

      // Navigate to goal breakdown page
      pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      // Try to swipe down from goal breakdown page (should not go beyond boundary)
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Should still be on goal breakdown page
      expect(find.text('Goal Breakdown'), findsOneWidget);

      pageController.dispose();
    });

    testWidgets('should provide haptic feedback on page changes', (
      tester,
    ) async {
      final pageController = PageController(initialPage: 1);

      await tester.pumpWidget(createTestWidget(controller: pageController));
      await tester.pumpAndSettle();

      // Simulate swipe gesture
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, 200));
      await tester.pumpAndSettle();

      // Note: Haptic feedback testing is limited in widget tests
      // This test mainly ensures no exceptions are thrown
      expect(find.byType(SwipeablePageView), findsOneWidget);

      pageController.dispose();
    });

    testWidgets('should handle animation duration and curve correctly', (
      tester,
    ) async {
      const customDuration = Duration(milliseconds: 600);
      const customCurve = Curves.bounceInOut;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: const Scaffold(
              body: SwipeablePageView(
                pages: [
                  StatisticsPage(),
                  MainHydrationPage(),
                  GoalBreakdownPage(),
                ],
                animationDuration: customDuration,
                animationCurve: customCurve,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify widget builds successfully with custom animation settings
      expect(find.byType(SwipeablePageView), findsOneWidget);
    });

    testWidgets('should handle external page controller correctly', (
      tester,
    ) async {
      final externalController = PageController(initialPage: 2);
      var pageChangedCallCount = 0;

      await tester.pumpWidget(
        createTestWidget(
          controller: externalController,
          onPageChanged: (page) => pageChangedCallCount++,
        ),
      );
      await tester.pumpAndSettle();

      // Should start on goal breakdown page
      expect(find.text('Goal Breakdown'), findsOneWidget);

      // Use external controller to navigate
      externalController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
      expect(pageChangedCallCount, greaterThan(0));

      externalController.dispose();
    });
  });
}
