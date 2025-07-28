import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_progress_indicator.dart';

void main() {
  group('OnboardingProgressIndicator Tests', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
            ),
          ),
        ),
      );

      expect(find.byType(OnboardingProgressIndicator), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('shows step numbers when showStepNumbers is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
            ),
          ),
        ),
      );

      expect(find.text('Step 3 of 5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('hides step numbers when showStepNumbers is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
              showStepNumbers: false,
            ),
          ),
        ),
      );

      expect(find.text('Step 3 of 5'), findsNothing);
      expect(find.text('60%'), findsNothing);
    });

    testWidgets('calculates progress percentage correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 1,
              totalSteps: 4,
            ),
          ),
        ),
      );

      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('applies custom height', (WidgetTester tester) async {
      const customHeight = 8.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
              height: customHeight,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<OnboardingProgressIndicator>(
        find.byType(OnboardingProgressIndicator),
      );
      expect(progressIndicator.height, equals(customHeight));
    });

    testWidgets('uses custom colors when provided', (WidgetTester tester) async {
      const customBackgroundColor = Colors.red;
      const customProgressColor = Colors.blue;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
              backgroundColor: customBackgroundColor,
              progressColor: customProgressColor,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<OnboardingProgressIndicator>(
        find.byType(OnboardingProgressIndicator),
      );
      expect(progressIndicator.backgroundColor, equals(customBackgroundColor));
      expect(progressIndicator.progressColor, equals(customProgressColor));
    });

    testWidgets('shows correct progress for first step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 0,
              totalSteps: 3,
            ),
          ),
        ),
      );

      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('33%'), findsOneWidget);
    });

    testWidgets('shows correct progress for last step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 3,
            ),
          ),
        ),
      );

      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('AnimatedOnboardingProgressIndicator Tests', () {
    testWidgets('renders with animation controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedOnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedOnboardingProgressIndicator), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });

    testWidgets('shows step numbers when showStepNumbers is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedOnboardingProgressIndicator(
              currentStep: 1,
              totalSteps: 4,
            ),
          ),
        ),
      );

      expect(find.text('Step 2 of 4'), findsOneWidget);
    });

    testWidgets('hides step numbers when showStepNumbers is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedOnboardingProgressIndicator(
              currentStep: 1,
              totalSteps: 4,
              showStepNumbers: false,
            ),
          ),
        ),
      );

      expect(find.text('Step 2 of 4'), findsNothing);
    });

    testWidgets('applies custom animation duration', (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 500);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedOnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
              animationDuration: customDuration,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<AnimatedOnboardingProgressIndicator>(
        find.byType(AnimatedOnboardingProgressIndicator),
      );
      expect(progressIndicator.animationDuration, equals(customDuration));
    });

    testWidgets('updates animation when currentStep changes', (WidgetTester tester) async {
      var currentStep = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    AnimatedOnboardingProgressIndicator(
                      currentStep: currentStep,
                      totalSteps: 3,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentStep = 1;
                        });
                      },
                      child: const Text('Next Step'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially at step 1
      expect(find.text('Step 1 of 3'), findsOneWidget);

      // Tap to go to next step
      await tester.tap(find.text('Next Step'));
      await tester.pump();

      // Should now show step 2
      expect(find.text('Step 2 of 3'), findsOneWidget);
    });

    testWidgets('disposes animation controller properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedOnboardingProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
            ),
          ),
        ),
      );

      // Remove the widget to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });
  });

  group('StepProgressIndicator Tests', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 1,
              totalSteps: 3,
            ),
          ),
        ),
      );

      expect(find.byType(StepProgressIndicator), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('shows correct number of step circles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 1,
              totalSteps: 4,
            ),
          ),
        ),
      );

      // Should have 4 containers for 4 steps
      final containers = tester.widgetList<Container>(find.byType(Container));
      final stepContainers = containers.where((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.shape == BoxShape.circle;
      });
      expect(stepContainers.length, equals(4));
    });

    testWidgets('shows check icon for completed steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 2,
              totalSteps: 4,
              completedSteps: {0, 1},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });

    testWidgets('shows step numbers for incomplete steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 1,
              totalSteps: 3,
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('applies custom step size', (WidgetTester tester) async {
      const customStepSize = 32.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 1,
              totalSteps: 3,
              stepSize: customStepSize,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<StepProgressIndicator>(
        find.byType(StepProgressIndicator),
      );
      expect(progressIndicator.stepSize, equals(customStepSize));
    });

    testWidgets('shows labels when provided and showLabels is true', (WidgetTester tester) async {
      const labels = ['Start', 'Middle', 'End'];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 1,
              totalSteps: 3,
              showLabels: true,
              labels: labels,
            ),
          ),
        ),
      );

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Middle'), findsOneWidget);
      expect(find.text('End'), findsOneWidget);
    });

    testWidgets('hides labels when showLabels is false', (WidgetTester tester) async {
      const labels = ['Start', 'Middle', 'End'];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 1,
              totalSteps: 3,
              labels: labels,
            ),
          ),
        ),
      );

      expect(find.text('Start'), findsNothing);
      expect(find.text('Middle'), findsNothing);
      expect(find.text('End'), findsNothing);
    });

    testWidgets('uses custom colors when provided', (WidgetTester tester) async {
      const customCompletedColor = Colors.green;
      const customActiveColor = Colors.blue;
      const customInactiveColor = Colors.grey;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepProgressIndicator(
              currentStep: 1,
              totalSteps: 3,
              completedColor: customCompletedColor,
              activeColor: customActiveColor,
              inactiveColor: customInactiveColor,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<StepProgressIndicator>(
        find.byType(StepProgressIndicator),
      );
      expect(progressIndicator.completedColor, equals(customCompletedColor));
      expect(progressIndicator.activeColor, equals(customActiveColor));
      expect(progressIndicator.inactiveColor, equals(customInactiveColor));
    });
  });
}
