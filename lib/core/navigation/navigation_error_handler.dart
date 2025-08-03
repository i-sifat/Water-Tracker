import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Navigation error types
enum NavigationError {
  pageLoadFailed,
  transitionTimeout,
  controllerDisposed,
  invalidRoute,
  memoryError,
  stateCorruption,
}

/// Navigation error details
class NavigationErrorDetails {
  final NavigationError type;
  final String message;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;
  final DateTime timestamp;

  NavigationErrorDetails({
    required this.type,
    required this.message,
    this.stackTrace,
    this.context,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'message': message,
    'context': context,
    'timestamp': timestamp.toIso8601String(),
  };

  factory NavigationErrorDetails.fromJson(Map<String, dynamic> json) {
    return NavigationErrorDetails(
      type: NavigationError.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NavigationError.pageLoadFailed,
      ),
      message: (json['message'] as String?) ?? '',
      context: json['context'] as Map<String, dynamic>?,
      timestamp:
          DateTime.tryParse((json['timestamp'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Navigation state for persistence and recovery
class NavigationState {
  final int currentStep;
  final bool isLoading;
  final String? error;
  final Map<int, bool> stepCompletionStatus;
  final DateTime lastUpdate;

  NavigationState({
    required this.currentStep,
    this.isLoading = false,
    this.error,
    this.stepCompletionStatus = const {},
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'currentStep': currentStep,
    'isLoading': isLoading,
    'error': error,
    'stepCompletionStatus': stepCompletionStatus.map(
      (key, value) => MapEntry(key.toString(), value),
    ),
    'lastUpdate': lastUpdate.toIso8601String(),
  };

  factory NavigationState.fromJson(Map<String, dynamic> json) {
    final stepStatus = <int, bool>{};
    final statusMap =
        json['stepCompletionStatus'] as Map<String, dynamic>? ?? {};
    for (final entry in statusMap.entries) {
      final key = int.tryParse(entry.key);
      if (key != null) {
        stepStatus[key] = entry.value as bool? ?? false;
      }
    }

    return NavigationState(
      currentStep: (json['currentStep'] as int?) ?? 0,
      isLoading: (json['isLoading'] as bool?) ?? false,
      error: json['error'] as String?,
      stepCompletionStatus: stepStatus,
      lastUpdate:
          DateTime.tryParse((json['lastUpdate'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  NavigationState copyWith({
    int? currentStep,
    bool? isLoading,
    String? error,
    Map<int, bool>? stepCompletionStatus,
  }) {
    return NavigationState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      stepCompletionStatus: stepCompletionStatus ?? this.stepCompletionStatus,
    );
  }
}

/// Navigation error handler with recovery mechanisms
class NavigationErrorHandler {
  static const String _errorLogKey = 'navigation_error_log';
  static const String _navigationStateKey = 'navigation_state';
  static const int _maxErrorLogEntries = 50;

  /// Handle navigation error with recovery options
  static Future<bool> handleError(
    NavigationErrorDetails error, {
    VoidCallback? onRetry,
    VoidCallback? onFallback,
    BuildContext? context,
  }) async {
    // Log the error
    await _logError(error);

    // Show error to user if context is available
    if (context != null && context.mounted) {
      return await _showErrorDialog(context, error, onRetry, onFallback);
    }

    return false;
  }

  /// Log navigation error for debugging
  static Future<void> _logError(NavigationErrorDetails error) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingLogs = prefs.getStringList(_errorLogKey) ?? [];

      // Add new error log
      existingLogs.add(jsonEncode(error.toJson()));

      // Keep only recent errors
      if (existingLogs.length > _maxErrorLogEntries) {
        existingLogs.removeRange(0, existingLogs.length - _maxErrorLogEntries);
      }

      await prefs.setStringList(_errorLogKey, existingLogs);

      // Also log to debug console
      debugPrint('Navigation Error: ${error.type.name} - ${error.message}');
      if (error.stackTrace != null) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    } catch (e) {
      debugPrint('Failed to log navigation error: $e');
    }
  }

  /// Show error dialog with recovery options
  static Future<bool> _showErrorDialog(
    BuildContext context,
    NavigationErrorDetails error,
    VoidCallback? onRetry,
    VoidCallback? onFallback,
  ) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Navigation Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getErrorMessage(error.type)),
                if (error.message.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Details: ${error.message}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            actions: [
              if (onFallback != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    onFallback();
                  },
                  child: const Text('Go Back'),
                ),
              if (onRetry != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onRetry();
                  },
                  child: const Text('Retry'),
                ),
              if (onRetry == null && onFallback == null)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('OK'),
                ),
            ],
          ),
    );

    return result ?? false;
  }

  /// Get user-friendly error message
  static String _getErrorMessage(NavigationError type) {
    switch (type) {
      case NavigationError.pageLoadFailed:
        return 'Failed to load the page. Please try again.';
      case NavigationError.transitionTimeout:
        return 'Page transition took too long. Please try again.';
      case NavigationError.controllerDisposed:
        return 'Navigation controller was disposed. Restarting navigation.';
      case NavigationError.invalidRoute:
        return 'Invalid navigation route. Returning to previous page.';
      case NavigationError.memoryError:
        return 'Not enough memory to complete navigation. Please close other apps.';
      case NavigationError.stateCorruption:
        return 'Navigation state was corrupted. Resetting to safe state.';
    }
  }

  /// Save navigation state for recovery
  static Future<void> saveNavigationState(NavigationState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_navigationStateKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Failed to save navigation state: $e');
    }
  }

  /// Restore navigation state after error
  static Future<NavigationState?> restoreNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_navigationStateKey);

      if (stateJson != null) {
        final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
        return NavigationState.fromJson(stateMap);
      }
    } catch (e) {
      debugPrint('Failed to restore navigation state: $e');
    }

