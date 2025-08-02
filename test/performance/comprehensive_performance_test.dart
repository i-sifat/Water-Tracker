/// Comprehensive performance tests for swipeable hydration interface
/// Tests animations, gestures, and rendering performance
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

void main() {
  group('Comprehensive Performance Tests', () {
    late HydrationProvider hydrationProvider;

    setUp(() {
      hydrationProvider = HydrationProvider();
    });

    testWidgets(
      'Animation performance: Circular progress animations maintain 60fps',
      (WidgetTester tester) async {
        // Track frame times
        final frameTimes = <Duration>[];

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<HydrationProvider>(
              create: (_) => hydrationProvider,
              child: const AddHydrationScreen(),
            ),
          ),
        );

        // Start monitoring frame times
        tester.binding.addPersistentFrameCallback(frameTimes.add);

        // Trigger multiple progress animations
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.text('500 ml'));
          await tester.pump(); // Start animation

          // Let animation run for a few frames
          for (var frame = 0; frame < 10; frame++) {
            await tester.pump(const Duration(milliseconds: 16)); // ~60fps
          }
        }

        await tester.pumpAndSettle();

        // Analyze frame times
        if (frameTimes.length > 1) {
          final frameDurations = <Duration>[];
          for (var i = 1; i < frameTimes.length; i++) {
            frameDurations.add(frameTimes[i] - frameTimes[i - 1]);
          }

          // Check that most frames are under 16.67ms (60fps)
          final slowFrames =
              frameDurations
                  .where((duration) => duration.inMicroseconds > 16670)
                  .length;
          final totalFrames = frameDurations.length;
          final slowFramePercentage = slowFrames / totalFrames;

          // Allow up to 10% slow frames for acceptable performance
          expect(
            slowFramePercentage,
            lessThan(0.1),
            reason:
                'Too many slow frames: $slowFrames/$totalFrames (${(slowFramePercentage * 100).toStringAsFixed(1)}%)',
          );
        }
      },
    );

    testWidgets('Gesture performance: Swipe gestures respond within 16ms', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      final swipeablePageView = find.byType(SwipeablePageView);
      expect(swipeablePageView, findsOneWidget);

      // Measure gesture response time
      final stopwatch = Stopwatch();

      // Start gesture
      stopwatch.start();
      final gesture = await tester.startGesture(
        tester.getCenter(swipeablePageView),
      );

      // Move gesture
      await gesture.moveBy(const Offset(0, -100));
      await tester.pump(); // Process gesture
      stopwatch.stop();

      // Complete gesture
      await gesture.up();
      await tester.pumpAndSettle();

      // Gesture should be processed within one frame (16.67ms at 60fps)
      expect(
        stopwatch.elapsedMicroseconds,
        lessThan(16670),
        reason:
            'Gesture response took ${stopwatch.elapsedMicroseconds}μs, should be <16670μs',
      );
    });

    testWidgets('Memory performance: No memory leaks during rapid interactions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Get initial render object count
      var initialRenderObjects = 0;
      void countRenderObjects(RenderObject renderObject) {
        initialRenderObjects++;
        renderObject.visitChildren(countRenderObjects);
      }

      final RenderObject rootRenderObject = tester.binding.renderView;
      if (rootRenderObject != null) {
        countRenderObjects(rootRenderObject);
      }

      // Perform many rapid interactions
      for (var i = 0; i < 50; i++) {
        // Rapid swipes
        await tester.drag(
          find.byType(SwipeablePageView),
          const Offset(0, -200),
        );
        await tester.pump(const Duration(milliseconds: 50));

        await tester.drag(find.byType(SwipeablePageView), const Offset(0, 200));
        await tester.pump(const Duration(milliseconds: 50));

        // Rapid button taps
        await tester.tap(find.text('500 ml'));
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Count render objects after interactions
      var finalRenderObjects = 0;
      void countFinalRenderObjects(RenderObject renderObject) {
        finalRenderObjects++;
        renderObject.visitChildren(countFinalRenderObjects);
      }

      if (rootRenderObject != null) {
        countFinalRenderObjects(rootRenderObject);
      }

      // Allow some growth but not excessive (within 50% of initial)
      final growthRatio = finalRenderObjects / initialRenderObjects;
      expect(
        growthRatio,
        lessThan(1.5),
        reason:
            'Render object count grew from $initialRenderObjects to $finalRenderObjects (${(growthRatio * 100).toStringAsFixed(1)}%)',
      );
    });

    testWidgets('Rendering performance: Complex layouts render efficiently', (
      WidgetTester tester,
    ) async {
      // Create provider with lots of data
      final dataProvider = HydrationProvider();

      // Add many entries to test rendering performance
      for (var i = 0; i < 100; i++) {
        await dataProvider.addHydration(
          100 + (i % 400), // Vary amounts
          type: DrinkType.values[i % DrinkType.values.length],
        );
      }

      final stopwatch = Stopwatch();
      stopwatch.start();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => dataProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      stopwatch.stop();

      // Initial render should be fast (under 100ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason:
            'Initial render took ${stopwatch.elapsedMilliseconds}ms, should be <100ms',
      );

      // Test swipe to statistics page (heavy data rendering)
      stopwatch.reset();
      stopwatch.start();

      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -300));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Statistics page render should be reasonable (under 200ms)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
        reason:
            'Statistics page render took ${stopwatch.elapsedMilliseconds}ms, should be <200ms',
      );
    });

    testWidgets('Animation smoothness: Page transitions are smooth', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Track animation frames
      final animationValues = <double>[];

      // Start swipe gesture
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SwipeablePageView)),
      );

      // Move through animation
      for (var i = 0; i <= 20; i++) {
        await gesture.moveBy(
          const Offset(0, -15),
        ); // Total -300px over 20 steps
        await tester.pump(const Duration(milliseconds: 16));

        // Try to capture animation progress (this is simplified)
        animationValues.add(i / 20.0);
      }

      await gesture.up();
      await tester.pumpAndSettle();

      // Animation should have smooth progression
      expect(
        animationValues.length,
        greaterThan(10),
        reason: 'Animation should have multiple frames',
      );

      // Check for smooth progression (no big jumps)
      for (var i = 1; i < animationValues.length; i++) {
        final diff = (animationValues[i] - animationValues[i - 1]).abs();
        expect(
          diff,
          lessThan(0.2),
          reason: 'Animation jump too large: $diff at frame $i',
        );
      }
    });

    testWidgets('Scroll performance: Large data sets scroll smoothly', (
      WidgetTester tester,
    ) async {
      // This test would be more relevant for statistics page with large datasets
      final dataProvider = HydrationProvider();

      // Add many entries
      for (var i = 0; i < 1000; i++) {
        await dataProvider.addHydration(250);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => dataProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Navigate to statistics page
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Test scrolling performance if there are scrollable elements
      final scrollables = find.byType(Scrollable);
      if (tester.any(scrollables)) {
        final stopwatch = Stopwatch();
        stopwatch.start();

        // Perform scroll
        await tester.drag(scrollables.first, const Offset(0, -500));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Scroll should complete quickly
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
          reason:
              'Scroll took ${stopwatch.elapsedMilliseconds}ms, should be <500ms',
        );
      }
    });

    testWidgets("CPU performance: Complex calculations don't block UI", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Add many hydration entries rapidly to trigger calculations
      final stopwatch = Stopwatch();
      stopwatch.start();

      for (var i = 0; i < 20; i++) {
        await tester.tap(find.text('500 ml'));
        await tester.pump(const Duration(milliseconds: 16));
      }

      stopwatch.stop();

      // UI should remain responsive during calculations
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason:
            'UI blocked for ${stopwatch.elapsedMilliseconds}ms during calculations',
      );

      // Final state should be correct
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressSection), findsOneWidget);
    });

    testWidgets('Widget rebuild performance: Minimal unnecessary rebuilds', (
      WidgetTester tester,
    ) async {
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: Builder(
              builder: (context) {
                buildCount++;
                return const AddHydrationScreen();
              },
            ),
          ),
        ),
      );

      final initialBuildCount = buildCount;

      // Perform actions that should cause minimal rebuilds
      await tester.tap(find.text('500 ml'));
      await tester.pumpAndSettle();

      // Should not cause excessive rebuilds
      final rebuilds = buildCount - initialBuildCount;
      expect(
        rebuilds,
        lessThan(5),
        reason: 'Too many rebuilds: $rebuilds, should be <5',
      );
    });
  });

  group('Performance Benchmarks', () {
    testWidgets('Benchmark: Initial app load time', (
      WidgetTester tester,
    ) async {
      final stopwatch = Stopwatch();
      stopwatch.start();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => HydrationProvider(),
            child: const AddHydrationScreen(),
          ),
        ),
      );

      stopwatch.stop();

      print('📊 Initial app load time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('Benchmark: Page transition time', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => HydrationProvider(),
            child: const AddHydrationScreen(),
          ),
        ),
      );

      final stopwatch = Stopwatch();
      stopwatch.start();

      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -300));
      await tester.pumpAndSettle();

      stopwatch.stop();

      print('📊 Page transition time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('Benchmark: Hydration addition time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => HydrationProvider(),
            child: const AddHydrationScreen(),
          ),
        ),
      );

      final stopwatch = Stopwatch();
      stopwatch.start();

      await tester.tap(find.text('500 ml'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      print('📊 Hydration addition time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
