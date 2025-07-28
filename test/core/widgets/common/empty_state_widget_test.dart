import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/common/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Widget Tests', () {
    const testTitle = 'No Data Available';
    const testSubtitle = 'There is no data to display at the moment.';
    const testActionText = 'Refresh';

    testWidgets('renders with title only', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsNothing);
      expect(find.byType(PrimaryButton), findsNothing);
    });

    testWidgets('renders with title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              subtitle: testSubtitle,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
      expect(find.byType(PrimaryButton), findsNothing);
    });

    testWidgets('renders with icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              icon: Icons.inbox,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('renders with custom illustration when provided', (WidgetTester tester) async {
      const customIllustration = Icon(Icons.star, size: 100);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              illustration: customIllustration,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('renders action button when provided', (WidgetTester tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              actionText: testActionText,
              onActionPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.text(testActionText), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('does not render action button when onActionPressed is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              actionText: testActionText,
            ),
          ),
        ),
      );

      expect(find.byType(PrimaryButton), findsNothing);
    });

    testWidgets('does not render action button when actionText is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PrimaryButton), findsNothing);
    });

    testWidgets('prefers illustration over icon', (WidgetTester tester) async {
      const customIllustration = Icon(Icons.star, size: 100);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              icon: Icons.inbox,
              illustration: customIllustration,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsNothing);
    });

    testWidgets('has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              subtitle: testSubtitle,
              icon: Icons.inbox,
            ),
          ),
        ),
      );

      // Should be centered
      expect(find.byType(Center), findsWidgets);
      
      // Should have padding
      expect(find.byType(Padding), findsWidgets);
      
      // Should have column layout
      expect(find.byType(Column), findsOneWidget);
      
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('has correct spacing between elements', (WidgetTester tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              subtitle: testSubtitle,
              icon: Icons.inbox,
              actionText: testActionText,
              onActionPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      
      // Should have spacing after icon (height: 24)
      final iconSpacing = sizedBoxes.where((box) => box.height == 24);
      expect(iconSpacing, isNotEmpty);

      // Should have spacing between title and subtitle (height: 8)
      final titleSubtitleSpacing = sizedBoxes.where((box) => box.height == 8);
      expect(titleSubtitleSpacing, isNotEmpty);

      // Should have spacing before action button (height: 32)
      final actionSpacing = sizedBoxes.where((box) => box.height == 32);
      expect(actionSpacing, isNotEmpty);
    });

    testWidgets('icon container has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              icon: Icons.inbox,
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final iconContainer = containers.firstWhere(
        (container) => container.decoration is BoxDecoration,
        orElse: Container.new,
      );

      final decoration = iconContainer.decoration as BoxDecoration?;
      expect(decoration?.shape, equals(BoxShape.circle));
    });

    testWidgets('action button has correct width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              actionText: testActionText,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      final primaryButton = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(primaryButton.width, equals(200));
    });

    testWidgets('text alignment is center', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: testTitle,
              subtitle: testSubtitle,
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text(testTitle));
      final subtitleText = tester.widget<Text>(find.text(testSubtitle));

      expect(titleText.textAlign, equals(TextAlign.center));
      expect(subtitleText.textAlign, equals(TextAlign.center));
    });
  });
}