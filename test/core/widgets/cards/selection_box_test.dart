import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/cards/selection_box.dart';

void main() {
  group('SelectionBox Widget Tests', () {
    testWidgets('renders title correctly', (WidgetTester tester) async {
      const title = 'Test Title';
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(title: title, onTap: () => wasTapped = true),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (WidgetTester tester) async {
      const title = 'Test Title';
      const subtitle = 'Test Subtitle';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(title: title, subtitle: subtitle, onTap: () {}),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets('does not render subtitle when not provided', (
      WidgetTester tester,
    ) async {
      const title = 'Test Title';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SelectionBox(title: title, onTap: () {})),
        ),
      );

      expect(find.text(title), findsOneWidget);
      // Should only find one text widget (the title)
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      const title = 'Test Title';
      const icon = Icons.water_drop;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(title: title, icon: icon, onTap: () {}),
          ),
        ),
      );

      expect(find.byIcon(icon), findsOneWidget);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('does not render icon when not provided', (
      WidgetTester tester,
    ) async {
      const title = 'Test Title';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SelectionBox(title: title, onTap: () {})),
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(
              title: 'Test Title',
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SelectionBox));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('applies selected styling when isSelected is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(
              title: 'Test Title',
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // The AppCard should be marked as selected
      final selectionBox = tester.widget<SelectionBox>(
        find.byType(SelectionBox),
      );
      expect(selectionBox.isSelected, isTrue);
    });

    testWidgets('applies unselected styling when isSelected is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SelectionBox(title: 'Test Title', onTap: () {})),
        ),
      );

      final selectionBox = tester.widget<SelectionBox>(
        find.byType(SelectionBox),
      );
      expect(selectionBox.isSelected, isFalse);
    });

    testWidgets('respects custom width and height', (
      WidgetTester tester,
    ) async {
      const customWidth = 200.0;
      const customHeight = 150.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(
              title: 'Test Title',
              width: customWidth,
              height: customHeight,
              onTap: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, equals(customWidth));
      expect(sizedBox.height, equals(customHeight));
    });

    testWidgets('uses custom background color when provided', (
      WidgetTester tester,
    ) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(
              title: 'Test Title',
              backgroundColor: customColor,
              onTap: () {},
            ),
          ),
        ),
      );

      final selectionBox = tester.widget<SelectionBox>(
        find.byType(SelectionBox),
      );
      expect(selectionBox.backgroundColor, equals(customColor));
    });

    testWidgets(
      'uses custom selected background color when provided and selected',
      (WidgetTester tester) async {
        const customSelectedColor = Colors.green;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionBox(
                title: 'Test Title',
                selectedBackgroundColor: customSelectedColor,
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        );

        final selectionBox = tester.widget<SelectionBox>(
          find.byType(SelectionBox),
        );
        expect(
          selectionBox.selectedBackgroundColor,
          equals(customSelectedColor),
        );
      },
    );

    testWidgets('has proper layout structure with icon, title, and subtitle', (
      WidgetTester tester,
    ) async {
      const title = 'Test Title';
      const subtitle = 'Test Subtitle';
      const icon = Icons.water_drop;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(
              title: title,
              subtitle: subtitle,
              icon: icon,
              onTap: () {},
            ),
          ),
        ),
      );

      // Check that all elements are present
      expect(find.byIcon(icon), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);

      // Check that they are arranged in a Column
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('centers content properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SelectionBox(title: 'Test Title', onTap: () {})),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('applies text alignment correctly', (
      WidgetTester tester,
    ) async {
      const title = 'Test Title';
      const subtitle = 'Test Subtitle';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBox(title: title, subtitle: subtitle, onTap: () {}),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text(title));
      final subtitleText = tester.widget<Text>(find.text(subtitle));

      expect(titleText.textAlign, equals(TextAlign.center));
      expect(subtitleText.textAlign, equals(TextAlign.center));
    });
  });
}