    return null;
  }

  /// Clear saved navigation state
  static Future<void> clearNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_navigationStateKey);
    } catch (e) {
      debugPrint('Failed to clear navigation state: $e');
    }
  }

  /// Get error logs for debugging
  static Future<List<NavigationErrorDetails>> getErrorLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = prefs.getStringList(_errorLogKey) ?? [];

      return logs.map((log) {
        try {
          final logMap = jsonDecode(log) as Map<String, dynamic>;
          return NavigationErrorDetails.fromJson(logMap);
        } catch (e) {
          return NavigationErrorDetails(
            type: NavigationError.pageLoadFailed,
            message: 'Failed to parse error log: $e',
          );
        }
      }).toList();
    } catch (e) {
      debugPrint('Failed to get error logs: $e');
      return [];
    }
  }

  /// Clear error logs
  static Future<void> clearErrorLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_errorLogKey);
    } catch (e) {
      debugPrint('Failed to clear error logs: $e');
    }
  }

  /// Check if navigation state is corrupted
  static bool isNavigationStateCorrupted(NavigationState state) {
    // Check for invalid current step
    if (state.currentStep < 0) return true;

    // Check for timestamp issues
    final now = DateTime.now();
    if (state.lastUpdate.isAfter(now.add(const Duration(minutes: 1)))) {
      return true;
    }

    // Check for very old state (more than 24 hours)
    if (now.difference(state.lastUpdate) > const Duration(hours: 24)) {
      return true;
    }

    return false;
  }

  /// Create safe fallback navigation state
  static NavigationState createSafeFallbackState() {
    return NavigationState(
      currentStep: 0,
      isLoading: false,
      error: null,
      stepCompletionStatus: {},
    );
  }
}

/// Mixin for widgets that need navigation error handling
mixin NavigationErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  /// Handle navigation error with automatic recovery
  Future<bool> handleNavigationError(
    NavigationError type,
    String message, {
    Map<String, dynamic>? context,
    VoidCallback? onRetry,
    VoidCallback? onFallback,
  }) async {
    final error = NavigationErrorDetails(
      type: type,
      message: message,
      context: context,
      stackTrace: StackTrace.current,
    );

    return await NavigationErrorHandler.handleError(
      error,
      context: mounted ? this.context : null,
      onRetry: onRetry,
      onFallback: onFallback,
    );
  }

  /// Safe navigation with error handling
  Future<T?> safeNavigate<T extends Object?>(
    Future<T?> Function() navigationFunction, {
    String operationName = 'navigation',
    VoidCallback? onError,
  }) async {
    try {
      return await navigationFunction();
    } catch (e, stackTrace) {
      await handleNavigationError(
        NavigationError.pageLoadFailed,
        'Failed to navigate: $e',
        context: {'operation': operationName},
        onFallback: onError,
      );
      return null;
    }
  }

  /// Save current navigation state
  Future<void> saveCurrentNavigationState(NavigationState state) async {
    await NavigationErrorHandler.saveNavigationState(state);
  }

  /// Restore navigation state if available
  Future<NavigationState?> restoreNavigationState() async {
    return await NavigationErrorHandler.restoreNavigationState();
  }
}

/// Error boundary widget for navigation
class NavigationErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(NavigationErrorDetails error)? errorBuilder;
  final VoidCallback? onError;

  const NavigationErrorBoundary({
    required this.child,
    this.errorBuilder,
    this.onError,
    super.key,
  });

  @override
  State<NavigationErrorBoundary> createState() =>
      _NavigationErrorBoundaryState();
}

class _NavigationErrorBoundaryState extends State<NavigationErrorBoundary> {
  NavigationErrorDetails? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? _buildDefaultErrorWidget();
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Navigation Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error?.message ?? 'An unknown error occurred',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  widget.onError?.call();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle error from child widgets
  void handleError(NavigationErrorDetails error) {
    setState(() {
      _error = error;
    });

    NavigationErrorHandler.handleError(error);
  }
}
