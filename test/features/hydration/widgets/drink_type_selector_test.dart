import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';

void main() {
  group('DrinkTypeSelector Widget Tests', () {
    testWidgets('displays selected drink type correctly', (tester) async {
      DrinkType? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeSelector(
              selectedType: DrinkType.water,
              onTypeChanged: (type) => selectedType = type,
            ),
          ),
        ),
      );

      // Verify water is displayed as selected type
      expect(find.text('Water'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);

      // Water should not show water content percentage
      expect(find.textContaining('% water'), findsNothing);
    });

    testWidgets('displays water content for non-water drinks', (tester) async {
      DrinkType? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeSelector(
              selectedType: DrinkType.tea,
              onTypeChanged: (type) => selectedType = type,
            ),
          ),
        ),
      );

      // Verify tea is displayed with water content
      expect(find.text('Tea'), findsOneWidget);
      expect(find.byIcon(Icons.local_cafe), findsOneWidget);
      expect(find.text('95% water'), findsOneWidget);
    });

    testWidgets('shows edit icon', (tester) async {
      DrinkType? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeSelector(
              selectedType: DrinkType.water,
              onTypeChanged: (type) => selectedType = type,
            ),
          ),
        ),
      );

      // Verify edit icon is present
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('opens picker modal when tapped', (tester) async {
      DrinkType? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeSelector(
              selectedType: DrinkType.water,
              onTypeChanged: (type) => selectedType = type,
            ),
          ),
        ),
      );

      // Tap the selector
      await tester.tap(find.byType(DrinkTypeSelector));
      await tester.pumpAndSettle();

      // Verify modal is opened
      expect(find.text('Select Drink Type'), findsOneWidget);
      expect(find.byType(DrinkTypePickerModal), findsOneWidget);
    });

    testWidgets('calls onTypeChanged when new type is selected', (
      tester,
    ) async {
      DrinkType? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeSelector(
              selectedType: DrinkType.water,
              onTypeChanged: (type) => selectedType = type,
            ),
          ),
        ),
      );

      // Open the picker
      await tester.tap(find.byType(DrinkTypeSelector));
      await tester.pumpAndSettle();

      // Select tea
      await tester.tap(find.text('Tea'));
      await tester.pumpAndSettle();

      // Verify callback was called with tea
      expect(selectedType, equals(DrinkType.tea));
    });

    testWidgets('does not call onTypeChanged when same type is selected', (
      tester,
    ) async {
      DrinkType? selectedType;
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeSelector(
              selectedType: DrinkType.water,
              onTypeChanged: (type) {
                selectedType = type;
                callCount++;
              },
            ),
          ),
        ),
      );

      // Open the picker
      await tester.tap(find.byType(DrinkTypeSelector));
      await tester.pumpAndSettle();

      // Find water options - there will be one in selector and one in modal
      final waterInModal = find.descendant(
        of: find.byType(DrinkTypePickerModal),
        matching: find.text('Water'),
      );

      // Select water (same as current) from the modal
      await tester.tap(waterInModal);
      await tester.pumpAndSettle();

      // Verify callback was not called
      expect(callCount, equals(0));
      expect(selectedType, isNull);
    });
  });

  group('DrinkTypePickerModal Widget Tests', () {
    testWidgets('displays all drink types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DrinkTypePickerModal(selectedType: DrinkType.water),
          ),
        ),
      );

      // Verify all drink types are displayed
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Juice'), findsOneWidget);
      expect(find.text('Soda'), findsOneWidget);
      expect(find.text('Sports Drink'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('shows selected type with different styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DrinkTypePickerModal(selectedType: DrinkType.tea),
          ),
        ),
      );

      // Find the tea option
      final teaOption = find.ancestor(
        of: find.text('Tea'),
        matching: find.byType(DrinkTypeOption),
      );

      expect(teaOption, findsOneWidget);

      // Verify check icon is present for selected item
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays water content for all drink types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DrinkTypePickerModal(selectedType: DrinkType.water),
          ),
        ),
      );

      // Verify water content is shown for all types
      expect(find.text('100% water content'), findsOneWidget); // Water
      expect(
        find.text('95% water content'),
        findsNWidgets(2),
      ); // Tea and Coffee
      expect(find.text('85% water content'), findsOneWidget); // Juice
      expect(find.text('90% water content'), findsOneWidget); // Soda
      expect(find.text('92% water content'), findsOneWidget); // Sports
      expect(find.text('80% water content'), findsOneWidget); // Other
    });

    testWidgets('closes modal when close button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => showModalBottomSheet<void>(
                          context: context,
                          builder:
                              (context) => const DrinkTypePickerModal(
                                selectedType: DrinkType.water,
                              ),
                        ),
                    child: const Text('Open Modal'),
                  ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.byType(DrinkTypePickerModal), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify modal is closed
      expect(find.byType(DrinkTypePickerModal), findsNothing);
    });

    testWidgets('returns selected drink type when option is tapped', (
      tester,
    ) async {
      DrinkType? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () async {
                      result = await showModalBottomSheet<DrinkType>(
                        context: context,
                        builder:
                            (context) => const DrinkTypePickerModal(
                              selectedType: DrinkType.water,
                            ),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Select coffee
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();

      // Verify coffee was returned
      expect(result, equals(DrinkType.coffee));
    });
  });

  group('DrinkTypeOption Widget Tests', () {
    testWidgets('displays drink type information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeOption(
              drinkType: DrinkType.juice,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify juice information is displayed
      expect(find.text('Juice'), findsOneWidget);
      expect(find.text('85% water content'), findsOneWidget);
      expect(find.byIcon(Icons.local_drink), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('shows selected state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeOption(
              drinkType: DrinkType.sports,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify selected state
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeOption(
              drinkType: DrinkType.soda,
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the option
      await tester.tap(find.byType(DrinkTypeOption));
      await tester.pump();

      // Verify callback was called
      expect(tapped, isTrue);
    });
  });

  group('Water Content Calculations', () {
    testWidgets('displays correct water content percentages', (tester) async {
      final testCases = [
        (DrinkType.water, null), // Water doesn't show percentage
        (DrinkType.tea, '95% water'),
        (DrinkType.coffee, '95% water'),
        (DrinkType.juice, '85% water'),
        (DrinkType.soda, '90% water'),
        (DrinkType.sports, '92% water'),
        (DrinkType.other, '80% water'),
      ];

      for (final (drinkType, expectedText) in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DrinkTypeSelector(
                selectedType: drinkType,
                onTypeChanged: (_) {},
              ),
            ),
          ),
        );

        if (expectedText == null) {
          // Water should not show percentage
          expect(find.textContaining('% water'), findsNothing);
        } else {
          // Non-water drinks should show percentage
          expect(find.text(expectedText), findsOneWidget);
        }

        await tester.pumpWidget(Container()); // Clear widget
      }
    });

    testWidgets('water content calculations match DrinkType enum', (
      tester,
    ) async {
      // Verify that the displayed percentages match the actual enum values
      for (final drinkType in DrinkType.values) {
        final expectedPercentage = (drinkType.waterContent * 100).round();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DrinkTypePickerModal(selectedType: drinkType)),
          ),
        );

        expect(
          find.text('$expectedPercentage% water content'),
          findsAtLeastNWidgets(1),
        );

        await tester.pumpWidget(Container()); // Clear widget
      }
    });
  });

  group('Accessibility Tests', () {
    testWidgets('has proper semantic labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkTypeSelector(
              selectedType: DrinkType.water,
              onTypeChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify the widget is accessible
      expect(find.byType(GestureDetector), findsOneWidget);

      // The widget should be tappable for screen readers
      final gestureDetector = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gestureDetector.onTap, isNotNull);
    });

    testWidgets('modal has proper close button accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DrinkTypePickerModal(selectedType: DrinkType.water),
          ),
        ),
      );

      // Verify close button is accessible
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
