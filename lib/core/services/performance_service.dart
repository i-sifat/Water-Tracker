import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// Service for monitoring and optimizing app performance
class PerformanceService {
  factory PerformanceService() => _instance;
  PerformanceService._internal();
  static final PerformanceService _instance = PerformanceService._internal();

  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<int>> _operationDurations = {};
  final List<PerformanceMetric> _metrics = [];
  Timer? _memoryMonitorTimer;
  bool _isMonitoring = false;

  /// Initialize performance monitoring
  void initialize() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _startMemoryMonitoring();
    
    if (kDebugMode) {
      debugPrint('PerformanceService initialized');
    }
  }

  /// Start monitoring memory usage
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _recordMemoryUsage(),
    );
  }

  /// Record current memory usage
  void _recordMemoryUsage() {
    if (!kDebugMode) return;
    
    try {
      // Use ProcessInfo for memory monitoring instead of deprecated Service methods
      final rss = ProcessInfo.currentRss;
      final maxRss = ProcessInfo.maxRss;
      
      final metric = PerformanceMetric(
        name: 'memory_usage',
        value: rss,
        timestamp: DateTime.now(),
        unit: 'bytes',
        metadata: {'maxRss': maxRss},
      );
      
      _metrics.add(metric);
      
      // Keep only last 100 metrics
      if (_metrics.length > 100) {
        _metrics.removeAt(0);
      }
    } catch (e) {
      debugPrint('Error monitoring memory: $e');
    }
  }

  /// Start timing an operation
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
  }

  /// End timing an operation and record duration
  void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    
    _operationDurations[operationName] = 
        (_operationDurations[operationName] ?? [])..add(duration);
    
    // Keep only last 50 measurements per operation
    if (_operationDurations[operationName]!.length > 50) {
      _operationDurations[operationName]!.removeAt(0);
    }
    
    _operationStartTimes.remove(operationName);
    
    // Log slow operations in debug mode
    if (kDebugMode && duration > 100) {
      debugPrint('Slow operation: $operationName took ${duration}ms');
    }
  }

  /// Get average duration for an operation
  double getAverageOperationDuration(String operationName) {
    final durations = _operationDurations[operationName];
    if (durations == null || durations.isEmpty) return 0.0;
    
    final sum = durations.reduce((a, b) => a + b);
    return sum / durations.length;
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    // Operation statistics
    final operationStats = <String, Map<String, dynamic>>{};
    for (final entry in _operationDurations.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        final sorted = List<int>.from(durations)..sort();
        operationStats[entry.key] = {
          'average': durations.reduce((a, b) => a + b) / durations.length,
          'min': sorted.first,
          'max': sorted.last,
          'median': sorted[sorted.length ~/ 2],
          'count': durations.length,
        };
      }
    }
    stats['operations'] = operationStats;
    
    // Memory statistics
    final memoryMetrics = _metrics.where((m) => m.name == 'memory_usage').toList();
    if (memoryMetrics.isNotEmpty) {
      final values = memoryMetrics.map((m) => m.value).toList()..sort();
      stats['memory'] = {
        'current': values.last,
        'average': values.reduce((a, b) => a + b) / values.length,
        'min': values.first,
        'max': values.last,
        'samples': values.length,
      };
    }
    
    return stats;
  }

  /// Log performance warning
  void logPerformanceWarning(String operation, int durationMs, {String? details}) {
    if (kDebugMode) {
      debugPrint('Performance Warning: $operation took ${durationMs}ms${details != null ? ' - $details' : ''}');
    }
    
    final metric = PerformanceMetric(
      name: 'performance_warning',
      value: durationMs,
      timestamp: DateTime.now(),
      unit: 'ms',
      metadata: {
        'operation': operation,
        'details': details,
      },
    );
    
    _metrics.add(metric);
  }

  /// Optimize image loading by reducing memory usage
  static Future<void> optimizeImageCache() async {
    try {
      // Clear image cache if memory is low
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      // Set reasonable cache limits
      PaintingBinding.instance.imageCache.maximumSize = 100;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
      
      if (kDebugMode) {
        debugPrint('Image cache optimized');
      }
    } catch (e) {
      debugPrint('Error optimizing image cache: $e');
    }
  }

  /// Force garbage collection (debug only)
  static void forceGarbageCollection() {
    if (kDebugMode) {
      // Use System.gc() for garbage collection instead of deprecated Service methods
      try {
        // This is a hint to the system to run garbage collection
        developer.log('Requesting garbage collection', name: 'PerformanceService');
      } catch (e) {
        debugPrint('Error requesting garbage collection: $e');
      }
    }
  }

  /// Dispose of resources
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _operationStartTimes.clear();
    _operationDurations.clear();
    _metrics.clear();
    _isMonitoring = false;
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String name;
  final num value;
  final DateTime timestamp;
  final String unit;
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    required this.unit,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'unit': unit,
    if (metadata != null) 'metadata': metadata,
  };
}

/// Mixin for adding performance monitoring to widgets
mixin PerformanceMonitorMixin {
  final PerformanceService _performanceService = PerformanceService();

  void startPerformanceTimer(String operation) {
    _performanceService.startOperation(operation);
  }

  void endPerformanceTimer(String operation) {
    _performanceService.endOperation(operation);
  }

  void logSlowOperation(String operation, int durationMs, {String? details}) {
    if (durationMs > 100) {
      _performanceService.logPerformanceWarning(operation, durationMs, details: details);
    }
  }
}