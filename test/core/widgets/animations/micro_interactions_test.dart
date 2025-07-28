import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/animations/micro_interactions.dart';

void main() {
  group('TapAnimation Widget Tests', () {
    const testChild = Text('Tap Me');

    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TapAnimation(onTap: () {}, child: testChild)),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      expect(find.byType(TapAnimation), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapAnimation(onTap: () => wasTapped = true, child: testChild),
          ),
        ),
      );

      await tester.tap(find.byType(TapAnimation));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('uses default scale value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TapAnimation(onTap: () {}, child: testChild)),
        ),
      );

      final tapAnimation = tester.widget<TapAnimation>(
        find.byType(TapAnimation),
      );
      expect(tapAnimation.scale, equals(0.95));
    });

    testWidgets('uses custom scale value', (WidgetTester tester) async {
      const customScale = 0.8;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapAnimation(
              onTap: () {},
              scale: customScale,
              child: testChild,
            ),
          ),
        ),
      );

      final tapAnimation = tester.widget<TapAnimation>(
        find.byType(TapAnimation),
      );
      expect(tapAnimation.scale, equals(customScale));
    });

    testWidgets('has gesture detector for tap handling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TapAnimation(onTap: () {}, child: testChild)),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('has animated builder for scale animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TapAnimation(onTap: () {}, child: testChild)),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);
      expect(find.byType(Transform), findsOneWidget);
    });
  });

  group('PulseAnimation Widget Tests', () {
    const testChild = Text('Pulsing');

    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PulseAnimation(child: testChild)),
        ),
      );

      expect(find.text('Pulsing'), findsOneWidget);
      expect(find.byType(PulseAnimation), findsOneWidget);
    });

    testWidgets('uses default parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PulseAnimation(child: testChild)),
        ),
      );

      final pulseAnimation = tester.widget<PulseAnimation>(
        find.byType(PulseAnimation),
      );
      expect(pulseAnimation.duration, equals(const Duration(seconds: 1)));
      expect(pulseAnimation.minScale, equals(0.95));
      expect(pulseAnimation.maxScale, equals(1.05));
      expect(pulseAnimation.curve, equals(Curves.easeInOut));
    });

    testWidgets('uses custom parameters', (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 500);
      const customMinScale = 0.9;
      const customMaxScale = 1.1;
      const customCurve = Curves.bounceIn;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulseAnimation(
              duration: customDuration,
              minScale: customMinScale,
              maxScale: customMaxScale,
              curve: customCurve,
              child: testChild,
            ),
          ),
        ),
      );

      final pulseAnimation = tester.widget<PulseAnimation>(
        find.byType(PulseAnimation),
      );
      expect(pulseAnimation.duration, equals(customDuration));
      expect(pulseAnimation.minScale, equals(customMinScale));
      expect(pulseAnimation.maxScale, equals(customMaxScale));
      expect(pulseAnimation.curve, equals(customCurve));
    });

    testWidgets('has animated builder for pulse animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PulseAnimation(child: testChild)),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);
      expect(find.byType(Transform), findsOneWidget);
    });
  });

  group('ShakeAnimation Widget Tests', () {
    const testChild = Text('Shaking');

    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShakeAnimation(child: testChild)),
        ),
      );

      expect(find.text('Shaking'), findsOneWidget);
      expect(find.byType(ShakeAnimation), findsOneWidget);
    });

    testWidgets('uses default parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShakeAnimation(child: testChild)),
        ),
      );

      final shakeAnimation = tester.widget<ShakeAnimation>(
        find.byType(ShakeAnimation),
      );
      expect(
        shakeAnimation.duration,
        equals(const Duration(milliseconds: 500)),
      );
      expect(shakeAnimation.shakeCount, equals(3));
      expect(shakeAnimation.shakeOffset, equals(10.0));
    });

    testWidgets('uses custom parameters', (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 300);
      const customShakeCount = 5;
      const customShakeOffset = 15.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShakeAnimation(
              duration: customDuration,
              shakeCount: customShakeCount,
              shakeOffset: customShakeOffset,
              child: testChild,
            ),
          ),
        ),
      );

      final shakeAnimation = tester.widget<ShakeAnimation>(
        find.byType(ShakeAnimation),
      );
      expect(shakeAnimation.duration, equals(customDuration));
      expect(shakeAnimation.shakeCount, equals(customShakeCount));
      expect(shakeAnimation.shakeOffset, equals(customShakeOffset));
    });

    testWidgets('has animated builder for shake animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShakeAnimation(child: testChild)),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);
      expect(find.byType(Transform), findsOneWidget);
    });
  });

  group('FadeInAnimation Widget Tests', () {
    const testChild = Text('Fading In');

    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FadeInAnimation(child: testChild)),
        ),
      );

      // Wait for animation to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Fading In'), findsOneWidget);
      expect(find.byType(FadeInAnimation), findsOneWidget);
    });

    testWidgets('uses default parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FadeInAnimation(child: testChild)),
        ),
      );

      final fadeInAnimation = tester.widget<FadeInAnimation>(
        find.byType(FadeInAnimation),
      );
      expect(
        fadeInAnimation.duration,
        equals(const Duration(milliseconds: 500)),
      );
      expect(fadeInAnimation.delay, equals(Duration.zero));
      expect(fadeInAnimation.curve, equals(Curves.easeIn));
    });

    testWidgets('uses custom parameters', (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 300);
      const customDelay = Duration(milliseconds: 100);
      const customCurve = Curves.bounceIn;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInAnimation(
              duration: customDuration,
              delay: customDelay,
              curve: customCurve,
              child: testChild,
            ),
          ),
        ),
      );

      final fadeInAnimation = tester.widget<FadeInAnimation>(
        find.byType(FadeInAnimation),
      );
      expect(fadeInAnimation.duration, equals(customDuration));
      expect(fadeInAnimation.delay, equals(customDelay));
      expect(fadeInAnimation.curve, equals(customCurve));
    });

    testWidgets('has fade transition', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FadeInAnimation(child: testChild)),
        ),
      );

      expect(find.byType(FadeTransition), findsOneWidget);
    });
  });

  group('SlideInAnimation Widget Tests', () {
    const testChild = Text('Sliding In');

    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SlideInAnimation(child: testChild)),
        ),
      );

      // Wait for animation to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sliding In'), findsOneWidget);
      expect(find.byType(SlideInAnimation), findsOneWidget);
    });

    testWidgets('uses default parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SlideInAnimation(child: testChild)),
        ),
      );

      final slideInAnimation = tester.widget<SlideInAnimation>(
        find.byType(SlideInAnimation),
      );
      expect(
        slideInAnimation.duration,
        equals(const Duration(milliseconds: 500)),
      );
      expect(slideInAnimation.delay, equals(Duration.zero));
      expect(slideInAnimation.direction, equals(SlideDirection.fromBottom));
      expect(slideInAnimation.offset, equals(50.0));
      expect(slideInAnimation.curve, equals(Curves.easeOutCubic));
    });

    testWidgets('uses custom parameters', (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 300);
      const customDelay = Duration(milliseconds: 100);
      const customDirection = SlideDirection.fromLeft;
      const customOffset = 100.0;
      const customCurve = Curves.bounceIn;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SlideInAnimation(
              duration: customDuration,
              delay: customDelay,
              direction: customDirection,
              offset: customOffset,
              curve: customCurve,
              child: testChild,
            ),
          ),
        ),
      );

      final slideInAnimation = tester.widget<SlideInAnimation>(
        find.byType(SlideInAnimation),
      );
      expect(slideInAnimation.duration, equals(customDuration));
      expect(slideInAnimation.delay, equals(customDelay));
      expect(slideInAnimation.direction, equals(customDirection));
      expect(slideInAnimation.offset, equals(customOffset));
      expect(slideInAnimation.curve, equals(customCurve));
    });

    testWidgets('has animated builder for slide animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SlideInAnimation(child: testChild)),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);
      expect(find.byType(Transform), findsOneWidget);
    });

    testWidgets('supports all slide directions', (WidgetTester tester) async {
      for (final direction in SlideDirection.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlideInAnimation(direction: direction, child: testChild),
            ),
          ),
        );

        final slideInAnimation = tester.widget<SlideInAnimation>(
          find.byType(SlideInAnimation),
        );
        expect(slideInAnimation.direction, equals(direction));

        // Clear the widget tree for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });

  group('SlideDirection Enum Tests', () {
    test('has all expected values', () {
      expect(SlideDirection.values, hasLength(4));
      expect(SlideDirection.values, contains(SlideDirection.fromLeft));
      expect(SlideDirection.values, contains(SlideDirection.fromRight));
      expect(SlideDirection.values, contains(SlideDirection.fromTop));
      expect(SlideDirection.values, contains(SlideDirection.fromBottom));
    });
  });
}
