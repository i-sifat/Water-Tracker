import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';

void main() {
  group('DrinkTypeSelector Integration Tests', () {
    late HydrationProvider mockProvider;

    setUp(() {
      mockProvider = HydrationProvider();
    });

    testWidgets('DrinkTypeSelector integrates with QuickAddButtonGrid', (
      tester,
    ) async {
      var selectedDrinkType = DrinkType.water;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: Scaffold(
              body: Column(
                children: [
                  DrinkTypeSelector(
                    selectedType: selectedDrinkType,
                    onTypeChanged: (DrinkType newType) {
                      selectedDrinkType = newType;
                    },
                  ),
                  QuickAddButtonGrid(selectedDrinkType: selectedDrinkType),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially, water is selected and no water content should be shown on buttons
      expect(find.text('Water'), findsOneWidget);
      expect(find.textContaining('ml water'), findsNothing);

      // Open drink type selector
      await tester.tap(find.byType(DrinkTypeSelector));
      await tester.pumpAndSettle();

      // Select tea
      await tester.tap(find.text('Tea'));
      await tester.pumpAndSettle();

      // Rebuild with new drink type
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: Scaffold(
              body: Column(
                children: [
                  DrinkTypeSelector(
                    selectedType: DrinkType.tea,
                    onTypeChanged: (DrinkType newType) {
                      selectedDrinkType = newType;
                    },
                  ),
                  const QuickAddButtonGrid(selectedDrinkType: DrinkType.tea),
                ],
              ),
            ),
          ),
        ),
      );

      // Now tea is selected and water content should be shown on buttons
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('95% water'), findsOneWidget);

      // Check that quick add buttons show water content
      expect(find.textContaining('ml water'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'water content calculations are consistent between components',
      (tester) async {
        const testDrinkType = DrinkType.juice;
        const testAmount = 500;
        const expectedWaterContent = testAmount * 0.85; // 85% for juice

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<HydrationProvider>.value(
              value: mockProvider,
              child: Scaffold(
                body: Column(
                  children: [
                    DrinkTypeSelector(
                      selectedType: testDrinkType,
                      onTypeChanged: (_) {},
                    ),
                    const QuickAddButtonGrid(selectedDrinkType: testDrinkType),
                  ],
                ),
              ),
            ),
          ),
        );

        // Check DrinkTypeSelector shows correct percentage
        expect(find.text('85% water'), findsOneWidget);

        // Check QuickAddButtonGrid shows correct water content for 500ml button
        expect(
          find.text('${expectedWaterContent.round()}ml water'),
          findsOneWidget,
        );
      },
    );

    testWidgets('all drink types show consistent water content', (
      tester,
    ) async {
      for (final drinkType in DrinkType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<HydrationProvider>.value(
              value: mockProvider,
              child: Scaffold(
                body: Column(
                  children: [
                    DrinkTypeSelector(
                      selectedType: drinkType,
                      onTypeChanged: (_) {},
                    ),
                    QuickAddButtonGrid(selectedDrinkType: drinkType),
                  ],
                ),
              ),
            ),
          ),
        );

        final expectedPercentage = (drinkType.waterContent * 100).round();

        if (drinkType == DrinkType.water) {
          // Water should not show percentage in selector
          expect(find.textContaining('% water'), findsNothing);
          // Water should not show water content in buttons
          expect(find.textContaining('ml water'), findsNothing);
        } else {
          // Non-water drinks should show percentage in selector
          expect(find.text('$expectedPercentage% water'), findsOneWidget);
          // Non-water drinks should show water content in buttons
          expect(find.textContaining('ml water'), findsAtLeastNWidgets(1));
        }

        await tester.pumpWidget(Container()); // Clear widget
      }
    });
  });
}
