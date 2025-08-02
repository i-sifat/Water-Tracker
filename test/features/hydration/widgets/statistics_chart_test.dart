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
  group('Statistics Chart and Cards Tests', () {
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

    group('Intake Chart', () {
      testWidgets('displays intake chart with correct title', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Intake'), findsOneWidget);

        final intakeTitle = tester.widget<Text>(find.text('Intake'));
        expect(intakeTitle.style?.fontSize, 18);
        expect(intakeTitle.style?.fontWeight, FontWeight.w600);
        expect(intakeTitle.style?.color, AppColors.textHeadline);
        expect(intakeTitle.style?.fontFamily, 'Nunito');
      });

      testWidgets('chart updates when period changes', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initially on weekly
        expect(find.text('Intake'), findsOneWidget);

        // Switch to monthly
        await tester.tap(find.text('MONTHLY'));
        await tester.pumpAndSettle();

        // Chart should still be present
        expect(find.text('Intake'), findsOneWidget);

        // Switch to yearly
        await tester.tap(find.text('YEARLY'));
        await tester.pumpAndSettle();

        // Chart should still be present
        expect(find.text('Intake'), findsOneWidget);
      });

      testWidgets('chart displays with real data', (tester) async {
        // Setup mock data for different days
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));

        // Mock data for each day of the week
        for (var i = 0; i < 7; i++) {
          final date = weekStart.add(Duration(days: i));
          final amount = 1000 + (i * 200); // Varying amounts
          when(mockProvider.getEntriesForDate(date)).thenReturn([
            HydrationData.create(amount: amount),
          ]);
        }

        await tester.pumpWidget(createTestWidget());

        // Chart should be displayed
        expect(find.text('Intake'), findsOneWidget);

        // Verify chart data is being used (chart widget should be present)
        expect(find.byType(StatisticsPage), findsOneWidget);
      });
    });

    group('Balance Card', () {
      testWidgets('displays balance card with correct percentage', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Balance'), findsOneWidget);
        expect(find.text('75%'), findsOneWidget); // 0.75 * 100
        expect(find.text('completed'), findsOneWidget);

        final balanceTitle = tester.widget<Text>(find.text('Balance'));
        expect(balanceTitle.style?.fontSize, 16);
        expect(balanceTitle.style?.fontWeight, FontWeight.w600);
        expect(balanceTitle.style?.color, AppColors.textHeadline);
        expect(balanceTitle.style?.fontFamily, 'Nunito');

        final percentageText = tester.widget<Text>(find.text('75%'));
        expect(percentageText.style?.fontSize, 32);
        expect(percentageText.style?.fontWeight, FontWeight.bold);
        expect(percentageText.style?.color, AppColors.waterFull);
        expect(percentageText.style?.fontFamily, 'Nunito');
      });

      testWidgets('balance card shows 100% when goal is reached', (
        tester,
      ) async {
        when(mockProvider.intakePercentage).thenReturn(1);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('100%'), findsOneWidget);
      });

      testWidgets('balance card shows 0% when no intake', (tester) async {
        when(mockProvider.intakePercentage).thenReturn(0);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('0%'), findsOneWidget);
      });

      testWidgets('balance card handles over 100% correctly', (tester) async {
        when(mockProvider.intakePercentage).thenReturn(1.25); // 125%

        await tester.pumpWidget(createTestWidget());

        expect(find.text('125%'), findsOneWidget);
      });
    });

    group('Daily Average Card', () {
      testWidgets('displays daily average card with correct format', (
        tester,
      ) async {
        // Mock some historical data for average calculation
        final now = DateTime.now();
        for (var i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          when(mockProvider.getEntriesForDate(date)).thenReturn([
            HydrationData.create(amount: 1500),
          ]);
        }

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Daily average'), findsOneWidget);
        expect(find.text('per day'), findsOneWidget);

        final averageTitle = tester.widget<Text>(find.text('Daily average'));
        expect(averageTitle.style?.fontSize, 16);
        expect(averageTitle.style?.fontWeight, FontWeight.w600);
        expect(averageTitle.style?.color, AppColors.textHeadline);
        expect(averageTitle.style?.fontFamily, 'Nunito');

        // Should display some average value in liters
        expect(find.textContaining('L'), findsAtLeastNWidgets(1));
      });

      testWidgets('daily average updates with different periods', (
        tester,
      ) async {
        // Setup different data for different periods
        final now = DateTime.now();

        // Weekly data
        for (var i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          when(mockProvider.getEntriesForDate(date)).thenReturn([
            HydrationData.create(
              amount: 1000 + (i * 100),
            ),
          ]);
        }

        await tester.pumpWidget(createTestWidget());

        // Initially on weekly
        expect(find.text('Daily average'), findsOneWidget);

        // Switch to monthly
        await tester.tap(find.text('MONTHLY'));
        await tester.pumpAndSettle();

        // Should still show daily average
        expect(find.text('Daily average'), findsOneWidget);

        // Switch to yearly
        await tester.tap(find.text('YEARLY'));
        await tester.pumpAndSettle();

        // Should still show daily average
        expect(find.text('Daily average'), findsOneWidget);
      });

      testWidgets('daily average handles no data gracefully', (tester) async {
        when(mockProvider.getEntriesForDate(any)).thenReturn([]);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Daily average'), findsOneWidget);
        expect(find.text('0.0 L'), findsOneWidget);
      });
    });

    group('Responsive Layout', () {
      testWidgets('balance and daily average cards are side by side', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // Both cards should be present
        expect(find.text('Balance'), findsOneWidget);
        expect(find.text('Daily average'), findsOneWidget);

        // They should be in a Row layout (side by side)
        final row = find.ancestor(
          of: find.text('Balance'),
          matching: find.byType(Row),
        );
        expect(row, findsOneWidget);

        final rowWidget = tester.widget<Row>(row);
        expect(rowWidget.children.length, 3); // Two Expanded widgets + SizedBox
      });

      testWidgets('cards have equal width in responsive layout', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // Find the Row containing the cards
        final row = find.ancestor(
          of: find.text('Balance'),
          matching: find.byType(Row),
        );
        expect(row, findsOneWidget);

        // Both cards should be wrapped in Expanded widgets for equal width
        final expandedWidgets = find.descendant(
          of: row,
          matching: find.byType(Expanded),
        );
        expect(expandedWidgets, findsNWidgets(2));
      });
    });

    group('Real-time Data Updates', () {
      testWidgets('statistics display correct values from provider', (
        tester,
      ) async {
        // Test with different provider values
        final testMockProvider = MockHydrationProvider();
        when(testMockProvider.currentStreak).thenReturn(5);
        when(testMockProvider.longestStreak).thenReturn(10);
        when(testMockProvider.dailyGoal).thenReturn(2000);
        when(testMockProvider.currentIntake).thenReturn(1800);
        when(testMockProvider.intakePercentage).thenReturn(0.90);
        when(testMockProvider.getEntriesForDate(any)).thenReturn([]);

        await tester.pumpWidget(
          ChangeNotifierProvider<HydrationProvider>.value(
            value: testMockProvider,
            child: const MaterialApp(home: StatisticsPage()),
          ),
        );

        // Should show correct percentage
        expect(find.text('90%'), findsOneWidget);
      });

      testWidgets('chart data updates with provider changes', (tester) async {
        // Setup initial data
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));

        when(mockProvider.getEntriesForDate(any)).thenReturn([
          HydrationData.create(amount: 1000),
        ]);

        await tester.pumpWidget(createTestWidget());

        // Chart should be present
        expect(find.text('Intake'), findsOneWidget);

        // Update data
        when(mockProvider.getEntriesForDate(any)).thenReturn([
          HydrationData.create(amount: 2000),
        ]);

        // Trigger rebuild
        mockProvider.notifyListeners();
        await tester.pumpAndSettle();

        // Chart should still be present with updated data
        expect(find.text('Intake'), findsOneWidget);
      });
    });

    group('Statistics Calculations', () {
      testWidgets('balance percentage calculation is correct', (tester) async {
        // Test various percentage scenarios
        final testCases = [
          {'intake': 0.0, 'expected': '0%'},
          {'intake': 0.25, 'expected': '25%'},
          {'intake': 0.5, 'expected': '50%'},
          {'intake': 0.75, 'expected': '75%'},
          {'intake': 1.0, 'expected': '100%'},
          {'intake': 1.5, 'expected': '150%'},
        ];

        for (final testCase in testCases) {
          when(
            mockProvider.intakePercentage,
          ).thenReturn(testCase['intake']! as double);

          await tester.pumpWidget(createTestWidget());

          expect(find.text(testCase['expected']! as String), findsOneWidget);

          // Reset for next test
          await tester.pumpWidget(Container());
        }
      });

      testWidgets('daily average displays in correct format', (tester) async {
        final now = DateTime.now();

        // Setup mock data with consistent intake
        for (var i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          when(mockProvider.getEntriesForDate(date)).thenReturn([
            HydrationData.create(amount: 1500),
          ]);
        }

        await tester.pumpWidget(createTestWidget());

        // Should display daily average in liters format
        expect(find.textContaining('L'), findsAtLeastNWidgets(1));
        expect(find.text('Daily average'), findsOneWidget);
        expect(find.text('per day'), findsOneWidget);
      });
    });
  });
}
