import 'package:equatable/equatable.dart';

/// Base class for all application errors
abstract class AppError extends Equatable implements Exception {
  const AppError({
    required this.message,
    required this.code,
    this.details,
    this.stackTrace,
  });

  /// Human-readable error message
  final String message;

  /// Error code for programmatic handling
  final String code;

  /// Additional error details
  final Map<String, dynamic>? details;

  /// Stack trace if available
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'AppError(code: $code, message: $message)';
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
    this.statusCode,
  });

  /// No internet connection
  factory NetworkError.noConnection() {
    return const NetworkError(
      message: 'No internet connection available',
      code: 'NETWORK_NO_CONNECTION',
    );
  }

  /// Request timeout
  factory NetworkError.timeout() {
    return const NetworkError(
      message: 'Request timed out',
      code: 'NETWORK_TIMEOUT',
    );
  }

  /// Server error
  factory NetworkError.serverError(int statusCode, [String? message]) {
    return NetworkError(
      message: message ?? 'Server error occurred',
      code: 'NETWORK_SERVER_ERROR',
      statusCode: statusCode,
      details: {'statusCode': statusCode},
    );
  }

  /// HTTP status code if applicable
  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Storage-related errors
class StorageError extends AppError {
  const StorageError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// Failed to read data
  factory StorageError.readFailed([String? details]) {
    return StorageError(
      message: 'Failed to read data from storage',
      code: 'STORAGE_READ_FAILED',
      details: details != null ? {'details': details} : null,
    );
  }

  /// Failed to write data
  factory StorageError.writeFailed([String? details]) {
    return StorageError(
      message: 'Failed to write data to storage',
      code: 'STORAGE_WRITE_FAILED',
      details: details != null ? {'details': details} : null,
    );
  }

  /// Storage is full
  factory StorageError.storageFull() {
    return const StorageError(message: 'Storage is full', code: 'STORAGE_FULL');
  }

  /// Data corruption detected
  factory StorageError.dataCorrupted() {
    return const StorageError(
      message: 'Stored data is corrupted',
      code: 'STORAGE_DATA_CORRUPTED',
    );
  }
}

/// Validation-related errors
class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
    this.field,
  });

  /// Invalid input value
  factory ValidationError.invalidInput(String field, String message) {
    return ValidationError(
      message: message,
      code: 'VALIDATION_INVALID_INPUT',
      field: field,
      details: {'field': field},
    );
  }

  /// Required field missing
  factory ValidationError.requiredField(String field) {
    return ValidationError(
      message: '$field is required',
      code: 'VALIDATION_REQUIRED_FIELD',
      field: field,
      details: {'field': field},
    );
  }

  /// Value out of range
  factory ValidationError.outOfRange(String field, dynamic min, dynamic max) {
    return ValidationError(
      message: '$field must be between $min and $max',
      code: 'VALIDATION_OUT_OF_RANGE',
      field: field,
      details: {'field': field, 'min': min, 'max': max},
    );
  }

  /// Field that failed validation
  final String? field;

  @override
  List<Object?> get props => [...super.props, field];
}

/// Premium-related errors
class PremiumError extends AppError {
  const PremiumError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// Feature is locked
  factory PremiumError.featureLocked(String featureName) {
    return PremiumError(
      message: '$featureName is a premium feature',
      code: 'PREMIUM_FEATURE_LOCKED',
      details: {'feature': featureName},
    );
  }

  /// Invalid unlock code
  factory PremiumError.invalidUnlockCode() {
    return const PremiumError(
      message: 'Invalid unlock code',
      code: 'PREMIUM_INVALID_UNLOCK_CODE',
    );
  }

  /// Unlock code expired
  factory PremiumError.unlockCodeExpired() {
    return const PremiumError(
      message: 'Unlock code has expired',
      code: 'PREMIUM_UNLOCK_CODE_EXPIRED',
    );
  }

  /// Device code mismatch
  factory PremiumError.deviceCodeMismatch() {
    return const PremiumError(
      message: 'Unlock code is not valid for this device',
      code: 'PREMIUM_DEVICE_CODE_MISMATCH',
    );
  }

  /// Donation proof submission failed
  factory PremiumError.donationProofFailed([String? reason]) {
    return PremiumError(
      message: reason ?? 'Failed to submit donation proof',
      code: 'PREMIUM_DONATION_PROOF_FAILED',
      details: reason != null ? {'reason': reason} : null,
    );
  }
}

/// Hydration tracking errors
class HydrationError extends AppError {
  const HydrationError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// Invalid amount
  factory HydrationError.invalidAmount(int amount) {
    return HydrationError(
      message: 'Invalid hydration amount: $amount ml',
      code: 'HYDRATION_INVALID_AMOUNT',
      details: {'amount': amount},
    );
  }

  /// Goal already reached
  factory HydrationError.goalAlreadyReached() {
    return const HydrationError(
      message: 'Daily hydration goal already reached',
      code: 'HYDRATION_GOAL_REACHED',
    );
  }

