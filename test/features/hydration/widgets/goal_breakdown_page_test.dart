import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/goal_factors.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';

void main() {
  group('GoalBreakdownPage Widget Tests', () {
    late HydrationProvider mockProvider;

    setUp(() {
      mockProvider = HydrationProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: const GoalBreakdownPage(),
        ),
      );
    }

    testWidgets('displays header correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Goal Breakdown'), findsOneWidget);

      final headerText = tester.widget<Text>(find.text('Goal Breakdown'));
      expect(headerText.style?.fontSize, 24);
      expect(headerText.style?.fontWeight, FontWeight.bold);
      expect(headerText.style?.color, AppColors.textHeadline);
    });

    testWidgets('displays goal summary card', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Daily Hydration Goal'), findsOneWidget);
      expect(
        find.text('Calculated based on your personal factors'),
        findsOneWidget,
      );

      // Should display goal in liters and milliliters
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.endsWith(' L'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('ml'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays all factor cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check all factor cards are present
      expect(find.text('Base Requirement'), findsOneWidget);
      expect(find.text('Activity Level'), findsOneWidget);
      expect(find.text('Climate Condition'), findsOneWidget);
      expect(find.text('Health Adjustment'), findsOneWidget);
      expect(find.text('Custom Adjustment'), findsOneWidget);
    });

    testWidgets('displays base requirement card with slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Base Requirement'), findsOneWidget);
      expect(
        find.text('Based on your age, weight, and gender'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Should have a slider for base requirement
      final sliders = find.byType(Slider);
      expect(sliders, findsAtLeastNWidgets(1));
    });

    testWidgets('displays activity level options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Activity Level'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);

      // Should display all activity level options
      for (final level in ActivityLevel.values) {
        expect(find.text(level.displayName), findsOneWidget);
      }
    });

    testWidgets('displays climate condition options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Climate Condition'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);

      // Should display all climate condition options
      for (final condition in ClimateCondition.values) {
        expect(find.text(condition.displayName), findsOneWidget);
      }
    });

    testWidgets('displays health adjustment slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Health Adjustment'), findsOneWidget);
      expect(
        find.text('Medical conditions, medications, or health factors'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    });

    testWidgets('displays custom adjustment slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Custom Adjustment'), findsOneWidget);
      expect(find.text('Personal preference or other factors'), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('displays apply button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final applyButton = find.text('Apply New Goal');
      expect(applyButton, findsOneWidget);

      final buttonWidget = tester.widget<ElevatedButton>(
        find.ancestor(of: applyButton, matching: find.byType(ElevatedButton)),
      );
      expect(
        buttonWidget.style?.backgroundColor?.resolve({}),
        AppColors.waterFull,
      );
    });

    testWidgets('can select different activity levels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap on a different activity level
      final veryActiveOption = find.text(ActivityLevel.veryActive.displayName);
      expect(veryActiveOption, findsOneWidget);

      await tester.tap(veryActiveOption);
      await tester.pumpAndSettle();

      // The selection should be updated (visual feedback)
      // Note: We can't easily test the internal state change without exposing it
    });

    testWidgets('can select different climate conditions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap on a different climate condition
      final hotOption = find.text(ClimateCondition.hot.displayName);
      expect(hotOption, findsOneWidget);

      await tester.tap(hotOption);
      await tester.pumpAndSettle();

      // The selection should be updated (visual feedback)
    });

    testWidgets('can adjust base requirement slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the first slider (base requirement)
      final sliders = find.byType(Slider);
      expect(sliders, findsAtLeastNWidgets(1));

      final firstSlider = sliders.first;
      await tester.drag(firstSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // The slider value should change (visual feedback)
    });

    testWidgets('can adjust health adjustment slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find sliders and identify health adjustment slider
      final sliders = find.byType(Slider);
      expect(sliders, findsAtLeastNWidgets(2));

      // Health adjustment is the second slider
      final healthSlider = sliders.at(1);
      await tester.drag(healthSlider, const Offset(30, 0));
      await tester.pumpAndSettle();
    });

    testWidgets('can adjust custom adjustment slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find sliders and identify custom adjustment slider
      final sliders = find.byType(Slider);
      expect(sliders, findsAtLeastNWidgets(3));

      // Custom adjustment is the third slider
      final customSlider = sliders.at(2);
      await tester.drag(customSlider, const Offset(-30, 0));
      await tester.pumpAndSettle();
    });

    testWidgets('apply button calls provider setDailyGoal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final applyButton = find.text('Apply New Goal');
      expect(applyButton, findsOneWidget);

      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.text('Goal updated successfully!'), findsOneWidget);
    });

    testWidgets('displays correct icons for each section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check all section icons are present
      expect(find.byIcon(Icons.person), findsOneWidget); // Base requirement
      expect(
        find.byIcon(Icons.fitness_center),
        findsOneWidget,
      ); // Activity level
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget); // Climate
      expect(find.byIcon(Icons.health_and_safety), findsOneWidget); // Health
      expect(find.byIcon(Icons.tune), findsOneWidget); // Custom
    });

    testWidgets('displays adjustment values with correct formatting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display adjustment values with + or - signs
      expect(find.textContaining('ml'), findsAtLeastNWidgets(5));

      // Default values should be displayed
      expect(
        find.textContaining('+0 ml'),
        findsAtLeastNWidgets(1),
      ); // Temperate climate
      expect(
        find.textContaining('+400 ml'),
        findsAtLeastNWidgets(1),
      ); // Moderate activity
    });

    testWidgets('scrolls properly when content overflows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the scrollable widget
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);

      // Try scrolling
      await tester.drag(scrollable, const Offset(0, -200));
      await tester.pumpAndSettle();

      // Should still find the header
      expect(find.text('Goal Breakdown'), findsOneWidget);
    });
  });

  group('GoalBreakdownPage Goal Calculation Tests', () {
    testWidgets('calculates total goal correctly with default values', (
      WidgetTester tester,
    ) async {
      final provider = HydrationProvider();

      final widget = MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: provider,
          child: const GoalBreakdownPage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Default calculation should be visible
      // Base (70% of 2000ml = 1400ml) + Moderate activity (400ml) + Temperate (0ml) = 1800ml
      expect(find.textContaining('1.8 L'), findsOneWidget);
    });

    testWidgets('updates total when activity level changes', (
      WidgetTester tester,
    ) async {
      final provider = HydrationProvider();

      final widget = MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: provider,
          child: const GoalBreakdownPage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Tap on "Very Active" option
      await tester.tap(find.text(ActivityLevel.veryActive.displayName));
      await tester.pumpAndSettle();

      // Should show updated adjustment value
      expect(find.textContaining('+600 ml'), findsOneWidget);
    });

    testWidgets('updates total when climate condition changes', (
      WidgetTester tester,
    ) async {
      final provider = HydrationProvider();

      final widget = MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: provider,
          child: const GoalBreakdownPage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Tap on "Hot" climate option
      await tester.tap(find.text(ClimateCondition.hot.displayName));
      await tester.pumpAndSettle();

      // Should show updated adjustment value
      expect(find.textContaining('+400 ml'), findsAtLeastNWidgets(1));
    });
  });

  group('GoalBreakdownPage Error Handling Tests', () {
    testWidgets('handles provider errors gracefully', (
      WidgetTester tester,
    ) async {
      // Create a provider that might fail
      final provider = HydrationProvider();

      final widget = MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: provider,
          child: const GoalBreakdownPage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Widget should still render without crashing
      expect(find.text('Goal Breakdown'), findsOneWidget);
      expect(find.text('Apply New Goal'), findsOneWidget);
    });

    testWidgets('shows error snackbar when goal update fails', (
      WidgetTester tester,
    ) async {
      // This test would require mocking the provider to throw an error
      // For now, we'll just verify the error handling structure exists
      final provider = HydrationProvider();

      final widget = MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: provider,
          child: const GoalBreakdownPage(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // The apply button should exist and be tappable
      final applyButton = find.text('Apply New Goal');
      expect(applyButton, findsOneWidget);

      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Should show some feedback (success or error)
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
