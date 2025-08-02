import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

void main() {
  group('SwipeablePageView Basic Integration Tests', () {
    testWidgets('should build without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeablePageView(
              pages: [
                Container(child: const Text('Statistics')),
                Container(child: const Text('Main')),
                Container(child: const Text('Goal Breakdown')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display the SwipeablePageView
      expect(find.byType(SwipeablePageView), findsOneWidget);

      // Should start on main page (index 1)
      expect(find.text('Main'), findsOneWidget);
    });

    testWidgets('should have page indicators', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeablePageView(
              pages: [
                Container(child: const Text('Page 1')),
                Container(child: const Text('Page 2')),
                Container(child: const Text('Page 3')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have page indicators (dots)
      final indicators = find.byType(Container).evaluate().where((element) {
        final widget = element.widget as Container;
        final decoration = widget.decoration as BoxDecoration?;
        return decoration?.shape == BoxShape.circle;
      });

      expect(indicators.length, greaterThanOrEqualTo(3));
    });

    testWidgets('should handle page controller navigation', (tester) async {
      final pageController = PageController(initialPage: 1);
      var currentPage = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeablePageView(
              pages: [
                Container(child: const Text('Statistics')),
                Container(child: const Text('Main')),
                Container(child: const Text('Goal Breakdown')),
              ],
              controller: pageController,
              onPageChanged: (page) => currentPage = page,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should start on main page
      expect(find.text('Main'), findsOneWidget);
      expect(currentPage, equals(1));

      // Navigate to first page programmatically
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
      expect(currentPage, equals(0));

      // Navigate to last page
      pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      expect(find.text('Goal Breakdown'), findsOneWidget);
      expect(currentPage, equals(2));

      pageController.dispose();
    });

    testWidgets('should handle custom animation settings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeablePageView(
              pages: [
                Container(child: const Text('Page 1')),
                Container(child: const Text('Page 2')),
                Container(child: const Text('Page 3')),
              ],
              animationDuration: const Duration(milliseconds: 600),
              animationCurve: Curves.bounceInOut,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should build successfully with custom animation settings
      expect(find.byType(SwipeablePageView), findsOneWidget);
    });
  });
}
