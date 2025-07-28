import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/animations/water_animation.dart';

void main() {
  group('WaterAnimation Widget Tests', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterAnimation(
              progress: 0.5,
              waterColor: Colors.blue,
              backgroundColor: Colors.grey,
              width: 200,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(WaterAnimation), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('applies correct dimensions', (WidgetTester tester) async {
      const width = 150.0;
      const height = 250.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterAnimation(
              progress: 0.3,
              waterColor: Colors.blue,
              backgroundColor: Colors.grey,
              width: width,
              height: height,
            ),
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      expect(customPaint.size.width, equals(width));
      expect(customPaint.size.height, equals(height));
    });

    testWidgets('updates when progress changes', (WidgetTester tester) async {
      var progress = 0.3;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    WaterAnimation(
                      progress: progress,
                      waterColor: Colors.blue,
                      backgroundColor: Colors.grey,
                      width: 200,
                      height: 300,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 0.7;
                        });
                      },
                      child: const Text('Update Progress'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initial state
      expect(find.byType(WaterAnimation), findsOneWidget);

      // Update progress
      await tester.tap(find.text('Update Progress'));
      await tester.pump();

      // Animation should still be present and updated
      expect(find.byType(WaterAnimation), findsOneWidget);
    });

    testWidgets('has animation controllers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterAnimation(
              progress: 0.5,
              waterColor: Colors.blue,
              backgroundColor: Colors.grey,
              width: 200,
              height: 300,
            ),
          ),
        ),
      );

      // Pump a few frames to ensure animations are running
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });

    testWidgets('disposes controllers properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterAnimation(
              progress: 0.5,
              waterColor: Colors.blue,
              backgroundColor: Colors.grey,
              width: 200,
              height: 300,
            ),
          ),
        ),
      );

      // Remove the widget to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles zero progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterAnimation(
              progress: 0,
              waterColor: Colors.blue,
              backgroundColor: Colors.grey,
              width: 200,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(WaterAnimation), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles full progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterAnimation(
              progress: 1,
              waterColor: Colors.blue,
              backgroundColor: Colors.grey,
              width: 200,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(WaterAnimation), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses ClipRect for proper clipping', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterAnimation(
              progress: 0.5,
              waterColor: Colors.blue,
              backgroundColor: Colors.grey,
              width: 200,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(ClipRect), findsOneWidget);
    });

    testWidgets('creates bubbles for animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterAnimation(
              progress: 0.5,
              waterColor: Colors.blue,
              backgroundColor: Colors.grey,
              width: 200,
              height: 300,
            ),
          ),
        ),
      );

      // Let the animation run for a bit to generate bubbles
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(WaterAnimation), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('responds to color changes', (WidgetTester tester) async {
      Color waterColor = Colors.blue;
      Color backgroundColor = Colors.grey;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    WaterAnimation(
                      progress: 0.5,
                      waterColor: waterColor,
                      backgroundColor: backgroundColor,
                      width: 200,
                      height: 300,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          waterColor = Colors.red;
                          backgroundColor = Colors.black;
                        });
                      },
                      child: const Text('Change Colors'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initial state
      expect(find.byType(WaterAnimation), findsOneWidget);

      // Change colors
      await tester.tap(find.text('Change Colors'));
      await tester.pump();

      // Animation should still be present with new colors
      expect(find.byType(WaterAnimation), findsOneWidget);
    });
  });

  group('Bubble Class Tests', () {
    test('creates bubble with correct properties', () {
      final bubble = Bubble(
        x: 10,
        y: 20,
        currentY: 20,
        radius: 5,
        speed: 50,
        active: true,
      );

      expect(bubble.x, equals(10.0));
      expect(bubble.y, equals(20.0));
      expect(bubble.currentY, equals(20.0));
      expect(bubble.radius, equals(5.0));
      expect(bubble.speed, equals(50.0));
      expect(bubble.active, isTrue);
    });

    test('bubble properties can be modified', () {
      final bubble = Bubble(
        x: 10,
        y: 20,
        currentY: 20,
        radius: 5,
        speed: 50,
        active: true,
      );

      bubble.currentY = 15.0;
      bubble.active = false;

      expect(bubble.currentY, equals(15.0));
      expect(bubble.active, isFalse);
    });
  });

  group('WaterLevelPainter Tests', () {
    test('creates painter with correct properties', () {
      final painter = WaterLevelPainter(
        progress: 0.5,
        waterColor: Colors.blue,
        backgroundColor: Colors.grey,
        animationValue: 0.3,
        bubbles: [],
      );

      expect(painter.progress, equals(0.5));
      expect(painter.waterColor, equals(Colors.blue));
      expect(painter.backgroundColor, equals(Colors.grey));
      expect(painter.animationValue, equals(0.3));
      expect(painter.bubbles, isEmpty);
    });

    test('shouldRepaint returns true when progress changes', () {
      final painter1 = WaterLevelPainter(
        progress: 0.5,
        waterColor: Colors.blue,
        backgroundColor: Colors.grey,
        animationValue: 0.3,
        bubbles: [],
      );

      final painter2 = WaterLevelPainter(
        progress: 0.7,
        waterColor: Colors.blue,
        backgroundColor: Colors.grey,
        animationValue: 0.3,
        bubbles: [],
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when animationValue changes', () {
      final painter1 = WaterLevelPainter(
        progress: 0.5,
        waterColor: Colors.blue,
        backgroundColor: Colors.grey,
        animationValue: 0.3,
        bubbles: [],
      );

      final painter2 = WaterLevelPainter(
        progress: 0.5,
        waterColor: Colors.blue,
        backgroundColor: Colors.grey,
        animationValue: 0.8,
        bubbles: [],
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns false when nothing changes', () {
      final painter1 = WaterLevelPainter(
        progress: 0.5,
        waterColor: Colors.blue,
        backgroundColor: Colors.grey,
        animationValue: 0.3,
        bubbles: [],
      );

      final painter2 = WaterLevelPainter(
        progress: 0.5,
        waterColor: Colors.blue,
        backgroundColor: Colors.grey,
        animationValue: 0.3,
        bubbles: [],
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });
  });
}
