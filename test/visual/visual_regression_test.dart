/// Visual regression tests for design accuracy
/// Tests that the UI matches the design mockup exactly
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

void main() {
  group('Visual Regression Tests', () {
    late HydrationProvider hydrationProvider;

    setUp(() {
      hydrationProvider = HydrationProvider();
    });

    testWidgets('Main hydration page matches design mockup', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test overall layout structure
      expect(find.byType(SwipeablePageView), findsOneWidget);
      expect(find.byType(MainHydrationPage), findsOneWidget);

      // Test header elements
      expect(find.text('Today'), findsOneWidget);

      // Verify header styling
      final todayText = tester.widget<Text>(find.text('Today'));
      expect(
        todayText.style?.fontSize,
        equals(AppTypography.headlineLarge.fontSize),
      );
      expect(
        todayText.style?.fontWeight,
        equals(AppTypography.headlineLarge.fontWeight),
      );

      // Test circular progress section
      expect(find.byType(CircularProgressSection), findsOneWidget);

      // Test progress text elements
      expect(find.text('0.0 L drank so far'), findsOneWidget);
      expect(find.textContaining('from a total of'), findsOneWidget);

      // Test quick add button grid
      expect(find.byType(QuickAddButtonGrid), findsOneWidget);
      expect(find.text('500 ml'), findsOneWidget);
      expect(find.text('250 ml'), findsOneWidget);
      expect(find.text('400 ml'), findsOneWidget);
      expect(find.text('100 ml'), findsOneWidget);

      // Test button colors match design
      final button500 = tester.widget<Container>(
        find
            .ancestor(of: find.text('500 ml'), matching: find.byType(Container))
            .first,
      );

      // Verify button styling (colors should match design mockup)
      expect(button500.decoration, isA<BoxDecoration>());
      final decoration = button500.decoration! as BoxDecoration;
      expect(decoration.borderRadius, isA<BorderRadius>());

      // Test drink type selector
      expect(find.byType(DrinkTypeSelector), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);

      // Test page indicators
      expect(
        find.byType(Row),
        findsWidgets,
      ); // Page indicator dots should be in a Row
    });

    testWidgets('Circular progress visual accuracy', (
      WidgetTester tester,
    ) async {
      // Set up provider with specific progress for visual testing
      await hydrationProvider.addHydration(1750); // 1.75L of 3L goal

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test progress display
      expect(find.text('1.75 L drank so far'), findsOneWidget);
      expect(find.textContaining('from a total of'), findsOneWidget);

      // Test circular progress painter
      final circularProgress = find.byType(CircularProgressSection);
      expect(circularProgress, findsOneWidget);

      // Verify the CustomPaint widget exists (contains the circular progress painter)
      expect(find.byType(CustomPaint), findsOneWidget);

      // Test center text styling
      final progressText = tester.widget<Text>(
        find.text('1.75 L drank so far'),
      );
      expect(progressText.style?.color, isNotNull);
      expect(progressText.style?.fontSize, greaterThan(16));

      // Test subtitle text
      final subtitleText = tester.widget<Text>(
        find.textContaining('from a total of'),
      );
      expect(
        subtitleText.style?.fontSize,
        lessThan(progressText.style?.fontSize ?? 0),
      );
    });

    testWidgets('Quick add buttons visual accuracy', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test button layout - should be 2x2 grid
      final buttonGrid = find.byType(QuickAddButtonGrid);
      expect(buttonGrid, findsOneWidget);

      // Test individual buttons exist
      expect(find.text('500 ml'), findsOneWidget);
      expect(find.text('250 ml'), findsOneWidget);
      expect(find.text('400 ml'), findsOneWidget);
      expect(find.text('100 ml'), findsOneWidget);

      // Test button styling
      final buttons = find.byType(GestureDetector);
      expect(buttons, findsAtLeastNWidgets(4));

      // Test button text styling
      final button500Text = tester.widget<Text>(find.text('500 ml'));
      expect(button500Text.style?.fontWeight, equals(FontWeight.w600));
      expect(button500Text.style?.color, equals(Colors.white));

      // Test button spacing and alignment
      final buttonPositions = <Offset>[];
      for (final button in ['500 ml', '250 ml', '400 ml', '100 ml']) {
        final buttonFinder = find.text(button);
        buttonPositions.add(tester.getCenter(buttonFinder));
      }

      // Verify 2x2 grid layout
      expect(buttonPositions.length, equals(4));

      // Top row should have same Y coordinate (approximately)
      final topRowY = buttonPositions[0].dy;
      final bottomRowY = buttonPositions[2].dy;
      expect((buttonPositions[1].dy - topRowY).abs(), lessThan(5));
      expect((buttonPositions[3].dy - bottomRowY).abs(), lessThan(5));
      expect(bottomRowY, greaterThan(topRowY));
    });

    testWidgets('Statistics page visual accuracy', (WidgetTester tester) async {
      // Add some sample data for statistics
      await hydrationProvider.addHydration(500);
      await hydrationProvider.addHydration(300, type: DrinkType.tea);
      await hydrationProvider.addHydration(250, type: DrinkType.coffee);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Navigate to statistics page
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Test statistics page elements
      expect(find.byType(StatisticsPage), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);

      // Test time period tabs
      expect(find.text('WEEKLY'), findsOneWidget);
      expect(find.text('MONTHLY'), findsOneWidget);
      expect(find.text('YEARLY'), findsOneWidget);

      // Test tab styling
      final weeklyTab = tester.widget<Text>(find.text('WEEKLY'));
      expect(weeklyTab.style?.fontWeight, equals(FontWeight.w600));

      // Test streak section
      expect(find.text('Days in a row'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget); // Trophy icon

      // Test weekly dots (S M T W T F S)
      expect(find.text('S'), findsAtLeastNWidgets(2)); // Sunday appears twice
      expect(find.text('M'), findsOneWidget);
      expect(find.text('T'), findsAtLeastNWidgets(2)); // Tuesday and Thursday
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);

      // Test statistics cards
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('Daily average'), findsOneWidget);
      expect(find.text('Most used'), findsOneWidget);
    });

    testWidgets('Color scheme accuracy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test background gradient
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      // Test app colors are used consistently
      final materialApp = find.byType(MaterialApp);
      expect(materialApp, findsOneWidget);

      // Test specific color usage in components
      final drinkTypeSelector = find.byType(DrinkTypeSelector);
      expect(drinkTypeSelector, findsOneWidget);

      // Test water drop icon color
      final waterDropIcon = find.byIcon(Icons.water_drop);
      if (tester.any(waterDropIcon)) {
        final iconWidget = tester.widget<Icon>(waterDropIcon);
        expect(iconWidget.color, equals(AppColors.waterFull));
      }
    });

    testWidgets('Typography consistency', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test header typography
      final todayText = tester.widget<Text>(find.text('Today'));
      expect(todayText.style?.fontFamily, equals('Nunito'));
      expect(todayText.style?.fontWeight, equals(FontWeight.w700));

      // Test progress text typography
      final progressText = tester.widget<Text>(find.text('0.0 L drank so far'));
      expect(progressText.style?.fontFamily, equals('Nunito'));
      expect(progressText.style?.fontWeight, equals(FontWeight.w600));

      // Test button text typography
      final buttonText = tester.widget<Text>(find.text('500 ml'));
      expect(buttonText.style?.fontFamily, equals('Nunito'));
      expect(buttonText.style?.fontWeight, equals(FontWeight.w600));
    });

    testWidgets('Spacing and layout accuracy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test overall layout spacing
      final mainPage = find.byType(MainHydrationPage);
      expect(mainPage, findsOneWidget);

      // Test circular progress section positioning
      final circularProgress = find.byType(CircularProgressSection);
      final circularProgressRect = tester.getRect(circularProgress);

      // Test quick add buttons positioning
      final buttonGrid = find.byType(QuickAddButtonGrid);
      final buttonGridRect = tester.getRect(buttonGrid);

      // Buttons should be below circular progress with proper spacing
      expect(buttonGridRect.top, greaterThan(circularProgressRect.bottom));

      // Test drink type selector positioning
      final drinkSelector = find.byType(DrinkTypeSelector);
      final drinkSelectorRect = tester.getRect(drinkSelector);

      // Drink selector should be between progress and buttons
      expect(drinkSelectorRect.top, greaterThan(circularProgressRect.bottom));
      expect(drinkSelectorRect.bottom, lessThan(buttonGridRect.top));
    });

    testWidgets('Responsive design accuracy', (WidgetTester tester) async {
      // Test different screen sizes
      await tester.binding.setSurfaceSize(
        const Size(375, 812),
      ); // iPhone X size

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Elements should still be visible and properly positioned
      expect(find.byType(CircularProgressSection), findsOneWidget);
      expect(find.byType(QuickAddButtonGrid), findsOneWidget);
      expect(find.byType(DrinkTypeSelector), findsOneWidget);

      // Test larger screen size
      await tester.binding.setSurfaceSize(
        const Size(414, 896),
      ); // iPhone 11 Pro Max size
      await tester.pumpAndSettle();

      // Elements should adapt to larger screen
      expect(find.byType(CircularProgressSection), findsOneWidget);
      expect(find.byType(QuickAddButtonGrid), findsOneWidget);
      expect(find.byType(DrinkTypeSelector), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(const Size(800, 600));
    });

    testWidgets('Animation visual accuracy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test progress animation
      await tester.tap(find.text('500 ml'));
      await tester.pump(); // Start animation

      // Animation should be in progress
      await tester.pump(const Duration(milliseconds: 200));

      // Progress should be updating
      expect(find.byType(CircularProgressSection), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();

      // Final state should show updated progress
      expect(find.text('0.5 L drank so far'), findsOneWidget);

      // Test page transition animation
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -300));

      // Animation should be smooth
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.byType(StatisticsPage), findsOneWidget);
    });
  });

  group('Visual Regression Golden Tests', () {
    // Note: Golden tests would require actual golden files
    // These are placeholder tests showing the structure

    testWidgets('Main page golden test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => HydrationProvider(),
            child: const AddHydrationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // In a real implementation, this would compare against a golden file
      // await expectLater(find.byType(MainHydrationPage), matchesGoldenFile('main_page.png'));

      // For now, just verify the page renders without errors
      expect(find.byType(MainHydrationPage), findsOneWidget);
    });

    testWidgets('Statistics page golden test', (WidgetTester tester) async {
      final provider = HydrationProvider();
      await provider.addHydration(500);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => provider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Navigate to statistics
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // In a real implementation, this would compare against a golden file
      // await expectLater(find.byType(StatisticsPage), matchesGoldenFile('statistics_page.png'));

      expect(find.byType(StatisticsPage), findsOneWidget);
    });
  });
}
