import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';

void main() {
  group('CircularProgressSection Widget Tests', () {
    late HydrationProgress mockProgress;

    setUp(() {
      mockProgress = HydrationProgress(
        currentIntake: 1750, // 1.75L
        dailyGoal: 3000, // 3L
        todaysEntries: [
          HydrationData(
            id: '1',
            amount: 500,
            timestamp: DateTime.now(),
          ),
          HydrationData(
            id: '2',
            amount: 1250,
            timestamp: DateTime.now(),
          ),
        ],
        nextReminderTime: DateTime.now().add(const Duration(hours: 2)),
      );
    });

    testWidgets('should display circular progress section with all elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CircularProgressSection(progress: mockProgress)),
        ),
      );

      // Verify the widget is rendered
      expect(find.byType(CircularProgressSection), findsOneWidget);

      // Verify CustomPaint for circular progress is present (may be multiple)
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify page indicator dots are present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display correct progress text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CircularProgressSection(progress: mockProgress)),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify progress text is displayed
      expect(find.text('1.75 L drank so far'), findsOneWidget);
      expect(find.text('from a total of 3.0 L'), findsOneWidget);
    });

    testWidgets('should display remaining text with reminder time', (
      WidgetTester tester,
    ) async {
      final reminderTime = DateTime(2024, 1, 1, 16, 22); // 4:22 PM
      final progressWithReminder = mockProgress.copyWith(
        nextReminderTime: reminderTime,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularProgressSection(progress: progressWithReminder),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify remaining text with reminder time
      expect(
        find.textContaining('1250 ml left before 4:22 PM'),
        findsOneWidget,
      );
    });

    testWidgets('should display goal achieved message when goal is reached', (
      WidgetTester tester,
    ) async {
      final completedProgress = mockProgress.copyWith(
        currentIntake: 3000, // Equal to goal
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularProgressSection(progress: completedProgress),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify goal achieved message
      expect(find.text('Goal achieved!'), findsOneWidget);
    });

    testWidgets('should display correct number of page indicator dots', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularProgressSection(
              progress: mockProgress,
              totalPages: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Count page indicator dots (containers with circular decoration)
      final dotContainers =
          tester
              .widgetList<Container>(find.byType(Container))
              .where(
                (container) =>
                    container.decoration is BoxDecoration &&
                    (container.decoration! as BoxDecoration).shape ==
                        BoxShape.circle,
              )
              .toList();

      expect(dotContainers.length, equals(5));
    });

    testWidgets('should highlight current page in page indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularProgressSection(
              progress: mockProgress,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all dot containers
      final dotContainers =
          tester
              .widgetList<Container>(find.byType(Container))
              .where(
                (container) =>
                    container.decoration is BoxDecoration &&
                    (container.decoration! as BoxDecoration).shape ==
                        BoxShape.circle,
              )
              .toList();

      expect(dotContainers.length, equals(3));

      // Check that the second dot (index 1) has the active color
      final secondDot = dotContainers[1];
      final decoration = secondDot.decoration! as BoxDecoration;
      expect(
        decoration.color,
        equals(const Color(0xFF918DFE)),
      ); // AppColors.waterFull
    });

    testWidgets('should animate progress changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularProgressSection(
              progress: mockProgress,
              animationDuration: const Duration(milliseconds: 100),
            ),
          ),
        ),
      );

      // Initial state
      await tester.pump();

      // Animation should be in progress
      await tester.pump(const Duration(milliseconds: 50));

      // Animation should complete
      await tester.pumpAndSettle();

      // Verify the widget is still present after animation
      expect(find.byType(CircularProgressSection), findsOneWidget);
    });

    testWidgets('should update animation when progress changes', (
      WidgetTester tester,
    ) async {
      // Create a StatefulWidget wrapper to test progress updates
      await tester.pumpWidget(
        MaterialApp(home: _TestProgressWrapper(initialProgress: mockProgress)),
      );

      await tester.pumpAndSettle();

      // Verify initial progress text
      expect(find.text('1.75 L drank so far'), findsOneWidget);

      // Tap button to update progress
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify updated progress text
      expect(find.text('2.25 L drank so far'), findsOneWidget);
    });

    testWidgets('should handle zero progress correctly', (
      WidgetTester tester,
    ) async {
      const zeroProgress = HydrationProgress(
        currentIntake: 0,
        dailyGoal: 3000,
        todaysEntries: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularProgressSection(progress: zeroProgress)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify zero progress display
      expect(find.text('0.00 L drank so far'), findsOneWidget);
      expect(find.text('from a total of 3.0 L'), findsOneWidget);
      expect(find.text('3000 ml remaining'), findsOneWidget);
    });

    testWidgets('should handle progress over 100% correctly', (
      WidgetTester tester,
    ) async {
      final overProgress = HydrationProgress(
        currentIntake: 4000, // Over the 3000ml goal
        dailyGoal: 3000,
        todaysEntries: [
          HydrationData(
            id: '1',
            amount: 4000,
            timestamp: DateTime.now(),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CircularProgressSection(progress: overProgress)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify over-goal progress display
      expect(find.text('4.00 L drank so far'), findsOneWidget);
      expect(find.text('Goal achieved!'), findsOneWidget);
    });

    testWidgets('should have proper accessibility semantics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CircularProgressSection(progress: mockProgress)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify text widgets are accessible
      expect(find.text('1.75 L drank so far'), findsOneWidget);
      expect(find.text('from a total of 3.0 L'), findsOneWidget);

      // Verify the widget structure supports screen readers
      final progressText = tester.widget<Text>(
        find.text('1.75 L drank so far'),
      );
      expect(progressText.textAlign, equals(TextAlign.center));
    });
  });
}

/// Test wrapper widget to simulate progress updates
class _TestProgressWrapper extends StatefulWidget {
  const _TestProgressWrapper({required this.initialProgress});

  final HydrationProgress initialProgress;

  @override
  State<_TestProgressWrapper> createState() => _TestProgressWrapperState();
}

class _TestProgressWrapperState extends State<_TestProgressWrapper> {
  late HydrationProgress progress;

  @override
  void initState() {
    super.initState();
    progress = widget.initialProgress;
  }

  void _updateProgress() {
    setState(() {
      progress = progress.copyWith(currentIntake: 2250); // 2.25L
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CircularProgressSection(
            progress: progress,
            animationDuration: const Duration(milliseconds: 100),
          ),
          ElevatedButton(
            onPressed: _updateProgress,
            child: const Text('Update Progress'),
          ),
        ],
      ),
    );
  }
}
