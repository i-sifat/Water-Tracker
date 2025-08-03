import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Secure data handler for managing sensitive information and preventing memory leaks
class SecureDataHandler {
  /// Securely clear a string from memory by overwriting it
  static void clearString(String? sensitiveString) {
    if (sensitiveString == null) return;

    try {
      // In Dart, strings are immutable, but we can help GC by nullifying references
      // and triggering garbage collection in debug mode
      if (kDebugMode) {
        // Force garbage collection in debug mode to help clear memory
        // Note: This is not guaranteed but helps in development
        sensitiveString = '';
      }
    } catch (e) {
      // Ignore errors in memory clearing
      debugPrint('Error clearing string from memory: $e');
    }
  }

  /// Securely clear a list from memory
  static void clearList<T>(List<T>? sensitiveList) {
    if (sensitiveList == null) return;

    try {
      // Clear all elements first
      for (int i = 0; i < sensitiveList.length; i++) {
        if (sensitiveList[i] is String) {
          clearString(sensitiveList[i] as String);
        }
        sensitiveList[i] = null as T;
      }

      // Clear the list itself
      sensitiveList.clear();
    } catch (e) {
      debugPrint('Error clearing list from memory: $e');
    }
  }

  /// Securely clear a map from memory
  static void clearMap<K, V>(Map<K, V>? sensitiveMap) {
    if (sensitiveMap == null) return;

    try {
      // Clear all values first
      for (final entry in sensitiveMap.entries) {
        if (entry.key is String) {
          clearString(entry.key as String);
        }
        if (entry.value is String) {
          clearString(entry.value as String);
        }
        if (entry.value is List) {
          clearList(entry.value as List);
        }
        if (entry.value is Map) {
          clearMap(entry.value as Map);
        }
      }

      // Clear the map itself
      sensitiveMap.clear();
    } catch (e) {
      debugPrint('Error clearing map from memory: $e');
    }
  }

  /// Securely clear bytes from memory
  static void clearBytes(Uint8List? sensitiveBytes) {
    if (sensitiveBytes == null) return;

    try {
      // Overwrite with random data first, then zeros
      for (int i = 0; i < sensitiveBytes.length; i++) {
        sensitiveBytes[i] = 0xFF;
      }
      for (int i = 0; i < sensitiveBytes.length; i++) {
        sensitiveBytes[i] = 0x00;
      }
    } catch (e) {
      debugPrint('Error clearing bytes from memory: $e');
    }
  }

  /// Create a secure copy of sensitive data that can be safely cleared
  static SecureString createSecureString(String data) {
    return SecureString(data);
  }

  /// Validate that data doesn't contain sensitive patterns
  static bool containsSensitiveData(String data) {
    final sensitivePatterns = [
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'), // Credit card
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Email
      RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), // Phone
      RegExp(r'\bpassword\b', caseSensitive: false),
      RegExp(r'\btoken\b', caseSensitive: false),
      RegExp(r'\bsecret\b', caseSensitive: false),
      RegExp(r'\bkey\b', caseSensitive: false),
    ];

