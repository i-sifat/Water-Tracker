import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/models/app_error.dart';

/// Comprehensive error logging system that safely logs errors without exposing sensitive information
class ErrorLogger {
  static const String _errorLogKey = 'app_error_log';
  static const String _errorCountKey = 'app_error_count';
  static const int _maxLogEntries = 100;
  static const int _maxLogAge = 7; // days

  /// Log an error with context information
  static Future<void> logError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? operation,
    bool isCritical = false,
  }) async {
    try {
      final errorEntry = _createErrorEntry(
        error,
        stackTrace: stackTrace,
        context: context,
        operation: operation,
        isCritical: isCritical,
      );

      await _saveErrorEntry(errorEntry);
      await _incrementErrorCount();

      // Log to debug console in debug mode
      if (kDebugMode) {
        _logToDebugConsole(errorEntry);
      }

      // For critical errors, also log to system
      if (isCritical) {
        await _logCriticalError(errorEntry);
      }
    } catch (e) {
      // Fallback logging - don't let logging errors crash the app
      if (kDebugMode) {
        debugPrint('Failed to log error: $e');
        debugPrint('Original error: $error');
      }
    }
  }

  /// Log a navigation error
  static Future<void> logNavigationError(
    String operation,
    dynamic error, {
    StackTrace? stackTrace,
    String? route,
    Map<String, dynamic>? params,
  }) async {
    await logError(
      error,
      stackTrace: stackTrace,
      context: {
        'type': 'navigation',
        'route': route,
        'params': _sanitizeParams(params),
      },
      operation: operation,
      isCritical: false,
    );
  }

  /// Log a calculation error
  static Future<void> logCalculationError(
    String calculation,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? inputs,
  }) async {
    await logError(
      error,
      stackTrace: stackTrace,
      context: {
        'type': 'calculation',
        'calculation': calculation,
        'inputs': _sanitizeInputs(inputs),
      },
      operation: calculation,
      isCritical: true, // Calculation errors are critical for app functionality
    );
  }

  /// Log a storage error
  static Future<void> logStorageError(
    String operation,
    dynamic error, {
    StackTrace? stackTrace,
    String? key,
  }) async {
    await logError(
      error,
      stackTrace: stackTrace,
      context: {
        'type': 'storage',
        'key': key, // Key names are not sensitive
      },
      operation: operation,
      isCritical: true, // Storage errors are critical
    );
  }

  /// Log a network error
  static Future<void> logNetworkError(
    String operation,
    dynamic error, {
    StackTrace? stackTrace,
    String? endpoint,
    int? statusCode,
  }) async {
    await logError(
      error,
      stackTrace: stackTrace,
      context: {
        'type': 'network',
        'endpoint': _sanitizeEndpoint(endpoint),
        'statusCode': statusCode,
      },
      operation: operation,
      isCritical: false,
    );
  }

  /// Get error statistics for debugging
  static Future<Map<String, dynamic>> getErrorStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorCount = prefs.getInt(_errorCountKey) ?? 0;
      final logs = await _getErrorLogs();

      final criticalErrors =
          logs.where((log) => log['isCritical'] == true).length;
      final recentErrors =
          logs.where((log) {
            final timestamp = DateTime.tryParse(log['timestamp'] ?? '');
            if (timestamp == null) return false;
            return DateTime.now().difference(timestamp).inHours < 24;
          }).length;

      final errorTypes = <String, int>{};
      for (final log in logs) {
        final type = log['context']?['type'] as String? ?? 'unknown';
        errorTypes[type] = (errorTypes[type] ?? 0) + 1;
      }

      return {
        'totalErrors': errorCount,
        'criticalErrors': criticalErrors,
        'recentErrors': recentErrors,
        'errorTypes': errorTypes,
        'logCount': logs.length,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get error statistics: $e');
      }
      return {
        'totalErrors': 0,
        'criticalErrors': 0,
        'recentErrors': 0,
        'errorTypes': <String, int>{},
        'logCount': 0,
      };
    }
  }

  /// Clear old error logs
  static Future<void> clearOldLogs() async {
    try {
      final logs = await _getErrorLogs();
      final cutoffDate = DateTime.now().subtract(Duration(days: _maxLogAge));

      final recentLogs =
          logs.where((log) {
            final timestamp = DateTime.tryParse(log['timestamp'] ?? '');
            return timestamp != null && timestamp.isAfter(cutoffDate);
          }).toList();

      await _saveErrorLogs(recentLogs);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to clear old logs: $e');
      }
    }
  }

  /// Clear all error logs (for privacy)
  static Future<void> clearAllLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_errorLogKey);
      await prefs.remove(_errorCountKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to clear all logs: $e');
      }
    }
  }

  /// Create sanitized error entry
  static Map<String, dynamic> _createErrorEntry(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? operation,
    bool isCritical = false,
  }) {
    String errorMessage;
    String errorType;

    if (error is AppError) {
      errorMessage = error.message;
      errorType = error.code;
    } else if (error is Exception) {
      errorMessage = error.toString();
      errorType = error.runtimeType.toString();
    } else {
      errorMessage = error?.toString() ?? 'Unknown error';
      errorType = 'UnknownError';
    }

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'type': errorType,
      'message': _sanitizeErrorMessage(errorMessage),
      'operation': operation,
      'isCritical': isCritical,
      'context': _sanitizeContext(context),
      'stackTrace': kDebugMode ? stackTrace?.toString() : null,
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  /// Save error entry to storage
  static Future<void> _saveErrorEntry(Map<String, dynamic> errorEntry) async {
    final logs = await _getErrorLogs();
    logs.insert(0, errorEntry); // Add to beginning (newest first)

    // Keep only recent logs
    if (logs.length > _maxLogEntries) {
      logs.removeRange(_maxLogEntries, logs.length);
    }

    await _saveErrorLogs(logs);
  }

  /// Get error logs from storage
  static Future<List<Map<String, dynamic>>> _getErrorLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList(_errorLogKey) ?? [];

      return logsJson.map((logString) {
        try {
          return jsonDecode(logString) as Map<String, dynamic>;
        } catch (e) {
          return <String, dynamic>{
            'timestamp': DateTime.now().toIso8601String(),
            'type': 'LogParseError',
            'message': 'Failed to parse log entry',
            'isCritical': false,
          };
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save error logs to storage
  static Future<void> _saveErrorLogs(List<Map<String, dynamic>> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = logs.map((log) => jsonEncode(log)).toList();
      await prefs.setStringList(_errorLogKey, logsJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save error logs: $e');
      }
    }
  }

  /// Increment error count
  static Future<void> _incrementErrorCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_errorCountKey) ?? 0;
      await prefs.setInt(_errorCountKey, currentCount + 1);
    } catch (e) {
      // Ignore count increment failures
    }
  }

  /// Log to debug console
  static void _logToDebugConsole(Map<String, dynamic> errorEntry) {
    debugPrint('=== ERROR LOG ===');
    debugPrint('Time: ${errorEntry['timestamp']}');
    debugPrint('Type: ${errorEntry['type']}');
    debugPrint('Operation: ${errorEntry['operation']}');
    debugPrint('Critical: ${errorEntry['isCritical']}');
    debugPrint('Message: ${errorEntry['message']}');
    if (errorEntry['context'] != null) {
      debugPrint('Context: ${errorEntry['context']}');
    }
    if (errorEntry['stackTrace'] != null) {
      debugPrint('Stack trace: ${errorEntry['stackTrace']}');
    }
    debugPrint('================');
  }

  /// Log critical errors to system (could be extended for crash reporting)
  static Future<void> _logCriticalError(Map<String, dynamic> errorEntry) async {
    // For now, just ensure it's logged to debug console
    if (kDebugMode) {
      debugPrint('CRITICAL ERROR: ${errorEntry['message']}');
    }

    // In production, this could send to crash reporting service
    // without exposing sensitive user data
  }

  /// Sanitize error message to remove sensitive information
  static String _sanitizeErrorMessage(String message) {
    // Remove potential file paths
    message = message.replaceAll(RegExp(r'[A-Za-z]:\\[^\\]*\\'), '[PATH]\\');
    message = message.replaceAll(RegExp(r'/[^/]*/'), '/[PATH]/');

    // Remove potential email addresses
    message = message.replaceAll(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      '[EMAIL]',
    );

    // Remove potential phone numbers
    message = message.replaceAll(RegExp(r'\b\d{3}-\d{3}-\d{4}\b'), '[PHONE]');

    // Remove potential IP addresses
    message = message.replaceAll(
      RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
      '[IP]',
    );

    return message;
  }

  /// Sanitize context to remove sensitive information
  static Map<String, dynamic>? _sanitizeContext(Map<String, dynamic>? context) {
    if (context == null) return null;

    final sanitized = <String, dynamic>{};
    for (final entry in context.entries) {
      final key = entry.key;
      final value = entry.value;

      // Skip potentially sensitive keys
      if (_isSensitiveKey(key)) {
        sanitized[key] = '[REDACTED]';
      } else if (value is String) {
        sanitized[key] = _sanitizeErrorMessage(value);
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeContext(value);
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /// Check if a key contains sensitive information
  static bool _isSensitiveKey(String key) {
    final sensitiveKeys = [
      'password',
      'token',
      'secret',
      'key',
      'auth',
      'credential',
      'email',
      'phone',
      'address',
      'name',
      'user',
      'personal',
    ];

    final lowerKey = key.toLowerCase();
    return sensitiveKeys.any((sensitive) => lowerKey.contains(sensitive));
  }

  /// Sanitize parameters
  static Map<String, dynamic>? _sanitizeParams(Map<String, dynamic>? params) {
    return _sanitizeContext(params);
  }

  /// Sanitize calculation inputs
  static Map<String, dynamic>? _sanitizeInputs(Map<String, dynamic>? inputs) {
    return _sanitizeContext(inputs);
  }

  /// Sanitize endpoint URLs
  static String? _sanitizeEndpoint(String? endpoint) {
    if (endpoint == null) return null;

    // Remove query parameters that might contain sensitive data
    final uri = Uri.tryParse(endpoint);
    if (uri != null) {
      return '${uri.scheme}://${uri.host}${uri.path}';
    }

    return endpoint;
  }
}
