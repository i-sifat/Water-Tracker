import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/adaptive_widgets.dart';

void main() {
  group('AdaptiveText', () {
    testWidgets('should render text with responsive font size', (
      WidgetTester tester,
    ) async {
      const testText = 'Adaptive Text';

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AdaptiveText(testText))),
      );

      expect(find.text(testText), findsOneWidget);

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, greaterThan(0));
    });

    testWidgets('should apply custom text style', (WidgetTester tester) async {
      const testText = 'Styled Text';
      const customStyle = TextStyle(
        fontSize: 20.0,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AdaptiveText(testText, style: customStyle)),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, Colors.red);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.fontSize, greaterThan(0));
    });

    testWidgets('should apply scale factor', (WidgetTester tester) async {
      const testText = 'Scaled Text';
      const scaleFactor = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveText(testText, scaleFactor: scaleFactor),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(
        textWidget.style?.fontSize,
        greaterThan(14.0),
      ); // Should be scaled up
    });

    testWidgets('should handle text properties', (WidgetTester tester) async {
      const testText =
          'Long text that might overflow and need special handling';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveText(
              testText,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              semanticsLabel: 'Semantic label',
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.textAlign, TextAlign.center);
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 2);
      expect(textWidget.semanticsLabel, 'Semantic label');
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('should render container with child', (
      WidgetTester tester,
    ) async {
      const childText = 'Container Child';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ResponsiveContainer(child: Text(childText))),
        ),
      );

      expect(find.text(childText), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should apply responsive dimensions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              width: 100.0,
              height: 50.0,
              child: Container(),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, greaterThan(0));
    });

    testWidgets('should apply decoration', (WidgetTester tester) async {
      const decoration = BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              decoration: decoration,
              child: Container(),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, decoration);
    });

    testWidgets('should handle alignment and transform', (
      WidgetTester tester,
    ) async {
      final transform = Matrix4.rotationZ(0.1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              alignment: Alignment.center,
              transform: transform,
              transformAlignment: Alignment.center,
              child: Text('Transformed'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.alignment, Alignment.center);
      expect(container.transform, transform);
      expect(container.transformAlignment, Alignment.center);
    });
  });

  group('ResponsiveIcon', () {
    testWidgets('should render icon with responsive size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ResponsiveIcon(Icons.home, size: 24.0)),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, greaterThan(0));
    });

    testWidgets('should apply icon properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveIcon(
              Icons.star,
              color: Colors.yellow,
              semanticLabel: 'Star icon',
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, Colors.yellow);
      expect(iconWidget.semanticLabel, 'Star icon');
    });

    testWidgets('should apply scale factor', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveIcon(Icons.settings, size: 24.0, scaleFactor: 2.0),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, greaterThan(24.0)); // Should be scaled up
    });
  });

  group('ResponsiveCard', () {
    testWidgets('should render card with child', (WidgetTester tester) async {
      const childText = 'Card Content';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ResponsiveCard(child: Text(childText))),
        ),
      );

      expect(find.text(childText), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should apply card properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveCard(
              color: Colors.blue,
              elevation: 8.0,
              child: Text('Card'),
            ),
          ),
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, Colors.blue);
      expect(cardWidget.elevation, 8.0);
    });

    testWidgets('should apply responsive padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveCard(
              padding: EdgeInsets.all(16.0),
              child: Text('Padded Card'),
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
      expect(find.text('Padded Card'), findsOneWidget);
    });
  });

  group('ResponsiveButton', () {
    testWidgets('should render elevated button by default', (
      WidgetTester tester,
    ) async {
      const buttonText = 'Click Me';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(text: buttonText, onPressed: () {}),
          ),
        ),
      );

      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render outlined button', (WidgetTester tester) async {
      const buttonText = 'Outlined';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(
              text: buttonText,
              type: ResponsiveButtonType.outlined,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should render text button', (WidgetTester tester) async {
      const buttonText = 'Text Button';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(
              text: buttonText,
              type: ResponsiveButtonType.text,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should handle button press', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(
              text: 'Press Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, true);
    });

    testWidgets('should apply custom colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(
              text: 'Colored Button',
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;

      expect(style.backgroundColor?.resolve({}), Colors.red);
      expect(style.foregroundColor?.resolve({}), Colors.white);
    });

    testWidgets('should be disabled when onPressed is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(text: 'Disabled Button', onPressed: null),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });

  group('ResponsiveImage', () {
    testWidgets('should create responsive image widget', (
      WidgetTester tester,
    ) async {
      // Test that the widget can be created without errors
      const responsiveImage = ResponsiveImage(
        image: NetworkImage('https://example.com/image.png'),
        width: 100.0,
        height: 100.0,
      );

      expect(responsiveImage, isA<ResponsiveImage>());
      expect(responsiveImage.width, 100.0);
      expect(responsiveImage.height, 100.0);
      expect(responsiveImage.applyResponsiveSizing, true);
    });

    testWidgets('should handle responsive image properties', (
      WidgetTester tester,
    ) async {
      const responsiveImage = ResponsiveImage(
        image: NetworkImage('https://example.com/image.png'),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        semanticLabel: 'Test image',
        scaleFactor: 1.5,
        applyResponsiveSizing: false,
      );

      expect(responsiveImage.fit, BoxFit.cover);
      expect(responsiveImage.alignment, Alignment.topCenter);
      expect(responsiveImage.semanticLabel, 'Test image');
      expect(responsiveImage.scaleFactor, 1.5);
      expect(responsiveImage.applyResponsiveSizing, false);
    });
  });
}
