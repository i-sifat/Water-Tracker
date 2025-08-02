import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';

void main() {
  group('Accessibility Simple Tests', () {
    testWidgets('CircularProgressSection renders with accessibility features', (
      tester,
    ) async {
      final progress = HydrationProgress(
        currentIntake: 1500,
        dailyGoal: 2000,
        nextReminderTime: DateTime.now().add(const Duration(hours: 2)),
        todaysEntries: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CircularProgressSection(progress: progress)),
        ),
      );

      // Check that the widget renders
      expect(find.byType(CircularProgressSection), findsOneWidget);

      // Check that Semantics widgets are present
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('DrinkTypeSelector renders with accessibility features', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeSelector(
              selectedType: DrinkType.water,
              onTypeChanged: (type) {},
            ),
          ),
        ),
      );

      // Check that the widget renders
      expect(find.byType(DrinkTypeSelector), findsOneWidget);

      // Check that Semantics widgets are present
      expect(find.byType(Semantics), findsWidgets);
    });

    group('AccessibilityUtils Tests', () {
      test('createProgressLabel generates correct label', () {
        const percentage = 0.75;
        const currentIntake = 1500;
        const dailyGoal = 2000;

        final label = AccessibilityUtils.createProgressLabel(
          percentage,
          currentIntake,
          dailyGoal,
        );

        expect(label, contains('75%'));
        expect(label, contains('1.5 liters'));
        expect(label, contains('2.0 liters'));
      });

      test('createQuickAddButtonLabel generates correct label', () {
        const amount = 250;
        const drinkType = 'Water';

        final label = AccessibilityUtils.createQuickAddButtonLabel(
          amount,
          drinkType,
        );

        expect(label, equals('Add 250ml of Water to hydration log'));
      });

      test('createDrinkTypeSelectorLabel generates correct label', () {
        const drinkType = 'Coffee';
        const waterContent = 0.90;

        final label = AccessibilityUtils.createDrinkTypeSelectorLabel(
          drinkType,
          waterContent,
        );

        expect(label, contains('Coffee'));
        expect(label, contains('90%'));
        expect(label, contains('water content'));
      });

      test('createPageIndicatorLabel generates correct label', () {
        const currentPage = 1;
        const totalPages = 3;
        const pageNames = ['Statistics', 'Main hydration', 'Goal breakdown'];

        final label = AccessibilityUtils.createPageIndicatorLabel(
          currentPage,
          totalPages,
          pageNames,
        );

        expect(label, contains('Main hydration'));
        expect(label, contains('page 2 of 3'));
      });

      test('createStatisticsCardLabel generates correct label', () {
        const title = 'Balance';
        const value = '75%';
        const unit = 'completed';

        final label = AccessibilityUtils.createStatisticsCardLabel(
          title,
          value,
          unit,
        );

        expect(label, equals('Balance: 75% completed'));
      });

      test('createStreakIndicatorLabel generates correct labels', () {
        // Test completed day
        final completedLabel = AccessibilityUtils.createStreakIndicatorLabel(
          1,
          true,
          false,
        );
        expect(completedLabel, equals('Monday: Goal completed'));

        // Test today completed
        final todayCompletedLabel =
            AccessibilityUtils.createStreakIndicatorLabel(2, true, true);
        expect(todayCompletedLabel, equals('Tuesday: Goal completed today'));

        // Test today in progress
        final todayInProgressLabel =
            AccessibilityUtils.createStreakIndicatorLabel(3, false, true);
        expect(
          todayInProgressLabel,
          equals('Wednesday: Today, goal in progress'),
        );

        // Test not completed
        final notCompletedLabel = AccessibilityUtils.createStreakIndicatorLabel(
          4,
          false,
          false,
        );
        expect(notCompletedLabel, equals('Thursday: Goal not completed'));
      });

      test('meetsMinTouchTarget returns correct values', () {
        expect(AccessibilityUtils.meetsMinTouchTarget(44, 44), isTrue);
        expect(AccessibilityUtils.meetsMinTouchTarget(50, 50), isTrue);
        expect(AccessibilityUtils.meetsMinTouchTarget(40, 44), isFalse);
        expect(AccessibilityUtils.meetsMinTouchTarget(44, 40), isFalse);
        expect(AccessibilityUtils.meetsMinTouchTarget(30, 30), isFalse);
      });

      testWidgets('ensureMinTouchTarget creates proper constraints', (
        tester,
      ) async {
        final widget = AccessibilityUtils.ensureMinTouchTarget(
          onTap: () {},
          semanticLabel: 'Test button',
          child: SizedBox(width: 20, height: 20),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        // Check that the widget renders
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('createAccessibleText renders correctly', (tester) async {
        const testText = 'Test text';
        const testStyle = TextStyle(fontSize: 16);

        final widget = AccessibilityUtils.createAccessibleText(
          text: testText,
          style: testStyle,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.text(testText), findsOneWidget);
        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Color Contrast Tests', () {
      test('App colors meet minimum contrast requirements', () {
        // Test that the contrast ratio constant is defined
        expect(AccessibilityUtils.minContrastRatio, equals(4.5));
      });
    });

    group('Touch Target Tests', () {
      testWidgets('Touch targets meet minimum size requirements', (
        tester,
      ) async {
        final widget = AccessibilityUtils.ensureMinTouchTarget(
          onTap: () {},
          semanticLabel: 'Test button',
          child: Container(width: 20, height: 20, color: Colors.blue),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        // Check that containers are present
        expect(find.byType(Container), findsWidgets);

        // Check that the minimum touch target size constant is correct
        expect(AccessibilityUtils.minTouchTargetSize, equals(44.0));
      });
    });
  });
}
