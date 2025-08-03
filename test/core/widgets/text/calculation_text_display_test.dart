import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/text/calculation_text_display.dart';

void main() {
  group('CalculationTextDisplay', () {
    testWidgets('displays value with unit correctly', (
      WidgetTester tester,
    ) async {
      const value = '2.5';
      const unit = 'L';
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculationTextDisplay(
              value: value,
              unit: unit,
              style: style,
            ),
          ),
        ),
      );

      expect(find.text(value), findsOneWidget);
      expect(find.text(unit), findsOneWidget);
    });

    testWidgets('displays label and suffix when provided', (
      WidgetTester tester,
    ) async {
      const value = '1500';
      const label = 'Daily Goal';
      const suffix = 'remaining';
      const style = TextStyle(fontSize: 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculationTextDisplay(
              value: value,
              label: label,
              suffix: suffix,
              style: style,
            ),
          ),
        ),
      );

      expect(find.text(value), findsOneWidget);
      expect(find.text(label), findsOneWidget);
      expect(find.text(suffix), findsOneWidget);
    });

    testWidgets('handles prefix correctly', (WidgetTester tester) async {
      const value = '100';
      const prefix = '+';
      const style = TextStyle(fontSize: 18);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculationTextDisplay(
              value: value,
              prefix: prefix,
              style: style,
            ),
          ),
        ),
      );

      expect(find.text(value), findsOneWidget);
      expect(find.text(prefix), findsOneWidget);
    });

    testWidgets('animates value changes smoothly', (WidgetTester tester) async {
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
                    CalculationTextDisplay(
                      value: currentValue,
                      unit: 'ml',
                      style: style,
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
      expect(find.text(initialValue), findsOneWidget);

      // Trigger update
      await tester.tap(find.text('Update'));
      await tester.pump();

      // Allow animation to complete
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(updatedValue), findsOneWidget);
    });

    testWidgets('builds correct semantic label', (WidgetTester tester) async {
      const value = '2.5';
      const label = 'Progress';
      const unit = 'L';
      const suffix = 'consumed';
      const style = TextStyle(fontSize: 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculationTextDisplay(
              value: value,
              label: label,
              unit: unit,
              suffix: suffix,
              style: style,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byType(CalculationTextDisplay),
      );
      expect(semantics.label, contains(label));
      expect(semantics.label, contains(value));
      expect(semantics.label, contains(unit));
      expect(semantics.label, contains(suffix));
    });
  });

  group('PercentageDisplay', () {
    testWidgets('displays percentage correctly', (WidgetTester tester) async {
      const percentage = 0.75; // 75%
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PercentageDisplay(percentage: percentage, style: style),
          ),
        ),
      );

      expect(find.text('75'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('handles decimal places correctly', (
      WidgetTester tester,
    ) async {
      const percentage = 0.756; // 75.6%
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PercentageDisplay(
              percentage: percentage,
              style: style,
              decimalPlaces: 1,
            ),
          ),
        ),
      );

      expect(find.text('75.6'), findsOneWidget);
    });

    testWidgets('can hide percent sign', (WidgetTester tester) async {
      const percentage = 0.85;
      const style = TextStyle(fontSize: 24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PercentageDisplay(
              percentage: percentage,
              style: style,
              showPercentSign: false,
            ),
          ),
        ),
      );

      expect(find.text('85'), findsOneWidget);
      expect(find.text('%'), findsNothing);
    });
  });

  group('VolumeDisplay', () {
    testWidgets('displays volume in ml for small amounts', (
      WidgetTester tester,
    ) async {
      const volumeInMl = 500;
      const style = TextStyle(fontSize: 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VolumeDisplay(
              volumeInMl: volumeInMl,
              style: style,
              preferLiters: true,
            ),
          ),
        ),
      );

      expect(find.text('500'), findsOneWidget);
      expect(find.text('ml'), findsOneWidget);
    });

    testWidgets('displays volume in liters for large amounts', (
      WidgetTester tester,
    ) async {
      const volumeInMl = 2500;
      const style = TextStyle(fontSize: 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VolumeDisplay(
              volumeInMl: volumeInMl,
              style: style,
              preferLiters: true,
            ),
          ),
        ),
      );

      expect(find.text('2.5'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
    });

    testWidgets('forces ml display when preferLiters is false', (
      WidgetTester tester,
    ) async {
      const volumeInMl = 2500;
      const style = TextStyle(fontSize: 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VolumeDisplay(
              volumeInMl: volumeInMl,
              style: style,
              preferLiters: false,
            ),
          ),
        ),
      );

      expect(find.text('2500'), findsOneWidget);
      expect(find.text('ml'), findsOneWidget);
    });

    testWidgets('includes label when provided', (WidgetTester tester) async {
      const volumeInMl = 1000;
      const label = 'Daily Goal';
      const style = TextStyle(fontSize: 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VolumeDisplay(
              volumeInMl: volumeInMl,
              label: label,
              style: style,
            ),
          ),
        ),
      );

      expect(find.text(label), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
    });
  });
}
