import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';

void main() {
  group('MainHydrationPage Integration Tests', () {
    Widget createTestWidget({int currentPage = 1, int totalPages = 3}) {
      return MaterialApp(
        home: Scaffold(
          body: MainHydrationPage(
            currentPage: currentPage,
            totalPages: totalPages,
          ),
        ),
      );
    }

    group('Header Layout Tests', () {
      testWidgets('displays header with Today title and navigation icons', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // Check Today title is displayed
        expect(find.text('Today'), findsOneWidget);

        // Check hamburger menu icon
        expect(find.byIcon(Icons.menu), findsOneWidget);

        // Check profile icon
        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });

      testWidgets('displays time range indicators', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Check all time indicators are present
        expect(find.text('07:00 AM'), findsOneWidget);
        expect(find.text('2min'), findsOneWidget);
        expect(find.text('11:00 PM'), findsOneWidget);
      });

      testWidgets('hamburger menu icon has proper styling', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final menuContainer = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(Icons.menu),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(menuContainer.decoration, isA<BoxDecoration>());
        final decoration = menuContainer.decoration! as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(12));
      });

      testWidgets('profile icon has proper styling', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final profileContainer = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(Icons.person_outline),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(profileContainer.decoration, isA<BoxDecoration>());
        final decoration = profileContainer.decoration! as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(12));
      });
    });

    group('Background and Styling Tests', () {
      testWidgets('applies gradient background matching design mockup', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );

        expect(container.decoration, isA<BoxDecoration>());
        final decoration = container.decoration! as BoxDecoration;
        expect(decoration.gradient, isA<LinearGradient>());

        final gradient = decoration.gradient! as LinearGradient;
        expect(gradient.colors, [
          const Color(0xFF6B73FF),
          const Color(0xFF9546C4),
        ]);
        expect(gradient.begin, Alignment.topCenter);
        expect(gradient.end, Alignment.bottomCenter);
      });

      testWidgets('uses proper spacing between components', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Check that components are properly spaced
        final column = tester.widget<Column>(
          find.descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Column),
          ),
        );

        // Verify spacing between components
        final sizedBoxes = column.children.whereType<SizedBox>();
        expect(sizedBoxes.length, greaterThan(2));

        // Check specific spacing values
        final spacingValues = sizedBoxes.map((box) => box.height).toList();
        expect(spacingValues, contains(20.0)); // After header
        expect(spacingValues, contains(32.0)); // After progress section
        expect(spacingValues, contains(24.0)); // After drink selector
      });
    });

    group('Navigation Integration Tests', () {
      testWidgets('hamburger menu tap opens drawer when available', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              drawer: Drawer(child: Text('Menu')),
              body: MainHydrationPage(),
            ),
          ),
        );

        // Tap hamburger menu
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        // Check if drawer opened
        expect(find.text('Menu'), findsOneWidget);
      });

      testWidgets('profile icon tap triggers debug print', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // This test verifies the tap is handled, actual navigation
        // would be tested in full app integration tests
        await tester.tap(find.byIcon(Icons.person_outline));
        await tester.pumpAndSettle();

        // No exception should be thrown
        expect(tester.takeException(), isNull);
      });
    });

    group('Responsive Layout Tests', () {
      testWidgets('adapts to different screen sizes', (tester) async {
        // Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(320, 568)); // Small
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(MainHydrationPage), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(414, 896)); // Large
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(MainHydrationPage), findsOneWidget);

        // Reset to default
        await tester.binding.setSurfaceSize(const Size(800, 600));
      });

      testWidgets('scrollable content works properly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the scrollable area
        final scrollView = find.byType(SingleChildScrollView);
        expect(scrollView, findsOneWidget);

        // Test scrolling
        await tester.drag(scrollView, const Offset(0, -200));
        await tester.pumpAndSettle();

        // Content should still be visible after scrolling
        expect(find.text('Today'), findsOneWidget);
      });
    });

    group('Page Indicator Tests', () {
      testWidgets('passes correct page indicators to components', (
        tester,
      ) async {
        const testCurrentPage = 2;
        const testTotalPages = 5;

        await tester.pumpWidget(
          createTestWidget(
            currentPage: testCurrentPage,
            totalPages: testTotalPages,
          ),
        );

        // Verify the page parameters are passed correctly
        final mainPage = tester.widget<MainHydrationPage>(
          find.byType(MainHydrationPage),
        );

        expect(mainPage.currentPage, testCurrentPage);
        expect(mainPage.totalPages, testTotalPages);
      });
    });

    group('Component Structure Tests', () {
      testWidgets('contains all required UI components', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Check that the main structure is present
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(find.byType(Column), findsAtLeastNWidgets(1));

        // Check that header components are present
        expect(find.text('Today'), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.byIcon(Icons.person_outline), findsOneWidget);

        // Check time indicators
        expect(find.text('07:00 AM'), findsOneWidget);
        expect(find.text('2min'), findsOneWidget);
        expect(find.text('11:00 PM'), findsOneWidget);
      });

      testWidgets('uses correct typography and styling', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Check Today title styling
        final todayText = tester.widget<Text>(find.text('Today'));
        expect(todayText.style?.fontSize, 24);
        expect(todayText.style?.fontWeight, FontWeight.w700);
        expect(todayText.style?.color, Colors.white);
        expect(todayText.style?.fontFamily, 'Nunito');

        // Check time indicator styling
        final timeIndicators = tester.widgetList<Text>(
          find.textContaining(RegExp('(AM|PM|min)')),
        );

        for (final indicator in timeIndicators) {
          expect(indicator.style?.fontSize, 12);
          expect(indicator.style?.fontWeight, FontWeight.w500);
          expect(indicator.style?.color, Colors.white);
          expect(indicator.style?.fontFamily, 'Nunito');
        }
      });
    });

    group('Error Handling Tests', () {
      testWidgets('handles missing provider gracefully', (tester) async {
        // This test ensures the widget structure is sound even without provider
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: MainHydrationPage())),
        );

        // The header should still be visible even if provider fails
        expect(find.text('Today'), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsOneWidget);
        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });
    });
  });
}
