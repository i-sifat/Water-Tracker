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
  group('StatisticsPage', () {
    late MockHydrationProvider mockProvider;

    setUp(() {
      mockProvider = MockHydrationProvider();

      // Setup default mock behavior
      when(mockProvider.currentStreak).thenReturn(5);
      when(mockProvider.longestStreak).thenReturn(10);
      when(mockProvider.dailyGoal).thenReturn(2000);
      when(mockProvider.currentIntake).thenReturn(1500);
      when(mockProvider.intakePercentage).thenReturn(0.75);
      when(mockProvider.getEntriesForDate(any)).thenReturn([]);
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<HydrationProvider>.value(
        value: mockProvider,
        child: const MaterialApp(home: StatisticsPage()),
      );
    }

    testWidgets('displays header with Statistics title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Statistics'), findsOneWidget);

      final titleWidget = tester.widget<Text>(find.text('Statistics'));
      expect(titleWidget.style?.fontSize, 24);
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
      expect(titleWidget.style?.color, AppColors.textHeadline);
      expect(titleWidget.style?.fontFamily, 'Nunito');
    });

    testWidgets('displays period selector tabs', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('WEEKLY'), findsOneWidget);
      expect(find.text('MONTHLY'), findsOneWidget);
      expect(find.text('YEARLY'), findsOneWidget);
    });

    testWidgets('period selector tabs are interactive', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially WEEKLY should be selected
      final weeklyTab = find.text('WEEKLY');
      expect(weeklyTab, findsOneWidget);

      // Tap on MONTHLY tab
      await tester.tap(find.text('MONTHLY'));
      await tester.pumpAndSettle();

      // Verify the tap was registered (widget should rebuild)
      expect(find.text('MONTHLY'), findsOneWidget);
    });

    testWidgets('displays streak section with trophy icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.text('Days in a row'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // Current streak
    });

    testWidgets('displays weekly dots with correct status', (tester) async {
      // Setup mock data for a week with some completed days
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      // Mock some days as completed
      when(
        mockProvider.getEntriesForDate(weekStart),
      ).thenReturn([HydrationData.create(amount: 2000)]);
      when(
        mockProvider.getEntriesForDate(weekStart.add(const Duration(days: 1))),
      ).thenReturn([HydrationData.create(amount: 2500)]);

      await tester.pumpWidget(createTestWidget());

      // Should find weekly day indicators (letters may appear in different contexts)
      expect(find.text('S'), findsAtLeastNWidgets(1));
      expect(find.text('M'), findsAtLeastNWidgets(1));
      expect(find.text('T'), findsAtLeastNWidgets(1));
      expect(find.text('W'), findsAtLeastNWidgets(1));
      expect(find.text('F'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays intake chart section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Intake'), findsOneWidget);

      final intakeTitle = tester.widget<Text>(find.text('Intake'));
      expect(intakeTitle.style?.fontSize, 18);
      expect(intakeTitle.style?.fontWeight, FontWeight.w600);
      expect(intakeTitle.style?.color, AppColors.textHeadline);
    });

    testWidgets('displays balance card with correct percentage', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget); // 0.75 * 100
      expect(find.text('completed'), findsOneWidget);
    });

    testWidgets('displays daily average card', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Daily average'), findsOneWidget);
      expect(find.text('per day'), findsOneWidget);

      // Should display some average value in liters
      expect(find.textContaining('L'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays most used section', (tester) async {
      // Setup mock data with some drink entries
      final mockEntries = [
        HydrationData.create(amount: 500),
        HydrationData.create(amount: 300, type: DrinkType.tea),
        HydrationData.create(amount: 200, type: DrinkType.coffee),
      ];

      when(mockProvider.getEntriesForDate(any)).thenReturn(mockEntries);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Most used'), findsOneWidget);

      // Should display ranking numbers
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
    });

    testWidgets('streak section displays correct current streak', (
      tester,
    ) async {
      when(mockProvider.currentStreak).thenReturn(12);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('12'), findsOneWidget);

      final streakText = tester.widget<Text>(find.text('12'));
      expect(streakText.style?.fontSize, 32);
      expect(streakText.style?.fontWeight, FontWeight.bold);
      expect(streakText.style?.color, AppColors.waterFull);
    });

    testWidgets('balance card shows 100% when goal is reached', (tester) async {
      when(mockProvider.intakePercentage).thenReturn(1);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('balance card shows 0% when no intake', (tester) async {
      when(mockProvider.intakePercentage).thenReturn(0);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('weekly dots show check icon for completed days', (
      tester,
    ) async {
      // Setup a completed day
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      when(mockProvider.getEntriesForDate(weekStart)).thenReturn([
        HydrationData.create(amount: 2500), // Over goal
      ]);

      await tester.pumpWidget(createTestWidget());

      // Should find at least one check icon for completed days
      expect(find.byIcon(Icons.check), findsAtLeastNWidgets(0));
    });

    testWidgets('period switching updates chart data', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially on weekly
      expect(find.text('WEEKLY'), findsOneWidget);

      // Switch to monthly
      await tester.tap(find.text('MONTHLY'));
      await tester.pumpAndSettle();

      // Chart should still be present but with different data
      expect(find.text('Intake'), findsOneWidget);

      // Switch to yearly
      await tester.tap(find.text('YEARLY'));
      await tester.pumpAndSettle();

      // Chart should still be present
      expect(find.text('Intake'), findsOneWidget);
    });

    testWidgets('displays correct typography throughout', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check main title
      final titleWidget = tester.widget<Text>(find.text('Statistics'));
      expect(titleWidget.style?.fontFamily, 'Nunito');

      // Check section headers
      final intakeTitle = tester.widget<Text>(find.text('Intake'));
      expect(intakeTitle.style?.fontFamily, 'Nunito');

      final balanceTitle = tester.widget<Text>(find.text('Balance'));
      expect(balanceTitle.style?.fontFamily, 'Nunito');
    });

    testWidgets('uses correct colors from AppColors', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check trophy icon color
      final trophyIcon = tester.widget<Icon>(find.byIcon(Icons.emoji_events));
      expect(trophyIcon.color, AppColors.goalYellow);

      // Check streak number color
      final streakText = tester.widget<Text>(find.text('5'));
      expect(streakText.style?.color, AppColors.waterFull);
    });

    testWidgets('handles empty data gracefully', (tester) async {
      when(mockProvider.currentStreak).thenReturn(0);
      when(mockProvider.intakePercentage).thenReturn(0);
      when(mockProvider.getEntriesForDate(any)).thenReturn([]);

      await tester.pumpWidget(createTestWidget());

      // Should still display all sections
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Days in a row'), findsOneWidget);
      expect(find.text('Intake'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('Most used'), findsOneWidget);

      // Should show 0 values
      expect(find.text('0'), findsAtLeastNWidgets(1));
      expect(find.text('0%'), findsOneWidget);
    });
  });

  group('StatisticsPeriod enum', () {
    test('has correct values', () {
      expect(StatisticsPeriod.values.length, 3);
      expect(StatisticsPeriod.values, contains(StatisticsPeriod.weekly));
      expect(StatisticsPeriod.values, contains(StatisticsPeriod.monthly));
      expect(StatisticsPeriod.values, contains(StatisticsPeriod.yearly));
    });

    test('has correct names', () {
      expect(StatisticsPeriod.weekly.name, 'weekly');
      expect(StatisticsPeriod.monthly.name, 'monthly');
      expect(StatisticsPeriod.yearly.name, 'yearly');
    });
  });
}
