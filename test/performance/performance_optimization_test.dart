import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/utils/animation_cache.dart';
import 'package:watertracker/core/utils/performance_utils.dart';
import 'package:watertracker/core/utils/widget_cache.dart';
import 'package:watertracker/core/widgets/animations/water_animation.dart';
import 'package:watertracker/core/widgets/performance/performance_monitor.dart';

void main() {
  group('Performance Optimization Tests', () {
    testWidgets('RepaintBoundary optimization works', (
      WidgetTester tester,
    ) async {
      // Test that RepaintBoundary is properly applied
      final widget = PerformanceUtils.optimizedRepaintBoundary(
        debugLabel: 'TestWidget',
        child: Container(width: 100, height: 100, color: Colors.blue),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      // Verify RepaintBoundary is present
      expect(find.byType(RepaintBoundary), findsOneWidget);
    });

    testWidgets('WaterAnimation has RepaintBoundary', (
      WidgetTester tester,
    ) async {
      const waterAnimation = WaterAnimation(
        progress: 0.5,
        waterColor: Colors.blue,
        backgroundColor: Colors.grey,
        width: 200,
        height: 300,
      );

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: waterAnimation)),
      );

      // Verify RepaintBoundary is present in WaterAnimation
      expect(find.byType(RepaintBoundary), findsOneWidget);
    });

    test('Animation cache stores and retrieves animations', () {
      // Test animation caching
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );

      final tween = AnimationCache.getCachedTween(
        key: 'test_tween',
        begin: 0,
        end: 1,
      );

      expect(tween.begin, equals(0));
      expect(tween.end, equals(1));

      // Test that same tween is returned from cache
      final cachedTween = AnimationCache.getCachedTween(
        key: 'test_tween',
        begin: 0,
        end: 1,
      );

      expect(identical(tween, cachedTween), isTrue);

      controller.dispose();
    });

    test('Widget cache stores and retrieves widgets', () {
      const testWidget = Icon(Icons.star);
      const cacheKey = 'test_icon';

      // Cache the widget
      WidgetCache.cacheWidget(cacheKey, testWidget);

      // Retrieve from cache
      final cachedWidget = WidgetCache.getCachedWidget(cacheKey);

      expect(cachedWidget, isNotNull);
      expect(identical(testWidget, cachedWidget), isTrue);
    });

    test('Widget cache respects size limits', () {
      // Set a small cache size for testing
      WidgetCache.setMaxCacheSize(2);

      // Add widgets to exceed cache size
      WidgetCache.cacheWidget('widget1', const Icon(Icons.star));
      WidgetCache.cacheWidget('widget2', const Icon(Icons.favorite));
      WidgetCache.cacheWidget('widget3', const Icon(Icons.home));

      // First widget should be evicted
      expect(WidgetCache.getCachedWidget('widget1'), isNull);
      expect(WidgetCache.getCachedWidget('widget2'), isNotNull);
      expect(WidgetCache.getCachedWidget('widget3'), isNotNull);

      // Clean up
      WidgetCache.clearCache();
    });

    testWidgets('Performance monitor tracks build times', (
      WidgetTester tester,
    ) async {
      const monitoredWidget = PerformanceMonitor(
        name: 'TestWidget',
        child: Text('Test'),
      );

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: monitoredWidget)),
      );

      // Verify the widget builds without errors
      expect(find.text('Test'), findsOneWidget);
    });

    test('CommonAnimations provides cached animations', () {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );

      final tapAnimation = CommonAnimations.getTapScaleAnimation(
        controller: controller,
      );

      expect(tapAnimation, isNotNull);
      expect(tapAnimation.value, equals(1)); // Initial value

      final fadeAnimation = CommonAnimations.getFadeAnimation(
        controller: controller,
      );

      expect(fadeAnimation, isNotNull);
      expect(fadeAnimation.value, equals(0)); // Initial value

      controller.dispose();
    });

    test('Performance utils cache statistics', () {
      // Clear cache first
      WidgetCache.clearCache();

      // Add some items
      WidgetCache.cacheWidget('test1', const Icon(Icons.star));
      WidgetCache.cacheWidget('test2', const Icon(Icons.favorite));

      final stats = WidgetCache.getCacheStats();
      expect(stats['widgets'], equals(2));
      expect(stats['maxSize'], isNotNull);

      // Clean up
      WidgetCache.clearCache();
    });
  });
}

class TestVSync implements TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
