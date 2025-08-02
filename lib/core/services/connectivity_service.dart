import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:watertracker/core/models/app_error.dart';

/// Service to handle network connectivity and offline scenarios
class ConnectivityService {
  factory ConnectivityService() => _instance;
  ConnectivityService._();
  static final ConnectivityService _instance = ConnectivityService._();

  bool _isOnline = true;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  Timer? _connectivityTimer;

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    await _checkConnectivity();
    _startPeriodicCheck();
  }

  /// Start periodic connectivity checks
  void _startPeriodicCheck() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (isConnected != _isOnline) {
        _isOnline = isConnected;
        _connectivityController.add(_isOnline);

        if (kDebugMode) {
          debugPrint(
            'Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}',
          );
        }
      }
    } catch (e) {
      if (_isOnline) {
        _isOnline = false;
        _connectivityController.add(_isOnline);

        if (kDebugMode) {
          debugPrint('Connectivity lost: $e');
        }
      }
    }
  }

  /// Force connectivity check
  Future<bool> checkConnectivity() async {
    await _checkConnectivity();
    return _isOnline;
  }

  /// Execute operation with connectivity check
  Future<T> executeWithConnectivity<T>(
    Future<T> Function() operation, {
    T? offlineFallback,
    bool requiresConnection = false,
  }) async {
    if (requiresConnection && !_isOnline) {
      throw NetworkError.noConnection();
    }

    try {
      return await operation();
    } catch (e) {
      if (e is SocketException || e is TimeoutException) {
        _isOnline = false;
        _connectivityController.add(_isOnline);

        if (offlineFallback != null) {
          return offlineFallback;
        }

        throw NetworkError.noConnection();
      }
      rethrow;
    }
  }

  /// Wait for connectivity to be restored
  Future<void> waitForConnectivity({Duration? timeout}) async {
    if (_isOnline) return;

    final completer = Completer<void>();
    late StreamSubscription<bool> subscription;

    subscription = connectivityStream.listen((isOnline) {
      if (isOnline) {
        subscription.cancel();
        completer.complete();
      }
    });

    if (timeout != null) {
      Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.completeError(NetworkError.timeout());
        }
      });
    }

    return completer.future;
  }

  /// Dispose resources
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }
}
