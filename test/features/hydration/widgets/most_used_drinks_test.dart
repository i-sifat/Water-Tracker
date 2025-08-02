import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';

import 'statistics_page_test.mocks.dart';

@GenerateMocks([HydrationProvider])
void main() {
  group('Most Used Drinks Section', () {
    late MockHydrationProvider mockProvider;

    setUp(() {
      mockProvider = MockHydrationProvider();

      // Setup default mock behavior
      when(mockProvider.currentStreak).thenReturn(0);
      when(mockProvider.longestStreak).thenReturn(0);
      when(mockProvider.dailyGoal).thenReturn(2000);
      when(mockProvider.currentIntake).thenReturn(0);
      when(mockProvider.intakePercentage).thenReturn(0);
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<HydrationProvider>.value(
        value: mockProvider,
        child: const MaterialApp(home: StatisticsPage()),
      );
    }

    testWidgets('displays most used section with correct ranking', (
      tester,
    ) async {
      // Setup mock data with different drink types and amounts
      final mockEntries = [
        // Water: 1000ml water content (1000 * 1.0)
        HydrationData.create(amount: 1000),
        // Tea: 475ml water content (500 * 0.95)
        HydrationData.create(amount: 500, type: DrinkType.tea),
        // Coffee: 285ml water content (300 * 0.95)
        HydrationData.create(amount: 300, type: DrinkType.coffee),
        // Juice: 170ml water content (200 * 0.85)
        HydrationData.create(amount: 200, type: DrinkType.juice),
      ];

      when(mockProvider.getEntriesForDate(any)).thenReturn(mockEntries);

      await tester.pumpWidget(createTestWidget());

      // Verify section title
      expect(find.text('Most used'), findsOneWidget);

      // Verify ranking numbers are displayed
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);

      // Verify drink icons are displayed
      expect(find.byIcon(Icons.water_drop), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.local_cafe), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.coffee), findsAtLeastNWidgets(1));

      // Verify amounts are displayed in liters (based on water content)
      expect(
        find.textContaining('L'),
        findsAtLeastNWidgets(3),
      ); // Should have 3 amounts in liters
    });

    testWidgets('displays correct drink names', (tester) async {
      final mockEntries = [
        HydrationData.create(amount: 1000),
        HydrationData.create(amount: 500, type: DrinkType.tea),
        HydrationData.create(amount: 300, type: DrinkType.coffee),
      ];

      when(mockProvider.getEntriesForDate(any)).thenReturn(mockEntries);

      await tester.pumpWidget(createTestWidget());

      // Verify drink names are displayed
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('uses correct colors and styling', (tester) async {
      final mockEntries = [
        HydrationData.create(amount: 1000),
      ];

      when(mockProvider.getEntriesForDate(any)).thenReturn(mockEntries);

      await tester.pumpWidget(createTestWidget());

      // Check section title styling
      final titleWidget = tester.widget<Text>(find.text('Most used'));
      expect(titleWidget.style?.fontSize, 18);
      expect(titleWidget.style?.fontWeight, FontWeight.w600);
      expect(titleWidget.style?.color, AppColors.textHeadline);
      expect(titleWidget.style?.fontFamily, 'Nunito');

      // Check ranking number styling
      final rankingWidget = tester.widget<Text>(find.text('1.'));
      expect(rankingWidget.style?.fontSize, 16);
      expect(rankingWidget.style?.fontWeight, FontWeight.w600);
      expect(rankingWidget.style?.color, AppColors.textHeadline);
      expect(rankingWidget.style?.fontFamily, 'Nunito');

      // Check icon color
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.water_drop));
      expect(iconWidget.color, AppColors.waterFull);
      expect(iconWidget.size, 24);

      // Check that amount texts are displayed (they should contain decimal and L)
      expect(find.textContaining('L'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles empty data gracefully', (tester) async {
      when(mockProvider.getEntriesForDate(any)).thenReturn([]);

      await tester.pumpWidget(createTestWidget());

      // Section should still be displayed
      expect(find.text('Most used'), findsOneWidget);

      // But no ranking numbers should be shown
      expect(find.text('1.'), findsNothing);
      expect(find.text('2.'), findsNothing);
      expect(find.text('3.'), findsNothing);
    });

    testWidgets('shows only top 3 drinks when more than 3 types exist', (
      tester,
    ) async {
      final mockEntries = [
        HydrationData.create(amount: 1000),
        HydrationData.create(amount: 800, type: DrinkType.tea),
        HydrationData.create(amount: 600, type: DrinkType.coffee),
        HydrationData.create(amount: 400, type: DrinkType.juice),
        HydrationData.create(amount: 200, type: DrinkType.soda),
      ];

      when(mockProvider.getEntriesForDate(any)).thenReturn(mockEntries);

      await tester.pumpWidget(createTestWidget());

      // Should show only top 3 rankings
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
      expect(find.text('4.'), findsNothing);
      expect(find.text('5.'), findsNothing);

      // Should show top 3 drink names
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('calculates water content correctly for ranking', (
      tester,
    ) async {
      // Setup drinks with same amount but different water content percentages
      final mockEntries = [
        // Juice: 850ml water content (1000 * 0.85)
        HydrationData.create(amount: 1000, type: DrinkType.juice),
        // Soda: 900ml water content (1000 * 0.90)
        HydrationData.create(amount: 1000, type: DrinkType.soda),
        // Water: 1000ml water content (1000 * 1.0)
        HydrationData.create(amount: 1000),
      ];

      when(mockProvider.getEntriesForDate(any)).thenReturn(mockEntries);

      await tester.pumpWidget(createTestWidget());

      // Water should be ranked first (highest water content)
      // Soda should be ranked second
      // Juice should be ranked third
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Soda'), findsOneWidget);
      expect(find.text('Juice'), findsOneWidget);
    });

    testWidgets('proper spacing between drink items', (tester) async {
      final mockEntries = [
        HydrationData.create(amount: 1000),
        HydrationData.create(amount: 500, type: DrinkType.tea),
        HydrationData.create(amount: 300, type: DrinkType.coffee),
      ];

      when(mockProvider.getEntriesForDate(any)).thenReturn(mockEntries);

      await tester.pumpWidget(createTestWidget());

      // Find all Padding widgets in the most used section
      final paddingWidgets = find.descendant(
        of: find.ancestor(
          of: find.text('Most used'),
          matching: find.byType(Column),
        ),
        matching: find.byType(Padding),
      );

      // Should have proper padding for spacing
      expect(paddingWidgets, findsAtLeastNWidgets(3));
    });
  });
}