  /// Failed to save hydration data
  factory HydrationError.saveFailed() {
    return const HydrationError(
      message: 'Failed to save hydration data',
      code: 'HYDRATION_SAVE_FAILED',
    );
  }

  /// Data sync failed
  factory HydrationError.syncFailed([String? reason]) {
    return HydrationError(
      message: reason ?? 'Failed to sync hydration data',
      code: 'HYDRATION_SYNC_FAILED',
      details: reason != null ? {'reason': reason} : null,
    );
  }
}

/// Notification-related errors
class NotificationError extends AppError {
  const NotificationError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// Permission denied
  factory NotificationError.permissionDenied() {
    return const NotificationError(
      message: 'Notification permission denied',
      code: 'NOTIFICATION_PERMISSION_DENIED',
    );
  }

  /// Failed to schedule notification
  factory NotificationError.scheduleFailed([String? reason]) {
    return NotificationError(
      message: reason ?? 'Failed to schedule notification',
      code: 'NOTIFICATION_SCHEDULE_FAILED',
      details: reason != null ? {'reason': reason} : null,
    );
  }

  /// Notification not supported
  factory NotificationError.notSupported() {
    return const NotificationError(
      message: 'Notifications are not supported on this device',
      code: 'NOTIFICATION_NOT_SUPPORTED',
    );
  }
}

/// Device-related errors
class DeviceError extends AppError {
  const DeviceError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// Failed to get device information
  factory DeviceError.infoUnavailable() {
    return const DeviceError(
      message: 'Device information is not available',
      code: 'DEVICE_INFO_UNAVAILABLE',
    );
  }

  /// Failed to generate device code
  factory DeviceError.codeGenerationFailed() {
    return const DeviceError(
      message: 'Failed to generate device code',
      code: 'DEVICE_CODE_GENERATION_FAILED',
    );
  }
}

/// Analytics-related errors
class AnalyticsError extends AppError {
  const AnalyticsError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// Failed to calculate analytics
  factory AnalyticsError.calculationFailed([String? reason]) {
    return AnalyticsError(
      message: reason ?? 'Failed to calculate analytics',
      code: 'ANALYTICS_CALCULATION_FAILED',
      details: reason != null ? {'reason': reason} : null,
    );
  }

  /// Insufficient data for analytics
  factory AnalyticsError.insufficientData() {
    return const AnalyticsError(
      message: 'Not enough data to generate analytics',
      code: 'ANALYTICS_INSUFFICIENT_DATA',
    );
  }
}

/// Data export errors
class DataExportError extends AppError {
  const DataExportError({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// Failed to export data
  factory DataExportError.exportFailed([String? reason]) {
    return DataExportError(
      message: reason ?? 'Failed to export data',
      code: 'DATA_EXPORT_FAILED',
      details: reason != null ? {'reason': reason} : null,
    );
  }

  /// Unsupported export format
  factory DataExportError.unsupportedFormat(String format) {
    return DataExportError(
      message: 'Unsupported export format: $format',
      code: 'DATA_EXPORT_UNSUPPORTED_FORMAT',
      details: {'format': format},
    );
  }
}

/// Extension for handling errors gracefully
extension AppErrorHandling on AppError {
  /// Get user-friendly message
  String get userMessage {
    switch (code) {
      case 'NETWORK_NO_CONNECTION':
        return 'Please check your internet connection and try again.';
      case 'STORAGE_FULL':
        return 'Storage is full. Please free up some space.';
      case 'PREMIUM_FEATURE_LOCKED':
        return 'This feature requires premium access.';
      case 'VALIDATION_REQUIRED_FIELD':
        return 'Please fill in all required fields.';
      case 'ANALYTICS_INSUFFICIENT_DATA':
        return 'Not enough data to generate analytics. Start tracking your water intake!';
      case 'DATA_EXPORT_FAILED':
        return 'Failed to export data. Please try again.';
      default:
        return message;
    }
  }

  /// Whether this error should be retried
  bool get isRetryable {
    switch (code) {
      case 'NETWORK_TIMEOUT':
      case 'NETWORK_SERVER_ERROR':
      case 'STORAGE_READ_FAILED':
      case 'STORAGE_WRITE_FAILED':
      case 'HYDRATION_SAVE_FAILED':
      case 'HYDRATION_SYNC_FAILED':
      case 'NOTIFICATION_SCHEDULE_FAILED':
      case 'ANALYTICS_CALCULATION_FAILED':
      case 'DATA_EXPORT_FAILED':
        return true;
      default:
        return false;
    }
  }

  /// Whether this error should be logged
  bool get shouldLog {
    switch (code) {
      case 'PREMIUM_FEATURE_LOCKED':
      case 'VALIDATION_INVALID_INPUT':
      case 'VALIDATION_REQUIRED_FIELD':
        return false;
      default:
        return true;
    }
  }
}
