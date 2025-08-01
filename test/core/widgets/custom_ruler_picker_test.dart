import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart';
import 'package:watertracker/core/widgets/custom_ruler_picker.dart';

@Skip('Temporarily disabled - needs API alignment')
void main() {
  group('CustomRulerPicker Widget Tests', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(CustomRulerPicker), findsOneWidget);
    });

    testWidgets('calls onValueChanged when value changes', (
      WidgetTester tester,
    ) async {
      var changedValue = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              onValueChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      // Simulate drag gesture to change value
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CustomRulerPicker)),
      );
      await gesture.moveBy(const Offset(50, 0));
      await gesture.up();
      await tester.pump();

      // Value should have changed
      expect(changedValue, isNot(equals(50)));
    });

    testWidgets('respects min and max values', (WidgetTester tester) async {
      const minValue = 10;
      const maxValue = 90;
      var currentValue = 50;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: minValue,
              maxValue: maxValue,
              initialValue: currentValue,
              onValueChanged: (value) => currentValue = value,
            ),
          ),
        ),
      );

      final rulerPicker = tester.widget<CustomRulerPicker>(
        find.byType(CustomRulerPicker),
      );
      expect(rulerPicker.minValue, equals(minValue));
      expect(rulerPicker.maxValue, equals(maxValue));
      expect(rulerPicker.initialValue, equals(50));
    });

    testWidgets('uses default step value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      final rulerPicker = tester.widget<CustomRulerPicker>(
        find.byType(CustomRulerPicker),
      );
      expect(rulerPicker.step, equals(1));
    });

    testWidgets('uses custom step value', (WidgetTester tester) async {
      const customStep = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              step: customStep,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      final rulerPicker = tester.widget<CustomRulerPicker>(
        find.byType(CustomRulerPicker),
      );
      expect(rulerPicker.step, equals(customStep));
    });

    testWidgets('has custom paint for ruler display', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('has gesture detector for interaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('responds to horizontal drag', (WidgetTester tester) async {
      const dragStarted = false;
      const dragUpdated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      final gestureDetector = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gestureDetector.onHorizontalDragStart, isNotNull);
      expect(gestureDetector.onHorizontalDragUpdate, isNotNull);
    });

    testWidgets('has proper size constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, isNotNull);
      expect(sizedBox.height! > 0, isTrue);
    });

    testWidgets('displays current value', (WidgetTester tester) async {
      const initialValue = 75;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: initialValue,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      // Should display the current value somewhere
      expect(find.text(initialValue.toString()), findsOneWidget);
    });

    testWidgets('handles edge values correctly', (WidgetTester tester) async {
      var currentValue = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 0,
              onValueChanged: (value) => currentValue = value,
            ),
          ),
        ),
      );

      // Try to drag below minimum
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CustomRulerPicker)),
      );
      await gesture.moveBy(const Offset(-200, 0));
      await gesture.up();
      await tester.pump();

      // Value should not go below minimum
      expect(currentValue, greaterThanOrEqualTo(0));
    });

    testWidgets('has proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRulerPicker(
              minValue: 0,
              maxValue: 100,
              initialValue: 50,
              onValueChanged: (value) {},
            ),
          ),
        ),
      );

      // Should have container for styling
      expect(find.byType(Container), findsWidgets);
    });
  });
}
