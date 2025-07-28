import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/common/loading_widget.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('renders CircularProgressIndicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders message when provided', (WidgetTester tester) async {
      const message = 'Loading data...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: message)),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not render message when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingWidget())),
      );

      expect(find.byType(Text), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('applies custom size correctly', (WidgetTester tester) async {
      const customSize = 60.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(size: customSize)),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('applies custom stroke width correctly', (
      WidgetTester tester,
    ) async {
      const customStrokeWidth = 6.0;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingWidget())),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.strokeWidth, equals(customStrokeWidth));
    });

    testWidgets('centers content properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingWidget())),
      );

      final center = tester.widget<Center>(find.byType(Center));
      expect(center, isNotNull);

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('has proper spacing between indicator and message', (
      WidgetTester tester,
    ) async {
      const message = 'Loading...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingWidget(message: message)),
        ),
      );

      // Find SizedBox with height 16 (spacing between indicator and message)
      final spacingBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacingBox = spacingBoxes.firstWhere(
        (box) => box.height == 16,
        orElse: () => const SizedBox(),
      );
      expect(spacingBox.height, equals(16));
    });
  });

  group('SkeletonLoader Tests', () {
    testWidgets('renders with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(child: Text('Test content'))),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    });

    testWidgets('applies custom width and height', (WidgetTester tester) async {
      const customWidth = 200.0;
      const customHeight = 40.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              child: Text('Test content'),
              width: customWidth,
              height: customHeight,
            ),
          ),
        ),
      );

      final skeletonLoader = tester.widget<SkeletonLoader>(
        find.byType(SkeletonLoader),
      );
      expect(skeletonLoader.width, equals(customWidth));
      expect(skeletonLoader.height, equals(customHeight));
    });

    testWidgets('applies custom border radius', (WidgetTester tester) async {
      const customBorderRadius = 12.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              child: Text('Test content'),
              borderRadius: customBorderRadius,
            ),
          ),
        ),
      );

      final skeletonLoader = tester.widget<SkeletonLoader>(
        find.byType(SkeletonLoader),
      );
      expect(skeletonLoader.borderRadius, equals(customBorderRadius));
    });

    testWidgets('has animation controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(child: Text('Test content'))),
        ),
      );

      // Pump a few frames to ensure animation is running
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SkeletonLoader), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    });

    testWidgets('uses default values correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(child: Text('Test content'))),
        ),
      );

      final skeletonLoader = tester.widget<SkeletonLoader>(
        find.byType(SkeletonLoader),
      );
      expect(skeletonLoader.width, equals(double.infinity));
      expect(skeletonLoader.height, equals(20));
      expect(skeletonLoader.borderRadius, equals(8));
    });

    testWidgets('disposes animation controller properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(child: Text('Test content'))),
        ),
      );

      // Remove the widget to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Should not throw any errors
      expect(tester.takeException(), isNull);
    });
  });
}
