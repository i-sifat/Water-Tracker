import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/models/hydration_entry.dart';
import 'package:watertracker/core/services/connectivity_service.dart';
import 'package:watertracker/core/services/storage_service.dart';

/// Service for handling offline data storage and synchronization
class OfflineStorageService {
  factory OfflineStorageService() => _instance;
  OfflineStorageService._();
  static final OfflineStorageService _instance = OfflineStorageService._();

  final StorageService _storageService = StorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  static const String _offlineQueueKey = 'offline_queue';
  static const String _syncStatusKey = 'sync_status';
  static const String _lastSyncKey = 'last_sync_timestamp';

  final List<OfflineOperation> _pendingOperations = [];
  bool _isSyncing = false;
  StreamSubscription<bool>? _connectivitySubscription;

  /// Initialize offline storage service
  Future<void> initialize() async {
    await _loadPendingOperations();
    _setupConnectivityListener();
  }

  /// Load pending operations from storage
  Future<void> _loadPendingOperations() async {
    try {
      final queueJson = await _storageService.getString(
        _offlineQueueKey,
        encrypted: false,
      );

      if (queueJson != null) {
        final queueList = jsonDecode(queueJson) as List<dynamic>;
        _pendingOperations.clear();

        for (final operationJson in queueList) {
          try {
            final operation = OfflineOperation.fromJson(
              operationJson as Map<String, dynamic>,
            );
            _pendingOperations.add(operation);
          } catch (e) {
            debugPrint('Failed to parse offline operation: $e');
          }
        }

        debugPrint('Loaded ${_pendingOperations.length} pending operations');
      }
    } catch (e) {
      debugPrint('Failed to load pending operations: $e');
    }
  }

  /// Save pending operations to storage
  Future<void> _savePendingOperations() async {
    try {
      final queueJson = jsonEncode(
        _pendingOperations.map((op) => op.toJson()).toList(),
      );

      await _storageService.saveString(
        _offlineQueueKey,
        queueJson,
        encrypted: false,
      );
    } catch (e) {
      debugPrint('Failed to save pending operations: $e');
      throw StorageError.writeFailed('Failed to save offline queue');
    }
  }

  /// Setup connectivity listener for auto-sync
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isOnline,
    ) {
      if (isOnline && _pendingOperations.isNotEmpty && !_isSyncing) {
        _syncPendingOperations();
      }
    });
  }

  /// Add hydration entry to offline queue
  Future<void> addHydrationOffline(HydrationEntry entry) async {
    final operation = OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.addHydration,
      data: entry.toJson(),
      timestamp: DateTime.now(),
    );

    _pendingOperations.add(operation);
    await _savePendingOperations();

    debugPrint('Added hydration entry to offline queue: ${entry.id}');
  }

  /// Edit hydration entry in offline queue
  Future<void> editHydrationOffline(HydrationEntry entry) async {
    final operation = OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.editHydration,
      data: entry.toJson(),
      timestamp: DateTime.now(),
    );

    _pendingOperations.add(operation);
    await _savePendingOperations();

    debugPrint('Added hydration edit to offline queue: ${entry.id}');
  }

  /// Delete hydration entry in offline queue
  Future<void> deleteHydrationOffline(String entryId) async {
    final operation = OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.deleteHydration,
      data: {'entryId': entryId},
      timestamp: DateTime.now(),
    );

    _pendingOperations.add(operation);
    await _savePendingOperations();

    debugPrint('Added hydration deletion to offline queue: $entryId');
  }

  /// Update goal in offline queue
  Future<void> updateGoalOffline(int goal) async {
    final operation = OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.updateGoal,
      data: {'goal': goal},
      timestamp: DateTime.now(),
    );

    _pendingOperations.add(operation);
    await _savePendingOperations();

    debugPrint('Added goal update to offline queue: $goal');
  }

  /// Sync pending operations when online
  Future<void> _syncPendingOperations() async {
    if (_isSyncing || _pendingOperations.isEmpty) return;

    _isSyncing = true;

    try {
      debugPrint('Starting sync of ${_pendingOperations.length} operations');

      final operationsToSync = List<OfflineOperation>.from(_pendingOperations);
      final syncedOperations = <OfflineOperation>[];

      for (final operation in operationsToSync) {
        try {
          await _syncOperation(operation);
          syncedOperations.add(operation);
          debugPrint('Synced operation: ${operation.id}');
        } catch (e) {
          debugPrint('Failed to sync operation ${operation.id}: $e');
          // Stop syncing on first failure to maintain order
          break;
        }
      }

      // Remove successfully synced operations
      for (final syncedOp in syncedOperations) {
        _pendingOperations.remove(syncedOp);
      }

      await _savePendingOperations();

      if (syncedOperations.isNotEmpty) {
        await _updateLastSyncTimestamp();
        debugPrint(
          'Sync completed: ${syncedOperations.length} operations synced',
        );
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync individual operation
  Future<void> _syncOperation(OfflineOperation operation) async {
    switch (operation.type) {
      case OfflineOperationType.addHydration:
        // In a real app, this would sync to a server
        // For now, we just mark as synced locally
        await _markOperationSynced(operation);

      case OfflineOperationType.editHydration:
        await _markOperationSynced(operation);

      case OfflineOperationType.deleteHydration:
        await _markOperationSynced(operation);

      case OfflineOperationType.updateGoal:
        await _markOperationSynced(operation);
    }
  }

  /// Mark operation as synced (placeholder for actual sync logic)
  Future<void> _markOperationSynced(OfflineOperation operation) async {
    // In a real implementation, this would:
    // 1. Send data to server
    // 2. Handle server response
    // 3. Update local data with server response
    // 4. Mark as synced

    // For now, we simulate a successful sync
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Update last sync timestamp
  Future<void> _updateLastSyncTimestamp() async {
    await _storageService.saveInt(
      _lastSyncKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp() async {
    final timestamp = await _storageService.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Force sync pending operations
  Future<void> forcSync() async {
    if (!_connectivityService.isOnline) {
      throw NetworkError.noConnection();
    }

    await _syncPendingOperations();
  }

  /// Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;

  /// Check if there are pending operations
  bool get hasPendingOperations => _pendingOperations.isNotEmpty;

  /// Get sync status
  bool get isSyncing => _isSyncing;

  /// Clear all pending operations (for testing)
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
  }

  /// Get offline storage statistics
  Map<String, dynamic> getOfflineStats() {
    final operationsByType = <String, int>{};

    for (final op in _pendingOperations) {
      final typeName = op.type.toString().split('.').last;
      operationsByType[typeName] = (operationsByType[typeName] ?? 0) + 1;
    }

    return {
      'total_pending': _pendingOperations.length,
      'is_syncing': _isSyncing,
      'operations_by_type': operationsByType,
      'oldest_operation':
          _pendingOperations.isNotEmpty
              ? _pendingOperations.first.timestamp.toIso8601String()
              : null,
    };
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

/// Represents an offline operation to be synced later
class OfflineOperation {
  const OfflineOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: OfflineOperationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'retryCount': retryCount,
    };
  }

  OfflineOperation copyWith({
    String? id,
    OfflineOperationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return OfflineOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Types of offline operations
enum OfflineOperationType {
  addHydration,
  editHydration,
  deleteHydration,
  updateGoal,
}