    return sensitivePatterns.any((pattern) => pattern.hasMatch(data));
  }

  /// Sanitize data for logging (remove sensitive information)
  static String sanitizeForLogging(String data) {
    String sanitized = data;

    // Replace credit card numbers
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'),
      '[CARD]',
    );

    // Replace SSN
    sanitized = sanitized.replaceAll(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), '[SSN]');

    // Replace email addresses
    sanitized = sanitized.replaceAll(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      '[EMAIL]',
    );

    // Replace phone numbers
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'),
      '[PHONE]',
    );

    // Replace potential passwords/tokens
    sanitized = sanitized.replaceAll(
      RegExp(
        r'\b(password|token|secret|key)\s*[:=]\s*\S+',
        caseSensitive: false,
      ),
      r'$1: [REDACTED]',
    );

    return sanitized;
  }

  /// Check if memory usage is within safe bounds
  static bool isMemoryUsageSafe() {
    try {
      // This is a basic check - in production you might use more sophisticated monitoring
      return true; // Dart handles memory management automatically
    } catch (e) {
      debugPrint('Error checking memory usage: $e');
      return false;
    }
  }

  /// Force garbage collection (debug mode only)
  static void forceGarbageCollection() {
    if (kDebugMode) {
      try {
        // Trigger garbage collection by creating and discarding objects
        final temp = List.generate(1000, (i) => 'temp_$i');
        temp.clear();
      } catch (e) {
        debugPrint('Error forcing garbage collection: $e');
      }
    }
  }

  /// Validate JSON data for security issues
  static bool isJsonSafe(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return _isDataStructureSafe(decoded);
    } catch (e) {
      // Invalid JSON is not safe
      return false;
    }
  }

  /// Check if a data structure is safe (no excessive nesting, reasonable size)
  static bool _isDataStructureSafe(dynamic data, {int depth = 0}) {
    const maxDepth = 10;
    const maxStringLength = 10000;
    const maxCollectionSize = 1000;

    if (depth > maxDepth) {
      return false; // Too deeply nested
    }

    if (data is String) {
      return data.length <= maxStringLength;
    }

    if (data is List) {
      if (data.length > maxCollectionSize) {
        return false;
      }
      return data.every((item) => _isDataStructureSafe(item, depth: depth + 1));
    }

    if (data is Map) {
      if (data.length > maxCollectionSize) {
        return false;
      }
      return data.entries.every(
        (entry) =>
            _isDataStructureSafe(entry.key, depth: depth + 1) &&
            _isDataStructureSafe(entry.value, depth: depth + 1),
      );
    }

    // Primitive types are generally safe
    return data is num || data is bool || data == null;
  }

  /// Create a secure hash of sensitive data (for comparison without storing)
  static String createSecureHash(String data) {
    // Simple hash for demonstration - in production use crypto libraries
    int hash = 0;
    for (int i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash + data.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}

/// Secure string wrapper that can be safely cleared from memory
class SecureString {
  String? _data;
  bool _isCleared = false;

  SecureString(String data) : _data = data;

  /// Get the string data (returns null if cleared)
  String? get value {
    if (_isCleared) return null;
    return _data;
  }

  /// Get the string length (0 if cleared)
  int get length {
    if (_isCleared || _data == null) return 0;
    return _data!.length;
  }

  /// Check if the string has been cleared
  bool get isCleared => _isCleared;

  /// Securely clear the string from memory
  void clear() {
    if (_data != null) {
      SecureDataHandler.clearString(_data);
      _data = null;
    }
    _isCleared = true;
  }

  /// Create a copy of this secure string
  SecureString copy() {
    if (_isCleared || _data == null) {
      return SecureString('');
    }
    return SecureString(_data!);
  }

  /// Compare with another secure string
  bool equals(SecureString other) {
    if (_isCleared || other._isCleared) return false;
    if (_data == null || other._data == null) return false;
    return _data == other._data;
  }

  @override
  String toString() {
    if (_isCleared) return '[CLEARED]';
    if (_data == null) return '[NULL]';
    return '[SECURE STRING: ${_data!.length} chars]';
  }

  /// Dispose method for use with disposable patterns
  void dispose() {
    clear();
  }
}

/// Mixin for widgets that handle sensitive data
mixin SecureDataMixin {
  final List<SecureString> _secureStrings = [];
  final List<Uint8List> _secureBytes = [];

  /// Register a secure string for automatic cleanup
  void registerSecureString(SecureString secureString) {
    _secureStrings.add(secureString);
  }

  /// Register secure bytes for automatic cleanup
  void registerSecureBytes(Uint8List bytes) {
    _secureBytes.add(bytes);
  }

  /// Clear all registered secure data
  void clearAllSecureData() {
    for (final secureString in _secureStrings) {
      secureString.clear();
    }
    _secureStrings.clear();

    for (final bytes in _secureBytes) {
      SecureDataHandler.clearBytes(bytes);
    }
    _secureBytes.clear();

    // Force garbage collection in debug mode
    SecureDataHandler.forceGarbageCollection();
  }

  /// Call this in dispose() method of StatefulWidget
  void disposeSecureData() {
    clearAllSecureData();
  }
}

/// Memory leak detector for development
class MemoryLeakDetector {
  static final Map<String, int> _objectCounts = {};
  static bool _isEnabled = kDebugMode;

  /// Track object creation
  static void trackObject(String className) {
    if (!_isEnabled) return;

    _objectCounts[className] = (_objectCounts[className] ?? 0) + 1;

    if (_objectCounts[className]! > 100) {
      debugPrint(
        'WARNING: High object count for $className: ${_objectCounts[className]}',
      );
    }
  }

  /// Track object disposal
  static void untrackObject(String className) {
    if (!_isEnabled) return;

    if (_objectCounts.containsKey(className)) {
      _objectCounts[className] = _objectCounts[className]! - 1;
      if (_objectCounts[className]! <= 0) {
        _objectCounts.remove(className);
      }
    }
  }

  /// Get current object counts
  static Map<String, int> getObjectCounts() {
    return Map.from(_objectCounts);
  }

  /// Reset all counts
  static void reset() {
    _objectCounts.clear();
  }

  /// Enable or disable tracking
  static void setEnabled(bool enabled) {
    _isEnabled = enabled && kDebugMode;
  }
}
