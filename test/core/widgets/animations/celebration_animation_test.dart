import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/animations/celebration_animation.dart';

void main() {
  group('CelebrationAnimation Widget Tests', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationAnimation(),
          ),
        ),
      );

      expect(find.byType(CelebrationAnimation), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('uses default parameters correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationAnimation(),
          ),
        ),
      );

      final celebrationAnimation = tester.widget<CelebrationAnimation>(
        find.byType(CelebrationAnimation),
      );

      expect(celebrationAnimation.duration, equals(const Duration(seconds: 3)));
      expect(celebrationAnimation.particleCount, equals(50));
      expect(celebrationAnimation.colors.length, equals(6));
    });

    testWidgets('accepts custom parameters', (WidgetTester tester) async {
      const customDuration = Duration(seconds: 5);
      const customParticleCount = 100;
      const customColors = [Colors.red, Colors.blue];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationAnimation(
              duration: customDuration,
              particleCount: customParticleCount,
              colors: customColors,
            ),
          ),
        ),
      );

      final celebrationAnimation = tester.widget<CelebrationAnimation>(
        find.byType(CelebrationAnimation),
      );

      expect(celebrationAnimation.duration, equals(customDuration));
      expect(celebrationAnimation.particleCount, equals(customParticleCount));
      expect(celebrationAnimation.colors, equals(customColors));
    });

    testWidgets('animation controller starts automatically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationAnimation(),
          ),
        ),
      );

      // Pump a few frames to let animation start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Animation should be running
      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });

    testWidgets('custom paint has infinite size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelebrationAnimation(),
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      expect(customPaint.size, equals(Size.infinite));
    });
  });

  group('GoalAchievementDialog Widget Tests', () {
    const testTitle = 'Test Achievement!';
    const testMessage = 'You did great!';

    testWidgets('renders with default content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoalAchievementDialog(),
          ),
        ),
      );

      expect(find.text('Goal Achieved!'), findsOneWidget);
      expect(find.text('Congratulations on reaching your hydration goal!'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('renders with custom content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoalAchievementDialog(
              title: testTitle,
              message: testMessage,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('calls onContinue when continue button is pressed', (WidgetTester tester) async {
      var wasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalAchievementDialog(
              onContinue: () => wasCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(wasCalled, isTrue);
    });

    testWidgets('has celebration animation in background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoalAchievementDialog(),
          ),
        ),
      );

      expect(find.byType(CelebrationAnimation), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('has correct dialog structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoalAchievementDialog(),
          ),
        ),
      );

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('trophy icon is animated', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoalAchievementDialog(),
          ),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('continue button spans full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoalAchievementDialog(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, equals(double.infinity));
    });
  });

  group('showGoalAchievementDialog Function Tests', () {
    testWidgets('shows dialog with default parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showGoalAchievementDialog(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Goal Achieved!'), findsOneWidget);
      expect(find.text('Congratulations on reaching your hydration goal!'), findsOneWidget);
    });

    testWidgets('shows dialog with custom parameters', (WidgetTester tester) async {
      const customTitle = 'Custom Achievement!';
      const customMessage = 'Custom message here!';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showGoalAchievementDialog(
                  context,
                  title: customTitle,
                  message: customMessage,
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text(customTitle), findsOneWidget);
      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('dialog is not dismissible by barrier', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showGoalAchievementDialog(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to dismiss by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be visible
      expect(find.text('Goal Achieved!'), findsOneWidget);
    });

    testWidgets('dialog closes when continue is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showGoalAchievementDialog(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Goal Achieved!'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Goal Achieved!'), findsNothing);
    });
  });
}