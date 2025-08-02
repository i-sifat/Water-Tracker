import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watertracker/core/models/app_error.dart';

/// Comprehensive error handling utility for the hydration interface
class ErrorHandler {
  ErrorHandler._();

  /// Handle errors with appropriate user feedback and logging
  static Future<void> handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
    bool logError = true,
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    final appError = _convertToAppError(error);

    // Log error if needed
    if (logError && appError.shouldLog) {
      _logError(appError);
    }

    // Show user feedback
    if (showSnackBar) {
      final message = customMessage ?? appError.userMessage;
      await _showErrorSnackBar(context, message, onRetry: onRetry);
    }
  }

  /// Convert any error to AppError
  static AppError _convertToAppError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is SocketException) {
      return NetworkError.noConnection();
    }

    if (error is TimeoutException) {
      return NetworkError.timeout();
    }

    if (error is FormatException) {
      return ValidationError.invalidInput('data', 'Invalid data format');
    }

    // Generic error - create a concrete implementation
    return _GenericError(error.toString());
  }

  /// Log error with appropriate level
  static void _logError(AppError error) {
    if (kDebugMode) {
      debugPrint('Error [${error.code}]: ${error.message}');
      if (error.details != null) {
        debugPrint('Details: ${error.details}');
      }
      if (error.stackTrace != null) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    }
  }

  /// Show error snackbar with retry option
  static Future<void> _showErrorSnackBar(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Text(message),
      action:
          onRetry != null
              ? SnackBarAction(label: 'Retry', onPressed: onRetry)
              : null,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Handle network connectivity errors
  static Future<void> handleNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    await handleError(context, NetworkError.noConnection(), onRetry: onRetry);
  }

  /// Handle validation errors
  static Future<void> handleValidationError(
    BuildContext context,
    String field,
    String message,
  ) async {
    await handleError(context, ValidationError.invalidInput(field, message));
  }

  /// Handle storage errors
  static Future<void> handleStorageError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    await handleError(context, StorageError.writeFailed(), onRetry: onRetry);
  }

  /// Show loading error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  child: const Text('Retry'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Check network connectivity
  static Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Retry operation with exponential backoff
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    var delay = initialDelay;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries - 1) {
          rethrow;
        }

        await Future.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Safe async operation wrapper
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    T? fallback,
    bool logError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (logError) {
        debugPrint('Safe async operation failed: $e');
      }
      return fallback;
    }
  }

  /// Validate hydration amount
  static ValidationError? validateHydrationAmount(int amount) {
    if (amount <= 0) {
      return ValidationError.invalidInput(
        'amount',
        'Amount must be greater than 0',
      );
    }

    if (amount > 5000) {
      return ValidationError.invalidInput(
        'amount',
        'Amount cannot exceed 5000ml',
      );
    }

    return null;
  }

  /// Validate daily goal
  static ValidationError? validateDailyGoal(int goal) {
    if (goal <= 0) {
      return ValidationError.invalidInput(
        'goal',
        'Goal must be greater than 0',
      );
    }

    if (goal < 500) {
      return ValidationError.invalidInput(
        'goal',
        'Goal should be at least 500ml',
      );
    }

    if (goal > 10000) {
      return ValidationError.invalidInput('goal', 'Goal cannot exceed 10000ml');
    }

    return null;
  }

  /// Validate notes input
  static ValidationError? validateNotes(String? notes) {
    if (notes != null && notes.length > 500) {
      return ValidationError.invalidInput(
        'notes',
        'Notes cannot exceed 500 characters',
      );
    }

    return null;
  }
}

/// Extension for safe context operations
extension SafeContext on BuildContext {
  /// Check if context is still mounted before using
  bool get isMounted => mounted;

  /// Safe navigation
  Future<T?> safePush<T>(Route<T> route) async {
    if (!mounted) return null;
    return Navigator.of(this).push(route);
  }

  /// Safe pop
  void safePop<T>([T? result]) {
    if (!mounted) return;
    Navigator.of(this).pop(result);
  }

  /// Safe show snackbar
  void safeShowSnackBar(SnackBar snackBar) {
    if (!mounted) return;
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}

/// Generic error implementation for unknown errors
class _GenericError extends AppError {
  const _GenericError(String message)
    : super(message: message, code: 'UNKNOWN_ERROR');
}
