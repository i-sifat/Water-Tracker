import 'package:flutter/material.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/buttons/secondary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';

/// Comprehensive error handling widget with user-friendly messages and actions
class ErrorHandler extends StatelessWidget {
  const ErrorHandler({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
    this.customTitle,
    this.customMessage,
    this.customActions,
  });

  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;
  final String? customTitle;
  final String? customMessage;
  final List<Widget>? customActions;

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo(error);
    
    return AppCard(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: errorInfo.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorInfo.icon,
                color: errorInfo.color,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              customTitle ?? errorInfo.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Message
            Text(
              customMessage ?? errorInfo.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSubtitle,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Error details (if enabled)
            if (showDetails && error is AppError) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text(
                  'Technical Details',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSubtitle,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error Code: ${(error as AppError).code}\n'
                      'Message: ${(error as AppError).message}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppColors.textSubtitle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Actions
            if (customActions != null)
              ...customActions!
            else
              _buildDefaultActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultActions(BuildContext context) {
    return Row(
      children: [
        if (onDismiss != null) ...[
          Expanded(
            child: SecondaryButton(
              text: 'Dismiss',
              onPressed: onDismiss!,
            ),
          ),
          if (onRetry != null) const SizedBox(width: 12),
        ],
        if (onRetry != null)
          Expanded(
            child: PrimaryButton(
              text: 'Try Again',
              onPressed: onRetry!,
            ),
          ),
      ],
    );
  }

  _ErrorInfo _getErrorInfo(Object error) {
    if (error is NetworkError) {
      return _ErrorInfo(
        title: 'Connection Problem',
        message: 'Please check your internet connection and try again.',
        icon: Icons.wifi_off,
        color: Colors.orange,
      );
    } else if (error is StorageError) {
      return _ErrorInfo(
        title: 'Storage Error',
        message: 'There was a problem saving your data. Please try again.',
        icon: Icons.storage,
        color: Colors.red,
      );
    } else if (error is ValidationError) {
      return _ErrorInfo(
        title: 'Invalid Input',
        message: 'Please check your input and try again.',
        icon: Icons.warning,
        color: Colors.amber,
      );
    } else if (error is PremiumError) {
      return _ErrorInfo(
        title: 'Premium Feature',
        message: 'This feature requires premium access.',
        icon: Icons.star,
        color: AppColors.waterFull,
      );
    } else if (error is HydrationError) {
      return _ErrorInfo(
        title: 'Hydration Error',
        message: 'There was a problem with your hydration data.',
        icon: Icons.water_drop,
        color: AppColors.lightBlue,
      );
    } else {
      return _ErrorInfo(
        title: 'Something Went Wrong',
        message: 'An unexpected error occurred. Please try again.',
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }
}

class _ErrorInfo {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _ErrorInfo({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}

/// Inline error widget for forms and smaller spaces
class InlineErrorWidget extends StatelessWidget {
  const InlineErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo(error);
    
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: errorInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorInfo.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            errorInfo.icon,
            color: errorInfo.color,
            size: compact ? 16 : 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorInfo.message,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                color: errorInfo.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                color: errorInfo.color,
                size: compact ? 16 : 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _ErrorInfo _getErrorInfo(Object error) {
    if (error is NetworkError) {
      return _ErrorInfo(
        title: 'Connection Problem',
        message: 'Check your internet connection',
        icon: Icons.wifi_off,
        color: Colors.orange,
      );
    } else if (error is StorageError) {
      return _ErrorInfo(
        title: 'Storage Error',
        message: 'Problem saving data',
        icon: Icons.storage,
        color: Colors.red,
      );
    } else if (error is ValidationError) {
      return _ErrorInfo(
        title: 'Invalid Input',
        message: 'Please check your input',
        icon: Icons.warning,
        color: Colors.amber,
      );
    } else {
      return _ErrorInfo(
        title: 'Error',
        message: 'Something went wrong',
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }
}

/// Snackbar error display
class ErrorSnackBar {
  static void show(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final errorInfo = _getErrorInfo(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              errorInfo.icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorInfo.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: errorInfo.color,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static _ErrorInfo _getErrorInfo(Object error) {
    if (error is NetworkError) {
      return _ErrorInfo(
        title: 'Connection Problem',
        message: 'Check your internet connection',
        icon: Icons.wifi_off,
        color: Colors.orange,
      );
    } else if (error is StorageError) {
      return _ErrorInfo(
        title: 'Storage Error',
        message: 'Problem saving data',
        icon: Icons.storage,
        color: Colors.red,
      );
    } else if (error is ValidationError) {
      return _ErrorInfo(
        title: 'Invalid Input',
        message: 'Please check your input',
        icon: Icons.warning,
        color: Colors.amber,
      );
    } else {
      return _ErrorInfo(
        title: 'Error',
        message: 'Something went wrong',
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }
}

/// Global error boundary for unhandled exceptions
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.fallbackBuilder,
  });

  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onError;
  final Widget Function(Object error)? fallbackBuilder;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    
    // Set up global error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
        });
      }
      
      widget.onError?.call(details.exception, details.stack ?? StackTrace.empty);
    };
  }

  void _clearError() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallbackBuilder?.call(_error!) ??
          Scaffold(
            body: ErrorHandler(
              error: _error!,
              onRetry: _clearError,
              showDetails: true,
            ),
          );
    }

    return widget.child;
  }
}

/// Mixin for widgets that need error handling
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  Object? _lastError;

  Object? get lastError => _lastError;

  void setError(Object error) {
    setState(() {
      _lastError = error;
    });
  }

  void clearError() {
    setState(() {
      _lastError = null;
    });
  }

  void showErrorSnackBar(Object error, {VoidCallback? onRetry}) {
    ErrorSnackBar.show(context, error, onRetry: onRetry);
  }

  Widget buildErrorWidget({
    VoidCallback? onRetry,
    bool showDetails = false,
  }) {
    if (_lastError == null) return const SizedBox.shrink();
    
    return ErrorHandler(
      error: _lastError!,
      onRetry: onRetry,
      onDismiss: clearError,
      showDetails: showDetails,
    );
  }

  Widget buildInlineErrorWidget({
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    if (_lastError == null) return const SizedBox.shrink();
    
    return InlineErrorWidget(
      error: _lastError!,
      onRetry: onRetry,
      compact: compact,
    );
  }
}
