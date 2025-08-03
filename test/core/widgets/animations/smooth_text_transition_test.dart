import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/animations/smooth_text_transition.dart';

void main() {
  group('SmoothTextTransition', () {
    testWidgets('displays initial text correctly', (WidgetTester tester) async {
      const initialText = 'Initial Text';
      const textStyle = TextStyle(fontSize: 16);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothTextTransition(text: initialText, style: textStyle),
          ),
        ),
      );

      expect(find.text(initialText), findsOneWidget);
    });

    testWidgets('animates text change smoothly', (WidgetTester tester) async {
      const initialText = 'Initial Text';
      const updatedText = 'Updated Text';
      const textStyle = TextStyle(fontSize: 16);

      String currentText = initialText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SmoothTextTransition(
                      text: currentText,
                      style: textStyle,
                      duration: const Duration(milliseconds: 300),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentText = updatedText;
                        });
                      },
                      child: const Text('Update'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text(initialText), findsOneWidget);
      expect(find.text(updatedText), findsNothing);

      // Trigger text change
      await tester.tap(find.text('Update'));
      await tester.pump();

      // During animation, both texts might be present
      await tester.pump(const Duration(milliseconds: 150));

      // After animation completes
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(updatedText), findsOneWidget);
    });

    testWidgets('handles rapid text changes gracefully', (
      WidgetTester tester,
    ) async {
      const textStyle = TextStyle(fontSize: 16);
      String currentText = 'Text 1';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SmoothTextTransition(
                      text: currentText,
                      style: textStyle,
                      duration: const Duration(milliseconds: 200),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentText =
                              currentText == 'Text 1' ? 'Text 2' : 'Text 1';
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Rapid changes
      await tester.tap(find.text('Toggle'));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Toggle'));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Toggle'));
      await tester.pump(const Duration(milliseconds: 300));

      // Should handle rapid changes without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects custom animation duration', (
      WidgetTester tester,
    ) async {
      const initialText = 'Initial';
      const updatedText = 'Updated';
      const textStyle = TextStyle(fontSize: 16);
      const customDuration = Duration(milliseconds: 500);

      String currentText = initialText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SmoothTextTransition(
                      text: currentText,
                      style: textStyle,
                      duration: customDuration,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentText = updatedText;
                        });
                      },
                      child: const Text('Update'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Update'));
      await tester.pump();

      // Animation should still be in progress after default duration
      await tester.pump(const Duration(milliseconds: 300));

      // Complete the custom duration
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(updatedText), findsOneWidget);
    });

    testWidgets('maintains accessibility properties', (
      WidgetTester tester,
    ) async {
      const text = 'Accessible Text';
      const semanticLabel = 'Custom semantic label';
      const textStyle = TextStyle(fontSize: 16);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothTextTransition(
              text: text,
              style: textStyle,
              semanticLabel: semanticLabel,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(SmoothTextTransition));
      expect(semantics.label, contains(semanticLabel));
    });

    testWidgets('handles empty text gracefully', (WidgetTester tester) async {
      const textStyle = TextStyle(fontSize: 16);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothTextTransition(text: '', style: textStyle),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports text alignment', (WidgetTester tester) async {
      const text = 'Aligned Text';
      const textStyle = TextStyle(fontSize: 16);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothTextTransition(
              text: text,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(text));
      expect(textWidget.textAlign, equals(TextAlign.center));
    });
  });
}
