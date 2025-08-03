import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/animations/advanced_text_transition.dart';

void main() {
  group('AdvancedTextTransition', () {
    testWidgets('displays initial text correctly', (WidgetTester tester) async {
      const initialText = 'Initial Text';
      const textStyle = TextStyle(fontSize: 16);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvancedTextTransition(text: initialText, style: textStyle),
          ),
        ),
      );

      expect(find.text(initialText), findsOneWidget);
    });

    testWidgets('animates text change with staggered timing', (
      WidgetTester tester,
    ) async {
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
                    AdvancedTextTransition(
                      text: currentText,
                      style: textStyle,
                      duration: const Duration(milliseconds: 400),
                      staggerDelay: const Duration(milliseconds: 50),
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

      // During fade-out phase
      await tester.pump(const Duration(milliseconds: 160)); // 40% of 400ms

      // During stagger delay
      await tester.pump(const Duration(milliseconds: 50));

      // During fade-in phase
      await tester.pump(const Duration(milliseconds: 240)); // 60% of 400ms

      // Animation should complete
      expect(find.text(updatedText), findsOneWidget);
    });

    testWidgets('uses custom animation curves', (WidgetTester tester) async {
      const initialText = 'Initial';
      const updatedText = 'Updated';
      const textStyle = TextStyle(fontSize: 16);

      String currentText = initialText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AdvancedTextTransition(
                      text: currentText,
                      style: textStyle,
                      slideInCurve: Curves.elasticOut,
                      slideOutCurve: Curves.easeInCubic,
                      fadeInCurve: Curves.easeInOut,
                      fadeOutCurve: Curves.easeOut,
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

      // Should handle custom curves without errors
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
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
                    AdvancedTextTransition(
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
      await tester.pump(const Duration(milliseconds: 30));

      await tester.tap(find.text('Toggle'));
      await tester.pump(const Duration(milliseconds: 30));

      await tester.tap(find.text('Toggle'));
      await tester.pump(const Duration(milliseconds: 300));

      // Should handle rapid changes without errors
      expect(tester.takeException(), isNull);
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
            body: AdvancedTextTransition(
              text: text,
              style: textStyle,
              semanticLabel: semanticLabel,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byType(AdvancedTextTransition),
      );
      expect(semantics.label, contains(semanticLabel));
    });
  });

  group('CalculationValueTransition', () {
    testWidgets('displays value with unit correctly', (
      WidgetTester tester,
    ) async {
      const value = '2.5';
      const unit = 'L';
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculationValueTransition(
              value: value,
              unit: unit,
              style: style,
            ),
          ),
        ),
      );

      expect(find.text('2.5L'), findsOneWidget);
    });

    testWidgets('handles prefix correctly', (WidgetTester tester) async {
      const value = '100';
      const prefix = '+';
      const style = TextStyle(fontSize: 18);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculationValueTransition(
              value: value,
              prefix: prefix,
              style: style,
            ),
          ),
        ),
      );

      expect(find.text('+100'), findsOneWidget);
    });

    testWidgets('emphasizes changes when enabled', (WidgetTester tester) async {
      const initialValue = '1000';
      const updatedValue = '1500';
      const style = TextStyle(fontSize: 20);

      String currentValue = initialValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CalculationValueTransition(
                      value: currentValue,
                      unit: 'ml',
                      style: style,
                      emphasizeChange: true,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentValue = updatedValue;
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
      expect(find.text('1000ml'), findsOneWidget);

      // Trigger update
      await tester.tap(find.text('Update'));
      await tester.pump();

      // Allow animation to complete
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('1500ml'), findsOneWidget);
    });
  });

  group('AnimatedPercentageText', () {
    testWidgets('displays percentage correctly', (WidgetTester tester) async {
      const percentage = 0.75; // 75%
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedPercentageText(percentage: percentage, style: style),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('handles decimal places correctly', (
      WidgetTester tester,
    ) async {
      const percentage = 0.756; // 75.6%
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedPercentageText(
              percentage: percentage,
              style: style,
              decimalPlaces: 1,
            ),
          ),
        ),
      );

      expect(find.text('75.6%'), findsOneWidget);
    });

    testWidgets('can hide percent sign', (WidgetTester tester) async {
      const percentage = 0.85;
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedPercentageText(
              percentage: percentage,
              style: style,
              showPercentSign: false,
            ),
          ),
        ),
      );

      expect(find.text('85'), findsOneWidget);
    });

    testWidgets('animates percentage changes', (WidgetTester tester) async {
      const style = TextStyle(fontSize: 24);
      double currentPercentage = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AnimatedPercentageText(
                      percentage: currentPercentage,
                      style: style,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentPercentage = 0.8;
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
      expect(find.text('50%'), findsOneWidget);

      // Trigger update
      await tester.tap(find.text('Update'));
      await tester.pump();

      // Allow animation to complete
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('80%'), findsOneWidget);
    });
  });
}
