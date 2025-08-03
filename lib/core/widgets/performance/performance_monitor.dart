import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Widget that monitors and reports performance metrics for expensive widgets
class PerformanceMonitor extends StatefulWidget {
  const PerformanceMonitor({
    required this.child,
    required this.name,
    super.key,
    this.enableFrameRateMonitoring = true,
    this.enableBuildTimeMonitoring = true,
    this.reportInterval = const Duration(seconds: 5),
  });

  final Widget child;
  final String name;
  final bool enableFrameRateMonitoring;
  final bool enableBuildTimeMonitoring;
  final Duration reportInterval;

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  final List<int> _frameTimes = [];
  final List<int> _buildTimes = [];
  int _frameCount = 0;
  int _droppedFrames = 0;
  DateTime? _lastReportTime;

  @override
  void initState() {
    super.initState();
    if (kDebugMode && widget.enableFrameRateMonitoring) {
      _startFrameRateMonitoring();
    }
  }

  void _startFrameRateMonitoring() {
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!mounted) return;

    _frameCount++;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Track frame times for performance analysis
    if (_frameTimes.isNotEmpty) {
      final frameDuration = now - _frameTimes.last;
      if (frameDuration > 16) {
        // More than 60fps threshold
        _droppedFrames++;
      }
    }

    _frameTimes.add(now);

    // Keep only last 100 frame times to prevent memory issues
    if (_frameTimes.length > 100) {
      _frameTimes.removeAt(0);
    }

    // Report performance metrics periodically
    _lastReportTime ??= DateTime.now();
    if (DateTime.now().difference(_lastReportTime!) >= widget.reportInterval) {
      _reportPerformanceMetrics();
      _lastReportTime = DateTime.now();
    }

    // Schedule next frame callback
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _reportPerformanceMetrics() {
    if (!kDebugMode) return;

    final avgBuildTime =
        _buildTimes.isNotEmpty
            ? _buildTimes.reduce((a, b) => a + b) / _buildTimes.length
            : 0;

    final frameRate =
        _frameCount > 0
            ? (1000 /
                (_frameTimes.length > 1
                    ? (_frameTimes.last - _frameTimes.first) /
                        (_frameTimes.length - 1)
                    : 16.67))
            : 0;

    developer.log(
      'Performance Report for ${widget.name}:\n'
      '  Frame Rate: ${frameRate.toStringAsFixed(1)} fps\n'
      '  Dropped Frames: $_droppedFrames\n'
      '  Avg Build Time: ${avgBuildTime.toStringAsFixed(2)}ms\n'
      '  Total Frames: $_frameCount',
      name: 'PerformanceMonitor',
    );

    // Reset counters
    _frameCount = 0;
    _droppedFrames = 0;
    _buildTimes.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !widget.enableBuildTimeMonitoring) {
      return widget.child;
    }

    final stopwatch = Stopwatch()..start();

    return StatefulBuilder(
      builder: (context, setState) {
        final result = widget.child;
        stopwatch.stop();

        _buildTimes.add(stopwatch.elapsedMicroseconds);

        // Keep only last 50 build times
        if (_buildTimes.length > 50) {
          _buildTimes.removeAt(0);
        }

        return result;
      },
    );
  }
}

/// Mixin for widgets that need automatic performance monitoring
mixin PerformanceMonitoringMixin<T extends StatefulWidget> on State<T> {
  late final Stopwatch _buildStopwatch = Stopwatch();
  int _buildCount = 0;
  final List<int> _buildTimes = [];

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return performanceBuild(context);
    }

    _buildStopwatch.start();
    final result = performanceBuild(context);
    _buildStopwatch.stop();

    _buildCount++;
    _buildTimes.add(_buildStopwatch.elapsedMicroseconds);

    // Keep only last 20 build times
    if (_buildTimes.length > 20) {
      _buildTimes.removeAt(0);
    }

    // Report every 10 builds
    if (_buildCount % 10 == 0) {
      final avgBuildTime =
          _buildTimes.reduce((a, b) => a + b) / _buildTimes.length;
      developer.log(
        'Build Performance: ${widget.runtimeType} - Avg: ${avgBuildTime.toStringAsFixed(2)}μs over ${_buildTimes.length} builds',
        name: 'PerformanceMonitoringMixin',
      );
    }

    _buildStopwatch.reset();
    return result;
  }

  /// Override this method instead of build() when using the mixin
  Widget performanceBuild(BuildContext context);
}

/// Performance-optimized wrapper for expensive widgets
class OptimizedWidget extends StatelessWidget {
  const OptimizedWidget({
    required this.child,
    required this.debugLabel,
    super.key,
    this.enableRepaintBoundary = true,
    this.enablePerformanceMonitoring = false,
  });

  final Widget child;
  final String debugLabel;
  final bool enableRepaintBoundary;
  final bool enablePerformanceMonitoring;

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    // Add performance monitoring if enabled
    if (kDebugMode && enablePerformanceMonitoring) {
      result = PerformanceMonitor(name: debugLabel, child: result);
    }

    // Add RepaintBoundary if enabled
    if (enableRepaintBoundary) {
      result = RepaintBoundary(child: result);
    }

    return result;
  }
}
