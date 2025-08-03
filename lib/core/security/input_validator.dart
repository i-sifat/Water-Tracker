import 'dart:math';

import 'package:watertracker/core/models/app_error.dart';

/// Comprehensive input validation system for security and data integrity
class InputValidator {
  // Hydration-related constants
  static const int minHydrationAmount = 1; // ml
  static const int maxHydrationAmount = 5000; // ml (5L max per entry)
  static const int maxDailyIntake = 15000; // ml (15L max per day for safety)
  static const int minDailyGoal = 500; // ml
  static const int maxDailyGoal = 10000; // ml

  // User profile constants
  static const int minAge = 1;
  static const int maxAge = 150;
  static const double minWeight = 1.0; // kg
  static const double maxWeight = 500.0; // kg
  static const int maxNotesLength = 500;
  static const int maxNameLength = 100;

  // Text input constants
  static const int maxStringLength = 1000;
  static const RegExp _safeTextPattern = RegExp(r'^[a-zA-Z0-9\s\-_.,!?()]+$');
  static const RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate hydration amount with bounds checking
  static ValidationError? validateHydrationAmount(int? amount) {
    if (amount == null) {
      return ValidationError.invalidInput('amount', 'Amount is required');
    }

    if (amount < minHydrationAmount) {
      return ValidationError.invalidInput(
        'amount',
        'Amount must be at least ${minHydrationAmount}ml',
      );
    }

    if (amount > maxHydrationAmount) {
      return ValidationError.invalidInput(
        'amount',
        'Amount cannot exceed ${maxHydrationAmount}ml per entry',
      );
    }

    return null;
  }

  /// Validate daily goal with reasonable bounds
  static ValidationError? validateDailyGoal(int? goal) {
    if (goal == null) {
      return ValidationError.invalidInput('goal', 'Daily goal is required');
    }

    if (goal < minDailyGoal) {
      return ValidationError.invalidInput(
        'goal',
        'Daily goal should be at least ${minDailyGoal}ml',
      );
    }

    if (goal > maxDailyGoal) {
      return ValidationError.invalidInput(
        'goal',
        'Daily goal cannot exceed ${maxDailyGoal}ml',
      );
    }

    return null;
  }

  /// Validate total daily intake to prevent overflow
  static ValidationError? validateDailyIntake(
    int currentIntake,
    int additionalAmount,
  ) {
    final projectedIntake = currentIntake + additionalAmount;

    if (projectedIntake > maxDailyIntake) {
      return ValidationError.invalidInput(
        'intake',
        'Total daily intake would exceed safe limit of ${maxDailyIntake}ml',
      );
    }

    return null;
  }

  /// Validate age with reasonable bounds
  static ValidationError? validateAge(int? age) {
    if (age == null) {
      return null; // Age is optional in some contexts
    }

    if (age < minAge) {
      return ValidationError.invalidInput(
        'age',
        'Age must be at least $minAge',
      );
    }

    if (age > maxAge) {
      return ValidationError.invalidInput('age', 'Age cannot exceed $maxAge');
    }

    return null;
  }

  /// Validate weight with reasonable bounds
  static ValidationError? validateWeight(double? weight) {
    if (weight == null) {
      return null; // Weight is optional in some contexts
    }

    if (weight < minWeight) {
      return ValidationError.invalidInput(
        'weight',
        'Weight must be at least ${minWeight}kg',
      );
    }

    if (weight > maxWeight) {
      return ValidationError.invalidInput(
        'weight',
        'Weight cannot exceed ${maxWeight}kg',
      );
    }

    // Check for reasonable precision (max 1 decimal place)
    if ((weight * 10) % 1 != 0) {
      return ValidationError.invalidInput(
        'weight',
        'Weight can have at most 1 decimal place',
      );
    }

    return null;
  }

  /// Validate notes text for safety and length
  static ValidationError? validateNotes(String? notes) {
    if (notes == null || notes.isEmpty) {
      return null; // Notes are optional
    }

    if (notes.length > maxNotesLength) {
      return ValidationError.invalidInput(
        'notes',
        'Notes cannot exceed $maxNotesLength characters',
      );
    }

    // Check for potentially malicious content
    if (_containsSuspiciousContent(notes)) {
      return ValidationError.invalidInput(
        'notes',
        'Notes contain invalid characters',
      );
    }

    return null;
  }

