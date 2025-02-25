class WaterTrackerException implements Exception {
  WaterTrackerException(this.message, [this.error]);
  final String message;
  final dynamic error;

  @override
  String toString() => message;
}

String getErrorMessage(dynamic error) {
  if (error is WaterTrackerException) {
    return error.message;
  }
  return 'An unexpected error occurred. Please try again.';
}
