import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/painters/circular_progress_painter.dart';

void main() {
  group('CircularProgressPainter', () {
    group('Constructor', () {
      test('creates painter with default values', () {
        const painter = CircularProgressPainter(progress: 0.5);

        expect(painter.progress, equals(0.5));
        expect(painter.strokeWidth, equals(12.0));
        expect(painter.backgroundColor, equals(const Color(0xFFE5E5E5)));
        expect(
          painter.progressColors,
          equals([const Color(0xFF2196F3), const Color(0xFF1976D2)]),
        );
        expect(painter.innerRingColor, equals(const Color(0xFF4CAF50)));
        expect(painter.innerRingWidth, equals(3.0));
        expect(painter.startAngle, equals(-math.pi / 2));
      });

      test('creates painter with custom values', () {
        const painter = CircularProgressPainter(
          progress: 0.75,
          strokeWidth: 15,
          backgroundColor: Colors.grey,
          progressColors: [Colors.red, Colors.orange],
          innerRingColor: Colors.green,
          innerRingWidth: 5,
          startAngle: 0,
        );

        expect(painter.progress, equals(0.75));
        expect(painter.strokeWidth, equals(15.0));
        expect(painter.backgroundColor, equals(Colors.grey));
        expect(painter.progressColors, equals([Colors.red, Colors.orange]));
        expect(painter.innerRingColor, equals(Colors.green));
        expect(painter.innerRingWidth, equals(5.0));
        expect(painter.startAngle, equals(0.0));
      });
    });

    group('Progress Calculations', () {
      test('clamps progress to valid range', () {
        // Test with progress > 1.0
        const painter1 = CircularProgressPainter(progress: 1.5);
        expect(painter1.progress, equals(1.5)); // Stored as-is

        // Test with progress < 0.0
        const painter2 = CircularProgressPainter(progress: -0.5);
        expect(painter2.progress, equals(-0.5)); // Stored as-is

        // Note: Clamping happens during painting, not in constructor
      });

      test('handles edge cases for progress values', () {
        const painter1 = CircularProgressPainter(progress: 0);
        const painter2 = CircularProgressPainter(progress: 1);

        expect(painter1.progress, equals(0.0));
        expect(painter2.progress, equals(1.0));
      });
    });

    group('shouldRepaint', () {
      test('returns true when progress changes', () {
        const painter1 = CircularProgressPainter(progress: 0.5);
        const painter2 = CircularProgressPainter(progress: 0.7);

        expect(painter1.shouldRepaint(painter2), isTrue);
        expect(painter2.shouldRepaint(painter1), isTrue);
      });

      test('returns true when strokeWidth changes', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
          strokeWidth: 10,
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
          strokeWidth: 15,
        );

        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('returns true when backgroundColor changes', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
          backgroundColor: Colors.grey,
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
          backgroundColor: Colors.blue,
        );

        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('returns true when progressColors change', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
          progressColors: [Colors.red, Colors.orange],
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
          progressColors: [Colors.blue, Colors.green],
        );

        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('returns true when innerRingColor changes', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
          innerRingColor: Colors.green,
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
          innerRingColor: Colors.red,
        );

        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('returns true when innerRingWidth changes', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
          innerRingWidth: 5,
        );

        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('returns true when startAngle changes', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
          startAngle: 0,
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
          startAngle: math.pi / 2,
        );

        expect(painter1.shouldRepaint(painter2), isTrue);
      });

      test('returns false when all properties are the same', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
        );

        expect(painter1.shouldRepaint(painter2), isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with updated progress', () {
        const original = CircularProgressPainter(progress: 0.5);
        final copy = original.copyWith(progress: 0.8);

        expect(copy.progress, equals(0.8));
        expect(copy.strokeWidth, equals(original.strokeWidth));
        expect(copy.backgroundColor, equals(original.backgroundColor));
      });

      test('creates copy with updated strokeWidth', () {
        const original = CircularProgressPainter(progress: 0.5);
        final copy = original.copyWith(strokeWidth: 15);

        expect(copy.progress, equals(original.progress));
        expect(copy.strokeWidth, equals(15.0));
        expect(copy.backgroundColor, equals(original.backgroundColor));
      });

      test('creates copy with updated backgroundColor', () {
        const original = CircularProgressPainter(progress: 0.5);
        final copy = original.copyWith(backgroundColor: Colors.red);

        expect(copy.progress, equals(original.progress));
        expect(copy.strokeWidth, equals(original.strokeWidth));
        expect(copy.backgroundColor, equals(Colors.red));
      });

      test('creates copy with updated progressColors', () {
        const original = CircularProgressPainter(progress: 0.5);
        final copy = original.copyWith(
          progressColors: [Colors.red, Colors.orange],
        );

        expect(copy.progress, equals(original.progress));
        expect(copy.progressColors, equals([Colors.red, Colors.orange]));
      });

      test('creates copy with updated innerRingColor', () {
        const original = CircularProgressPainter(progress: 0.5);
        final copy = original.copyWith(innerRingColor: Colors.red);

        expect(copy.progress, equals(original.progress));
        expect(copy.innerRingColor, equals(Colors.red));
      });

      test('creates copy with updated innerRingWidth', () {
        const original = CircularProgressPainter(progress: 0.5);
        final copy = original.copyWith(innerRingWidth: 5);

        expect(copy.progress, equals(original.progress));
        expect(copy.innerRingWidth, equals(5.0));
      });

      test('creates copy with updated startAngle', () {
        const original = CircularProgressPainter(progress: 0.5);
        final copy = original.copyWith(startAngle: 0);

        expect(copy.progress, equals(original.progress));
        expect(copy.startAngle, equals(0.0));
      });

      test('creates copy with multiple updated properties', () {
        const original = CircularProgressPainter(progress: 0.5);
        final copy = original.copyWith(
          progress: 0.8,
          strokeWidth: 15,
          backgroundColor: Colors.red,
        );

        expect(copy.progress, equals(0.8));
        expect(copy.strokeWidth, equals(15.0));
        expect(copy.backgroundColor, equals(Colors.red));
        expect(copy.progressColors, equals(original.progressColors));
        expect(copy.innerRingColor, equals(original.innerRingColor));
      });

      test('creates identical copy when no parameters provided', () {
        const original = CircularProgressPainter(
          progress: 0.5,
          strokeWidth: 15,
          backgroundColor: Colors.red,
        );
        final copy = original.copyWith();

        expect(copy.progress, equals(original.progress));
        expect(copy.strokeWidth, equals(original.strokeWidth));
        expect(copy.backgroundColor, equals(original.backgroundColor));
        expect(copy.progressColors, equals(original.progressColors));
        expect(copy.innerRingColor, equals(original.innerRingColor));
        expect(copy.innerRingWidth, equals(original.innerRingWidth));
        expect(copy.startAngle, equals(original.startAngle));
      });
    });

    group('Equality and HashCode', () {
      test('painters with same properties are equal', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
        );

        expect(painter1, equals(painter2));
        expect(painter1.hashCode, equals(painter2.hashCode));
      });

      test('painters with different properties are not equal', () {
        const painter1 = CircularProgressPainter(progress: 0.5);
        const painter2 = CircularProgressPainter(progress: 0.7);

        expect(painter1, isNot(equals(painter2)));
        expect(painter1.hashCode, isNot(equals(painter2.hashCode)));
      });

      test('painter is equal to itself', () {
        const painter = CircularProgressPainter(progress: 0.5);

        expect(painter, equals(painter));
        expect(painter.hashCode, equals(painter.hashCode));
      });

      test('painter is not equal to different type', () {
        const painter = CircularProgressPainter(progress: 0.5);
        const other = 'not a painter';

        expect(painter, isNot(equals(other)));
      });
    });

    group('Paint Method Integration', () {
      testWidgets('painter can be used in CustomPaint widget', (tester) async {
        const painter = CircularProgressPainter(progress: 0.5);

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(painter: painter),
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('painter handles zero progress', (tester) async {
        const painter = CircularProgressPainter(progress: 0);

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(painter: painter),
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('painter handles full progress', (tester) async {
        const painter = CircularProgressPainter(progress: 1);

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(painter: painter),
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsOneWidget);
      });
    });

    group('Performance Optimization', () {
      test('shouldRepaint optimization works correctly', () {
        const painter1 = CircularProgressPainter(progress: 0.5);
        const painter2 = CircularProgressPainter(progress: 0.5);
        const painter3 = CircularProgressPainter(progress: 0.7);

        // Same properties should not repaint
        expect(painter1.shouldRepaint(painter2), isFalse);

        // Different properties should repaint
        expect(painter1.shouldRepaint(painter3), isTrue);
      });

      test('list comparison works correctly for progressColors', () {
        const painter1 = CircularProgressPainter(
          progress: 0.5,
          progressColors: [Colors.red, Colors.blue],
        );
        const painter2 = CircularProgressPainter(
          progress: 0.5,
          progressColors: [Colors.red, Colors.blue],
        );
        const painter3 = CircularProgressPainter(
          progress: 0.5,
          progressColors: [Colors.red, Colors.green],
        );

        expect(painter1.shouldRepaint(painter2), isFalse);
        expect(painter1.shouldRepaint(painter3), isTrue);
      });
    });

    group('Edge Cases', () {
      test('handles negative progress values', () {
        const painter = CircularProgressPainter(progress: -0.5);
        expect(painter.progress, equals(-0.5));
      });

      test('handles progress values greater than 1', () {
        const painter = CircularProgressPainter(progress: 1.5);
        expect(painter.progress, equals(1.5));
      });

      test('handles zero stroke width', () {
        const painter = CircularProgressPainter(
          progress: 0.5,
          strokeWidth: 0,
        );
        expect(painter.strokeWidth, equals(0.0));
      });

      test('handles zero inner ring width', () {
        const painter = CircularProgressPainter(
          progress: 0.5,
          innerRingWidth: 0,
        );
        expect(painter.innerRingWidth, equals(0.0));
      });

      test('handles empty progress colors list', () {
        const painter = CircularProgressPainter(
          progress: 0.5,
          progressColors: [],
        );
        expect(painter.progressColors, isEmpty);
      });

      test('handles single color in progress colors', () {
        const painter = CircularProgressPainter(
          progress: 0.5,
          progressColors: [Colors.blue],
        );
        expect(painter.progressColors, equals([Colors.blue]));
      });
    });
  });
}
