import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/buttons/prefer_not_to_answer_button.dart';

void main() {
  group('PreferNotToAnswerButton Widget Tests', () {
    testWidgets('renders with skip text correctly', (WidgetTester tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreferNotToAnswerButton(
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('skip'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreferNotToAnswerButton(
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('has correct styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreferNotToAnswerButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<TextButton>(find.byType(TextButton));
      final shape = button.style?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(shape?.borderRadius, equals(BorderRadius.circular(16)));

      // Check minimum size
      final minimumSize = button.style?.minimumSize?.resolve({});
      expect(minimumSize?.width, equals(double.infinity));
      expect(minimumSize?.height, equals(56));
    });

    testWidgets('has correct text styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreferNotToAnswerButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('skip'));
      expect(textWidget.style?.fontWeight, equals(FontWeight.w500));
    });

    testWidgets('has proper spacing in row layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreferNotToAnswerButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      // Check that there's a SizedBox with width 8 for spacing
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacingBox = sizedBoxes.firstWhere(
        (box) => box.width == 8,
        orElse: () => const SizedBox(),
      );
      expect(spacingBox.width, equals(8));
    });

    testWidgets('has row with center alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreferNotToAnswerButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, equals(MainAxisAlignment.center));
    });
  });
}