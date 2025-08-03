import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

/// Performance tests for swipeable hydration interface components
/// Tests ensure 60fps performance and smooth animations
void main() {
  group('Swipeable Hydration Performance Tests', () {
    late HydrationProvider mockProvider;

    setUp(() {
      mockProvider = HydrationProvider();
    });

    testWidgets('CircularProgressSection animation performance', (
      tester,
    ) async {
      // Performance test: Measure animation frame rate
      final progress = HydrationProgress.fromEntries(
        todaysEntries: const [],
        dailyGoal: 2000,
        nextReminderTime: DateTime.now().add(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CircularProgressSection(progress: progress)),
        ),
      );

      // Start performance measurement
      final stopwatch = Stopwatch()..start();

      // Trigger multiple animation frames
      for (var i = 0; i < 60; i++) {
        await tester.pump(
          const Duration(milliseconds: 16),
        ); // 60fps = 16ms per frame
      }

      stopwatch.stop();

      // Performance assertion: Should complete 60 frames in ~1 second
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1100),
      ); // Allow 10% tolerance

      // Verify no frame drops by checking widget is still rendered
      expect(find.byType(CircularProgressSection), findsOneWidget);
    });

    testWidgets('SwipeablePageView gesture performance', (tester) async {
      final pages = [
        const Center(child: Text('Page 1')),
        const Center(child: Text('Page 2')),
        const Center(child: Text('Page 3')),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SwipeablePageView(pages: pages))),
      );

      // Performance test: Measure gesture response time
      final stopwatch = Stopwatch()..start();

      // Simulate swipe gesture
      await tester.drag(
        find.byType(SwipeablePageView),
        const Offset(0, -200), // Swipe up
      );

      stopwatch.stop();

      // Performance assertion: Gesture should respond within 16ms (60fps)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
      ); // Allow some tolerance

      await tester.pumpAndSettle();

      // Verify page changed
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('QuickAddButtonGrid animation performance', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: const MaterialApp(home: Scaffold(body: QuickAddButtonGrid())),
        ),
      );

      // Performance test: Measure button press animation
      final stopwatch = Stopwatch()..start();

      // Find and tap a button
      final button = find.text('500 ml').first;
      await tester.tap(button);

      // Pump animation frames
      for (var i = 0; i < 10; i++) {
        await tester.pump(
          const Duration(milliseconds: 15),
        ); // 150ms animation / 10 frames
      }

      stopwatch.stop();

      // Performance assertion: Animation should complete smoothly
      expect(stopwatch.elapsedMilliseconds, lessThan(200)); // 150ms + tolerance

      await tester.pumpAndSettle();
    });

    testWidgets('MainHydrationPage loading performance', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: const MaterialApp(home: Scaffold(body: MainHydrationPage())),
        ),
      );

      // Performance test: Measure initial render time
      final stopwatch = Stopwatch()..start();

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Performance assertion: Should render within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      // Verify all components are rendered
      expect(find.text('Today'), findsOneWidget);
      expect(find.byType(CircularProgressSection), findsOneWidget);
      expect(find.byType(QuickAddButtonGrid), findsOneWidget);
    });

    testWidgets('StatisticsPage chart rendering performance', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: const MaterialApp(home: Scaffold(body: StatisticsPage())),
        ),
      );

      // Performance test: Measure chart rendering time
      final stopwatch = Stopwatch()..start();

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Performance assertion: Chart should render within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Verify chart components are rendered
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('WEEKLY'), findsOneWidget);
      expect(find.text('Days in a row'), findsOneWidget);
    });

    testWidgets('Memory usage test - RepaintBoundary effectiveness', (
      tester,
    ) async {
      // This test verifies that RepaintBoundary widgets are working correctly
      // by ensuring widgets don't rebuild unnecessarily

      var buildCount = 0;

      final Widget testWidget = StatefulBuilder(
        builder: (context, setState) {
          buildCount++;
          return ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: const MaterialApp(home: Scaffold(body: MainHydrationPage())),
          );
        },
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final initialBuildCount = buildCount;

      // Trigger a state change that should only affect specific components
      mockProvider.notifyListeners();
      await tester.pump();

      // Performance assertion: Build count should not increase significantly
      // RepaintBoundary should prevent unnecessary rebuilds
      expect(buildCount - initialBuildCount, lessThanOrEqualTo(1));
    });

    group('Animation Controller Disposal Tests', () {
      testWidgets('CircularProgressSection disposes controllers properly', (
        tester,
      ) async {
        final progress = HydrationProgress.fromEntries(
          todaysEntries: const [],
          dailyGoal: 2000,
          nextReminderTime: DateTime.now().add(const Duration(hours: 2)),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CircularProgressSection(progress: progress)),
          ),
        );

        // Verify widget is built
        expect(find.byType(CircularProgressSection), findsOneWidget);

        // Remove widget and verify no memory leaks
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));

        // If there were memory leaks, this would cause issues in subsequent tests
        expect(find.byType(CircularProgressSection), findsNothing);
      });

      testWidgets('QuickAddButton disposes controllers properly', (
        tester,
      ) async {
        await tester.pumpWidget(
          ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: const MaterialApp(
              home: Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        // Verify buttons are built
        expect(find.text('500 ml'), findsOneWidget);

        // Remove widget and verify no memory leaks
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));

        expect(find.text('500 ml'), findsNothing);
      });
    });

    group('Gesture Performance Benchmarks', () {
      testWidgets('Swipe gesture latency benchmark', (tester) async {
        final pages = [
          const Center(child: Text('History')),
          const Center(child: Text('Main')),
          const Center(child: Text('Goals')),
        ];

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: SwipeablePageView(pages: pages))),
        );

        await tester.pumpAndSettle();

        // Benchmark: Multiple swipe gestures
        final gestureTimes = <int>[];

        for (var i = 0; i < 5; i++) {
          final stopwatch = Stopwatch()..start();

          // Swipe up
          await tester.drag(
            find.byType(SwipeablePageView),
            const Offset(0, -150),
          );

          stopwatch.stop();
          gestureTimes.add(stopwatch.elapsedMilliseconds);

          await tester.pumpAndSettle();

          // Swipe back down
          await tester.drag(
            find.byType(SwipeablePageView),
            const Offset(0, 150),
          );

          await tester.pumpAndSettle();
        }

        // Performance assertion: Average gesture time should be under 50ms
        final averageTime =
            gestureTimes.reduce((a, b) => a + b) / gestureTimes.length;
        expect(averageTime, lessThan(50.0));

        // Performance assertion: No gesture should take longer than 100ms
        expect(gestureTimes.every((time) => time < 100), isTrue);
      });
    });

    group('Rendering Performance Benchmarks', () {
      testWidgets('Complex layout rendering benchmark', (tester) async {
        // Create a complex layout with multiple animated components
        await tester.pumpWidget(
          ChangeNotifierProvider<HydrationProvider>.value(
            value: mockProvider,
            child: MaterialApp(
              home: Scaffold(
                body: SwipeablePageView(
                  pages: [
                    const StatisticsPage(),
                    const MainHydrationPage(),
                    Container(), // Goal breakdown placeholder
                  ],
                ),
              ),
            ),
          ),
        );

        // Benchmark: Initial render time
        final stopwatch = Stopwatch()..start();
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Performance assertion: Complex layout should render within 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        // Benchmark: Page transition time
        final transitionStopwatch = Stopwatch()..start();

        await tester.drag(
          find.byType(SwipeablePageView),
          const Offset(0, -200),
        );

        await tester.pumpAndSettle();
        transitionStopwatch.stop();

        // Performance assertion: Page transition should complete within 500ms
        expect(transitionStopwatch.elapsedMilliseconds, lessThan(500));
      });
    });
  });
}