  /// Validate name input
  static ValidationError? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return ValidationError.invalidInput('name', 'Name is required');
    }

    if (name.length > maxNameLength) {
      return ValidationError.invalidInput(
        'name',
        'Name cannot exceed $maxNameLength characters',
      );
    }

    if (!_safeTextPattern.hasMatch(name)) {
      return ValidationError.invalidInput(
        'name',
        'Name contains invalid characters',
      );
    }

    return null;
  }

  /// Validate email format (if email features are added)
  static ValidationError? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationError.invalidInput('email', 'Email is required');
    }

    if (!_emailPattern.hasMatch(email)) {
      return ValidationError.invalidInput(
        'email',
        'Please enter a valid email address',
      );
    }

    return null;
  }

  /// Validate generic string input
  static ValidationError? validateString(
    String? input,
    String fieldName, {
    int? maxLength,
    bool required = false,
    bool allowSpecialChars = false,
  }) {
    if (input == null || input.isEmpty) {
      if (required) {
        return ValidationError.invalidInput(
          fieldName,
          '$fieldName is required',
        );
      }
      return null;
    }

    final effectiveMaxLength = maxLength ?? maxStringLength;
    if (input.length > effectiveMaxLength) {
      return ValidationError.invalidInput(
        fieldName,
        '$fieldName cannot exceed $effectiveMaxLength characters',
      );
    }

    if (!allowSpecialChars && _containsSuspiciousContent(input)) {
      return ValidationError.invalidInput(
        fieldName,
        '$fieldName contains invalid characters',
      );
    }

    return null;
  }

  /// Validate numeric range
  static ValidationError? validateNumericRange(
    num? value,
    String fieldName, {
    num? min,
    num? max,
    bool required = false,
  }) {
    if (value == null) {
      if (required) {
        return ValidationError.invalidInput(
          fieldName,
          '$fieldName is required',
        );
      }
      return null;
    }

    if (min != null && value < min) {
      return ValidationError.invalidInput(
        fieldName,
        '$fieldName must be at least $min',
      );
    }

    if (max != null && value > max) {
      return ValidationError.invalidInput(
        fieldName,
        '$fieldName cannot exceed $max',
      );
    }

    // Check for NaN or infinite values
    if (value.isNaN || value.isInfinite) {
      return ValidationError.invalidInput(
        fieldName,
        '$fieldName must be a valid number',
      );
    }

    return null;
  }

  /// Validate calculation inputs to prevent overflow
  static ValidationError? validateCalculationInputs(
    Map<String, dynamic> inputs,
  ) {
    for (final entry in inputs.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is num) {
        // Check for extreme values that could cause overflow
        if (value.abs() > 1e10) {
          return ValidationError.invalidInput(
            key,
            'Value is too large for calculation',
          );
        }

        if (value.isNaN || value.isInfinite) {
          return ValidationError.invalidInput(key, 'Invalid numeric value');
        }
      }
    }

    return null;
  }

  /// Sanitize string input by removing potentially dangerous characters
  static String sanitizeString(String input) {
    // Remove null bytes and control characters
    String sanitized = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Remove potential script injection patterns
    sanitized = sanitized.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      '',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'javascript:', caseSensitive: false),
      '',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'on\w+\s*=', caseSensitive: false),
      '',
    );

    // Trim whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Sanitize numeric input to prevent overflow
  static num sanitizeNumeric(num input) {
    if (input.isNaN || input.isInfinite) {
      return 0;
    }

    // Clamp to reasonable bounds
    return input.clamp(-1e10, 1e10);
  }

  /// Check if text contains suspicious content
  static bool _containsSuspiciousContent(String text) {
    // Check for script injection patterns
    final suspiciousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
      RegExp(r'<object', caseSensitive: false),
      RegExp(r'<embed', caseSensitive: false),
      RegExp(r'eval\s*\(', caseSensitive: false),
      RegExp(r'expression\s*\(', caseSensitive: false),
    ];

    for (final pattern in suspiciousPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }

    // Check for excessive special characters (potential injection)
    final specialCharCount = RegExp(r'[<>{}()[\]&;]').allMatches(text).length;
    if (specialCharCount > text.length * 0.1) {
      return true;
    }

    return false;
  }

  /// Validate that a calculation result is safe
  static ValidationError? validateCalculationResult(
    num result,
    String operation,
  ) {
    if (result.isNaN) {
      return ValidationError.invalidInput(
        'calculation',
        'Calculation resulted in invalid value (NaN)',
      );
    }

    if (result.isInfinite) {
      return ValidationError.invalidInput(
        'calculation',
        'Calculation resulted in infinite value',
      );
    }

    // Check for reasonable bounds based on operation
    if (operation.contains('water') || operation.contains('hydration')) {
      if (result < 0 || result > maxDailyIntake) {
        return ValidationError.invalidInput(
          'calculation',
          'Calculation result is outside safe hydration bounds',
        );
      }
    }

    return null;
  }

  /// Generate secure random values for testing (with bounds)
  static int generateSecureRandomInt(int min, int max) {
    final random = Random.secure();
    return min + random.nextInt(max - min + 1);
  }

  /// Generate secure random double (with bounds)
  static double generateSecureRandomDouble(double min, double max) {
    final random = Random.secure();
    return min + random.nextDouble() * (max - min);
  }

  /// Validate that an ID is safe (for database operations)
  static ValidationError? validateId(String? id, String fieldName) {
    if (id == null || id.isEmpty) {
      return ValidationError.invalidInput(fieldName, '$fieldName is required');
    }

    // Check for reasonable length
    if (id.length > 100) {
      return ValidationError.invalidInput(fieldName, '$fieldName is too long');
    }

    // Check for safe characters only (alphanumeric, hyphens, underscores)
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(id)) {
      return ValidationError.invalidInput(
        fieldName,
        '$fieldName contains invalid characters',
      );
    }

    return null;
  }

  /// Validate date to prevent time-based attacks
  static ValidationError? validateDate(DateTime? date, String fieldName) {
    if (date == null) {
      return ValidationError.invalidInput(fieldName, '$fieldName is required');
    }

    final now = DateTime.now();
    final minDate = DateTime(1900);
    final maxDate = now.add(
      const Duration(days: 365),
    ); // Allow 1 year in future

    if (date.isBefore(minDate)) {
      return ValidationError.invalidInput(
        fieldName,
        '$fieldName cannot be before year 1900',
      );
    }

    if (date.isAfter(maxDate)) {
      return ValidationError.invalidInput(
        fieldName,
        '$fieldName cannot be more than 1 year in the future',
      );
    }

    return null;
  }
}
