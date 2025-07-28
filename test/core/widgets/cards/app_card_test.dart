import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';

void main() {
  group('AppCard Widget Tests', () {
    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      const childText = 'Test Child';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppCard(child: Text(childText))),
        ),
      );

      expect(find.text(childText), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('applies custom padding correctly', (
      WidgetTester tester,
    ) async {
      const customPadding = EdgeInsets.all(24);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(padding: customPadding, child: Text('Test')),
          ),
        ),
      );

      final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));
      final cardPadding = paddingWidgets.firstWhere(
        (padding) => padding.padding == customPadding,
        orElse:
            () => const Padding(padding: EdgeInsets.zero, child: SizedBox()),
      );
      expect(cardPadding.padding, equals(customPadding));
    });

    testWidgets('applies custom margin correctly', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(12);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(margin: customMargin, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, equals(customMargin));
    });

    testWidgets('uses default padding when not specified', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppCard(child: Text('Test')))),
      );

      final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));
      final cardPadding = paddingWidgets.firstWhere(
        (padding) => padding.padding == const EdgeInsets.all(16),
        orElse:
            () => const Padding(padding: EdgeInsets.zero, child: SizedBox()),
      );
      expect(cardPadding.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('uses default margin when not specified', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppCard(child: Text('Test')))),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, equals(const EdgeInsets.all(8)));
    });

    testWidgets('applies custom border radius', (WidgetTester tester) async {
      const customRadius = 24.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(borderRadius: customRadius, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(
        decoration.borderRadius,
        equals(BorderRadius.circular(customRadius)),
      );
    });

    testWidgets('shows InkWell when onTap is provided', (
      WidgetTester tester,
    ) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => wasTapped = true,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('does not show InkWell when onTap is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppCard(child: Text('Test')))),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('applies selected styling when isSelected is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppCard(isSelected: true, child: Text('Test'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;

      // Selected cards should have a thicker border (width: 2)
      expect(border.top.width, equals(2));
    });

    testWidgets('applies unselected styling when isSelected is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppCard(child: Text('Test')))),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;

      // Unselected cards should have a thinner border (width: 1)
      expect(border.top.width, equals(1));
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(backgroundColor: customColor, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });

    testWidgets('applies custom border color', (WidgetTester tester) async {
      const customBorderColor = Colors.blue;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(borderColor: customBorderColor, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;
      expect(border.top.color, equals(customBorderColor));
    });

    testWidgets('applies elevation with box shadow', (
      WidgetTester tester,
    ) async {
      const customElevation = 8.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(elevation: customElevation, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
      expect(decoration.boxShadow!.first.blurRadius, equals(customElevation));
    });

    testWidgets('has no box shadow when elevation is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppCard(child: Text('Test')))),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });
  });
}
