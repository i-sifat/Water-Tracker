import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/common/accessible_button.dart';

void main() {
  group('AccessibleButton Widget Tests', () {
    const testLabel = 'Test Button';
    const testTooltip = 'This is a test button';

    testWidgets('renders with child widget', (WidgetTester tester) async {
      const childWidget = Text('Button Text');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              label: testLabel,
              child: childWidget,
            ),
          ),
        ),
      );

      expect(find.text('Button Text'), findsOneWidget);
      expect(find.byType(AccessibleButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () => wasPressed = true,
              label: testLabel,
              child: const Text('Button Text'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AccessibleButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('has correct semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              label: testLabel,
              child: const Text('Button Text'),
            ),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(find.byType(Semantics));
      expect(semantics.properties.label, equals(testLabel));
    });

    testWidgets('shows tooltip when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              label: testLabel,
              tooltip: testTooltip,
              child: const Text('Button Text'),
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
      
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, equals(testTooltip));
    });

    testWidgets('does not show tooltip when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              label: testLabel,
              child: const Text('Button Text'),
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('is disabled when onPressed is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              label: testLabel,
              child: Text('Button Text'),
            ),
          ),
        ),
      );

      final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector));
      expect(gestureDetector.onTap, isNull);
    });

    testWidgets('has correct semantic properties for button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              label: testLabel,
              child: const Text('Button Text'),
            ),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(find.byType(Semantics));
      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.enabled, isTrue);
    });

    testWidgets('has correct semantic properties when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              label: testLabel,
              child: Text('Button Text'),
            ),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(find.byType(Semantics));
      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.enabled, isFalse);
    });

    testWidgets('has minimum touch target size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              label: testLabel,
              child: const SizedBox(width: 20, height: 20),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final constraints = container.constraints;
      expect(constraints?.minWidth, equals(44));
      expect(constraints?.minHeight, equals(44));
    });

    testWidgets('preserves larger child size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              label: testLabel,
              child: const SizedBox(width: 100, height: 60),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(100));
      expect(sizedBox.height, equals(60));
    });

    testWidgets('has correct focus behavior', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              label: testLabel,
              child: const Text('Button Text'),
            ),
          ),
        ),
      );

      final focus = tester.widget<Focus>(find.byType(Focus));
      expect(focus.canRequestFocus, isTrue);
    });

    testWidgets('excludes from semantics when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              label: testLabel,
              child: Text('Button Text'),
            ),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(find.byType(Semantics));
      expect(semantics.properties.enabled, isFalse);
    });
  });
}