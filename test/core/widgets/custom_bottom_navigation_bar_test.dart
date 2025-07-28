import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';

void main() {
  group('CustomBottomNavigationBar Widget Tests', () {
    testWidgets('renders with correct number of navigation items', (WidgetTester tester) async {
      var selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: selectedIndex,
              onItemTapped: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      // Should have 3 navigation items
      expect(find.byType(GestureDetector), findsNWidgets(3));
      expect(find.byType(SvgPicture), findsNWidgets(3));
    });

    testWidgets('calls onItemTapped when item is tapped', (WidgetTester tester) async {
      const selectedIndex = 0;
      var tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: selectedIndex,
              onItemTapped: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      // Tap the second item
      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pump();

      expect(tappedIndex, equals(1));
    });

    testWidgets('shows selected state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 1,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      // Find all animated containers
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // The selected item (index 1) should have a different background color
      expect(animatedContainers, hasLength(3));
    });

    testWidgets('uses default background color when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, equals(Colors.white));
    });

    testWidgets('uses custom background color when provided', (WidgetTester tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, equals(customColor));
    });

    testWidgets('has correct height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, equals(60));
    });

    testWidgets('has safe area', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('navigation items have correct spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, equals(MainAxisAlignment.spaceEvenly));
    });

    testWidgets('animated containers have correct animation duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      for (final container in animatedContainers) {
        expect(container.duration, equals(const Duration(milliseconds: 200)));
        expect(container.curve, equals(Curves.easeInOut));
      }
    });

    testWidgets('svg icons have correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      final svgPictures = tester.widgetList<SvgPicture>(find.byType(SvgPicture));

      for (final svg in svgPictures) {
        expect(svg.width, equals(24));
        expect(svg.height, equals(24));
      }
    });

    testWidgets('gesture detectors have opaque hit test behavior', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      );

      for (final detector in gestureDetectors) {
        expect(detector.behavior, equals(HitTestBehavior.opaque));
      }
    });

    testWidgets('animated containers have correct border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      for (final container in animatedContainers) {
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.borderRadius, equals(BorderRadius.circular(30)));
      }
    });

    testWidgets('handles multiple taps correctly', (WidgetTester tester) async {
      const selectedIndex = 0;
      final tappedIndices = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBottomNavigationBar(
              selectedIndex: selectedIndex,
              onItemTapped: tappedIndices.add,
            ),
          ),
        ),
      );

      // Tap different items
      await tester.tap(find.byType(GestureDetector).at(0));
      await tester.pump();
      await tester.tap(find.byType(GestureDetector).at(2));
      await tester.pump();
      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pump();

      expect(tappedIndices, equals([0, 2, 1]));
    });
  });
}
