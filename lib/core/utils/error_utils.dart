class WaterTrackerException implements Exception {
  final String message;
  final dynamic error;

  WaterTrackerException(this.message, [this.error]);

  @override
  String toString() => message;
}

String getErrorMessage(dynamic error) {
  if (error is WaterTrackerException) {
    return error.message;
  }
  return 'An unexpected error occurred. Please try again.';
}