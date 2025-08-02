import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Utility class for performance monitoring and optimization
/// Provides tools for measuring frame rates, memory usage, and animation performance
class PerformanceUtils {
  static const bool _enableProfiling = kDebugMode;

  /// Measure the execution time of a function
  static Future<T> measureExecutionTime<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    if (!_enableProfiling) {
      return operation();
    }

    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      developer.log(
        'Performance: $operationName completed in ${stopwatch.elapsedMilliseconds}ms',
        name: 'PerformanceUtils',
      );

      return result;
    } catch (e) {
      stopwatch.stop();
      developer.log(
        'Performance: $operationName failed after ${stopwatch.elapsedMilliseconds}ms - $e',
        name: 'PerformanceUtils',
        error: e,
      );
      rethrow;
    }
  }

  /// Measure synchronous execution time
  static T measureSyncExecutionTime<T>(
    String operationName,
    T Function() operation,
  ) {
    if (!_enableProfiling) {
      return operation();
    }

    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      developer.log(
        'Performance: $operationName completed in ${stopwatch.elapsedMilliseconds}ms',
        name: 'PerformanceUtils',
      );

      return result;
    } catch (e) {
      stopwatch.stop();
      developer.log(
        'Performance: $operationName failed after ${stopwatch.elapsedMilliseconds}ms - $e',
        name: 'PerformanceUtils',
        error: e,
      );
      rethrow;
    }
  }

  /// Create a performance-optimized RepaintBoundary widget
  static Widget optimizedRepaintBoundary({
    required Widget child,
    String? debugLabel,
  }) {
    if (_enableProfiling && debugLabel != null) {
      return RepaintBoundary(
        child: Builder(
          builder: (context) {
            developer.log(
              'RepaintBoundary: $debugLabel rendered',
              name: 'PerformanceUtils',
            );
            return child;
          },
        ),
      );
    }

    return RepaintBoundary(child: child);
  }

  /// Monitor animation performance
  static void monitorAnimation(
    AnimationController controller,
    String animationName,
  ) {
    if (!_enableProfiling) return;

    controller.addStatusListener((status) {
      developer.log(
        'Animation: $animationName status changed to $status',
        name: 'PerformanceUtils',
      );
    });
  }

  /// Log memory usage information
  static void logMemoryUsage(String context) {
    if (!_enableProfiling) return;

    developer.log(
      'Memory: $context - Check DevTools for detailed memory usage',
      name: 'PerformanceUtils',
    );
  }

  /// Create a performance-monitored animation controller
  static AnimationController createMonitoredAnimationController({
    required Duration duration,
    required TickerProvider vsync,
    String? debugLabel,
    double? value,
    Duration? reverseDuration,
    AnimationBehavior? animationBehavior,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
      value: value,
      reverseDuration: reverseDuration,
      animationBehavior: animationBehavior ?? AnimationBehavior.normal,
      debugLabel: debugLabel,
    );

    if (_enableProfiling && debugLabel != null) {
      monitorAnimation(controller, debugLabel);
    }

    return controller;
  }

  /// Measure widget build performance
  static Widget measureBuildPerformance({
    required Widget child,
    required String widgetName,
  }) {
    if (!_enableProfiling) {
      return child;
    }

    return Builder(
      builder: (context) {
        final stopwatch = Stopwatch()..start();

        return StatefulBuilder(
          builder: (context, setState) {
            final result = child;
            stopwatch.stop();

            developer.log(
              'Build Performance: $widgetName built in ${stopwatch.elapsedMicroseconds}μs',
              name: 'PerformanceUtils',
            );

            return result;
          },
        );
      },
    );
  }

  /// Check if frame rate is maintaining 60fps
  static void checkFrameRate() {
    if (!_enableProfiling) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      _lastFrameTime ??= now;

      final frameDuration = now - _lastFrameTime!;
      _lastFrameTime = now;

      if (frameDuration > 16.67) {
        // More than 60fps threshold
        developer.log(
          'Performance Warning: Frame took ${frameDuration}ms (target: 16.67ms)',
          name: 'PerformanceUtils',
        );
      }
    });
  }

  static int? _lastFrameTime;

  /// Performance benchmark for gesture handling
  static void benchmarkGesture(
    String gestureName,
    VoidCallback gestureHandler,
  ) {
    if (!_enableProfiling) {
      gestureHandler();
      return;
    }

    final stopwatch = Stopwatch()..start();
    gestureHandler();
    stopwatch.stop();

    developer.log(
      'Gesture Performance: $gestureName handled in ${stopwatch.elapsedMicroseconds}μs',
      name: 'PerformanceUtils',
    );
  }

  /// Cache for expensive calculations
  static final Map<String, dynamic> _calculationCache = {};

  /// Cache expensive calculations
  static T cacheCalculation<T>(String key, T Function() calculation) {
    if (_calculationCache.containsKey(key)) {
      if (_enableProfiling) {
        developer.log('Cache Hit: $key', name: 'PerformanceUtils');
      }
      return _calculationCache[key] as T;
    }

    final result = calculation();
    _calculationCache[key] = result;

    if (_enableProfiling) {
      developer.log(
        'Cache Miss: $key calculated and cached',
        name: 'PerformanceUtils',
      );
    }

    return result;
  }

  /// Clear calculation cache
  static void clearCache() {
    _calculationCache.clear();
    if (_enableProfiling) {
      developer.log('Cache cleared', name: 'PerformanceUtils');
    }
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _calculationCache.length,
      'keys': _calculationCache.keys.toList(),
    };
  }
}

/// Mixin for widgets that need performance monitoring
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  late final Stopwatch _buildStopwatch = Stopwatch();

  @override
  Widget build(BuildContext context) {
    _buildStopwatch.start();
    final result = performanceBuild(context);
    _buildStopwatch.stop();

    if (kDebugMode) {
      developer.log(
        'Build Performance: ${widget.runtimeType} built in ${_buildStopwatch.elapsedMicroseconds}μs',
        name: 'PerformanceMonitorMixin',
      );
    }

    _buildStopwatch.reset();
    return result;
  }

  /// Override this method instead of build() when using the mixin
  Widget performanceBuild(BuildContext context);
}

/// Performance-optimized StatefulWidget base class
abstract class PerformanceOptimizedWidget extends StatefulWidget {
  const PerformanceOptimizedWidget({super.key});

  @override
  PerformanceOptimizedState createState();
}

abstract class PerformanceOptimizedState<T extends PerformanceOptimizedWidget>
    extends State<T>
    with PerformanceMonitorMixin<T> {
  /// List of animation controllers to dispose
  final List<AnimationController> _animationControllers = [];

  /// Register an animation controller for automatic disposal
  void registerAnimationController(AnimationController controller) {
    _animationControllers.add(controller);
  }

  @override
  void dispose() {
    // Dispose all registered animation controllers
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    _animationControllers.clear();

    super.dispose();
  }
}
