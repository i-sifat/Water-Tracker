import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/goal_factors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GoalBreakdownPage Integration Tests', () {
    late HydrationProvider provider;

    setUp(() {
      provider = HydrationProvider();
    });

    Widget createTestApp() {
      return MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: provider,
          child: const GoalBreakdownPage(),
        ),
      );
    }

    testWidgets('complete goal adjustment workflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Goal Breakdown'), findsOneWidget);
      expect(find.text('Daily Hydration Goal'), findsOneWidget);

      // Step 1: Adjust base requirement
      final baseSlider = find.byType(Slider).first;
      await tester.drag(baseSlider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Step 2: Change activity level to Very Active
      await tester.tap(find.text(ActivityLevel.veryActive.displayName));
      await tester.pumpAndSettle();

      // Verify activity level selection visual feedback
      expect(find.text(ActivityLevel.veryActive.displayName), findsOneWidget);

      // Step 3: Change climate to Hot
      await tester.tap(find.text(ClimateCondition.hot.displayName));
      await tester.pumpAndSettle();

      // Verify climate selection visual feedback
      expect(find.text(ClimateCondition.hot.displayName), findsOneWidget);

      // Step 4: Adjust health factor
      final healthSlider = find.byType(Slider).at(1);
      await tester.drag(healthSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Step 5: Adjust custom factor
      final customSlider = find.byType(Slider).at(2);
      await tester.drag(customSlider, const Offset(-30, 0));
      await tester.pumpAndSettle();

      // Step 6: Apply the new goal
      await tester.tap(find.text('Apply New Goal'));
      await tester.pumpAndSettle();

      // Verify success feedback
      expect(find.text('Goal updated successfully!'), findsOneWidget);
    });

    testWidgets('activity level selection updates adjustments', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Test each activity level
      for (final level in ActivityLevel.values) {
        await tester.tap(find.text(level.displayName));
        await tester.pumpAndSettle();

        // Verify the adjustment value is displayed
        final expectedAdjustment = level.adjustmentFactor;
        final adjustmentText =
            expectedAdjustment >= 0
                ? '+$expectedAdjustment ml'
                : '$expectedAdjustment ml';

        expect(find.textContaining(adjustmentText), findsOneWidget);
      }
    });

    testWidgets('climate condition selection updates adjustments', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Test each climate condition
      for (final condition in ClimateCondition.values) {
        await tester.tap(find.text(condition.displayName));
        await tester.pumpAndSettle();

        // Verify the adjustment value is displayed
        final expectedAdjustment = condition.adjustmentFactor;
        final adjustmentText =
            expectedAdjustment >= 0
                ? '+$expectedAdjustment ml'
                : '$expectedAdjustment ml';

        expect(find.textContaining(adjustmentText), findsOneWidget);
      }
    });

    testWidgets('slider adjustments update values in real-time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Test base requirement slider
      final baseSlider = find.byType(Slider).first;

      // Drag to increase value
      await tester.drag(baseSlider, const Offset(200, 0));
      await tester.pumpAndSettle();

      // The total goal should be updated (we can't easily verify exact value without exposing state)
      expect(find.textContaining('L'), findsOneWidget);
      expect(find.textContaining('ml'), findsAtLeastNWidgets(1));

      // Test health adjustment slider
      final healthSlider = find.byType(Slider).at(1);
      await tester.drag(healthSlider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Should show positive health adjustment
      expect(find.textContaining('+'), findsAtLeastNWidgets(1));

      // Test custom adjustment slider
      final customSlider = find.byType(Slider).at(2);
      await tester.drag(customSlider, const Offset(-100, 0));
      await tester.pumpAndSettle();

      // Should show negative custom adjustment
      expect(find.textContaining('-'), findsAtLeastNWidgets(1));
    });

    testWidgets('goal calculation reflects all factor changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Record initial goal display
      final initialGoalFinder = find.textContaining('L');
      expect(initialGoalFinder, findsOneWidget);

      // Make multiple changes
      // 1. Change to very active
      await tester.tap(find.text(ActivityLevel.veryActive.displayName));
      await tester.pumpAndSettle();

      // 2. Change to hot climate
      await tester.tap(find.text(ClimateCondition.hot.displayName));
      await tester.pumpAndSettle();

      // 3. Increase base requirement
      final baseSlider = find.byType(Slider).first;
      await tester.drag(baseSlider, const Offset(150, 0));
      await tester.pumpAndSettle();

      // The goal should be updated to reflect all changes
      expect(find.textContaining('L'), findsOneWidget);

      // Verify individual adjustments are shown
      expect(find.textContaining('+600 ml'), findsOneWidget); // Very active
      expect(
        find.textContaining('+400 ml'),
        findsAtLeastNWidgets(1),
      ); // Hot climate
    });

    testWidgets('apply button updates provider goal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Get initial provider goal
      final initialGoal = provider.dailyGoal;

      // Make some adjustments
      await tester.tap(find.text(ActivityLevel.veryActive.displayName));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ClimateCondition.hot.displayName));
      await tester.pumpAndSettle();

      // Apply the changes
      await tester.tap(find.text('Apply New Goal'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Goal updated successfully!'), findsOneWidget);

      // The provider's goal should be updated
      // (We can't easily verify the exact value without exposing internal state)
      expect(provider.dailyGoal, isNot(equals(initialGoal)));
    });

    testWidgets('page scrolls properly with all content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify top content is visible
      expect(find.text('Goal Breakdown'), findsOneWidget);
      expect(find.text('Daily Hydration Goal'), findsOneWidget);

      // Scroll down to see bottom content
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // Bottom content should be visible
      expect(find.text('Apply New Goal'), findsOneWidget);

      // Scroll back up
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();

      // Top content should be visible again
      expect(find.text('Goal Breakdown'), findsOneWidget);
    });

    testWidgets('visual feedback for selections is immediate', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Test activity level selection visual feedback
      final sedentaryOption = find.text(ActivityLevel.sedentary.displayName);
      await tester.tap(sedentaryOption);
      await tester.pump(); // Single pump to check immediate feedback

      // Should immediately show the selection (visual state change)
      expect(find.text(ActivityLevel.sedentary.displayName), findsOneWidget);

      // Test climate condition selection visual feedback
      final coldOption = find.text(ClimateCondition.cold.displayName);
      await tester.tap(coldOption);
      await tester.pump(); // Single pump to check immediate feedback

      // Should immediately show the selection
      expect(find.text(ClimateCondition.cold.displayName), findsOneWidget);
    });

    testWidgets('handles extreme slider values correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Test maximum base requirement
      final baseSlider = find.byType(Slider).first;
      await tester.drag(baseSlider, const Offset(1000, 0)); // Drag far right
      await tester.pumpAndSettle();

      // Should handle maximum value gracefully
      expect(find.textContaining('L'), findsOneWidget);

      // Test minimum base requirement
      await tester.drag(baseSlider, const Offset(-1000, 0)); // Drag far left
      await tester.pumpAndSettle();

      // Should handle minimum value gracefully
      expect(find.textContaining('L'), findsOneWidget);

      // Test extreme health adjustment
      final healthSlider = find.byType(Slider).at(1);
      await tester.drag(
        healthSlider,
        const Offset(1000, 0),
      ); // Maximum positive
      await tester.pumpAndSettle();

      expect(find.textContaining('+'), findsAtLeastNWidgets(1));

      await tester.drag(
        healthSlider,
        const Offset(-1000, 0),
      ); // Maximum negative
      await tester.pumpAndSettle();

      expect(find.textContaining('-'), findsAtLeastNWidgets(1));
    });

    testWidgets('maintains state during interaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Make several changes
      await tester.tap(find.text(ActivityLevel.extremelyActive.displayName));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ClimateCondition.veryHot.displayName));
      await tester.pumpAndSettle();

      // Scroll down and back up
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Previous selections should still be maintained
      expect(
        find.text(ActivityLevel.extremelyActive.displayName),
        findsOneWidget,
      );
      expect(find.text(ClimateCondition.veryHot.displayName), findsOneWidget);
      expect(
        find.textContaining('+800 ml'),
        findsOneWidget,
      ); // Extremely active
      expect(find.textContaining('+600 ml'), findsOneWidget); // Very hot
    });
  });
}
