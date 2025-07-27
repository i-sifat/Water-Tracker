import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';

void main() {
  group('ContinueButton Widget Tests', () {
    testWidgets('renders with Continue text and arrow icon', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueButton(
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueButton(
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('is disabled when isDisabled is true', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueButton(
              onPressed: () => wasPressed = true,
              isDisabled: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('has correct styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final shape = button.style?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(shape?.borderRadius, equals(BorderRadius.circular(24)));

      // Check minimum size
      final minimumSize = button.style?.minimumSize?.resolve({});
      expect(minimumSize?.width, equals(double.infinity));
      expect(minimumSize?.height, equals(56));
    });

    testWidgets('has correct text and icon colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the text widget
      final textWidget = tester.widget<Text>(find.text('Continue'));
      expect(textWidget.style?.color, equals(Colors.white));

      // Find the icon widget
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.arrow_forward));
      expect(iconWidget.color, equals(Colors.white));
      expect(iconWidget.size, equals(20));
    });

    testWidgets('has proper spacing between text and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      // Check that there's a SizedBox with width 8 between text and icon
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacingBox = sizedBoxes.firstWhere(
        (box) => box.width == 8,
        orElse: () => const SizedBox(),
      );
      expect(spacingBox.width, equals(8));
    });

    testWidgets('maintains enabled state when isDisabled is false', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueButton(
              onPressed: () => wasPressed = true,
              isDisabled: false,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });
  });
}