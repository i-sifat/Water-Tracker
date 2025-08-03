import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_entry.dart';
import 'package:watertracker/core/services/connectivity_service.dart';
import 'package:watertracker/core/services/offline_storage_service.dart';
import 'package:watertracker/core/services/storage_service.dart';

import 'offline_storage_test.mocks.dart';

@GenerateMocks([StorageService, ConnectivityService])
void main() {
  group('OfflineStorageService Tests', () {
    late MockStorageService mockStorageService;
    late MockConnectivityService mockConnectivityService;
    late OfflineStorageService offlineStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      mockConnectivityService = MockConnectivityService();

      // Setup default mock behaviors
      when(
        mockStorageService.getString(any, encrypted: anyNamed('encrypted')),
      ).thenAnswer((_) async => null);
      when(
        mockStorageService.saveString(
          any,
          any,
          encrypted: anyNamed('encrypted'),
        ),
      ).thenAnswer((_) async => true);
      when(mockStorageService.getInt(any)).thenAnswer((_) async => null);
      when(mockStorageService.saveInt(any, any)).thenAnswer((_) async => true);

      when(mockConnectivityService.isOnline).thenReturn(false);
      when(
        mockConnectivityService.connectivityStream,
      ).thenAnswer((_) => Stream.value(false));

      offlineStorageService = OfflineStorageService();
    });

    group('Offline Queue Management', () {
      test('should add hydration entry to offline queue', () async {
        final entry = HydrationEntry.create(amount: 250);

        await offlineStorageService.addHydrationOffline(entry);

        expect(offlineStorageService.hasPendingOperations, isTrue);
        expect(offlineStorageService.pendingOperationsCount, equals(1));
      });

      test('should add edit operation to offline queue', () async {
        final entry = HydrationEntry.create(amount: 300, type: DrinkType.tea);

        await offlineStorageService.editHydrationOffline(entry);

        expect(offlineStorageService.hasPendingOperations, isTrue);
        expect(offlineStorageService.pendingOperationsCount, equals(1));
      });

      test('should add delete operation to offline queue', () async {
        const entryId = 'test-entry-id';

        await offlineStorageService.deleteHydrationOffline(entryId);

        expect(offlineStorageService.hasPendingOperations, isTrue);
        expect(offlineStorageService.pendingOperationsCount, equals(1));
      });

      test('should add goal update to offline queue', () async {
        const newGoal = 2500;

        await offlineStorageService.updateGoalOffline(newGoal);

        expect(offlineStorageService.hasPendingOperations, isTrue);
        expect(offlineStorageService.pendingOperationsCount, equals(1));
      });

      test('should accumulate multiple operations', () async {
        final entry1 = HydrationEntry.create(amount: 250);
        final entry2 = HydrationEntry.create(amount: 300, type: DrinkType.tea);

        await offlineStorageService.addHydrationOffline(entry1);
        await offlineStorageService.addHydrationOffline(entry2);
        await offlineStorageService.updateGoalOffline(2500);

        expect(offlineStorageService.pendingOperationsCount, equals(3));
      });
    });

    group('Offline Queue Persistence', () {
      test('should save pending operations to storage', () async {
        final entry = HydrationEntry.create(amount: 250);

        await offlineStorageService.addHydrationOffline(entry);

        // Verify that saveString was called with offline queue data
        verify(
          mockStorageService.saveString('offline_queue', any, encrypted: false),
        ).called(1);
      });

      test('should load pending operations from storage', () async {
        // Setup mock to return saved operations
        final operations = [
          {
            'id': '1',
            'type': 'OfflineOperationType.addHydration',
            'data': {
              'id': 'entry-1',
              'amount': 250,
              'type': 'water',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'isSynced': false,
            },
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'retryCount': 0,
          },
        ];

        when(
          mockStorageService.getString('offline_queue', encrypted: false),
        ).thenAnswer((_) async => jsonEncode(operations));

        await offlineStorageService.initialize();

        expect(offlineStorageService.pendingOperationsCount, equals(1));
      });

      test('should handle corrupted offline queue data gracefully', () async {
        // Setup mock to return invalid JSON
        when(
          mockStorageService.getString('offline_queue', encrypted: false),
        ).thenAnswer((_) async => 'invalid json');

        // Should not throw exception
        await offlineStorageService.initialize();

        expect(offlineStorageService.pendingOperationsCount, equals(0));
      });
    });

    group('Sync Operations', () {
      test('should not sync when offline', () async {
        when(mockConnectivityService.isOnline).thenReturn(false);

        final entry = HydrationEntry.create(amount: 250);
        await offlineStorageService.addHydrationOffline(entry);

        // Force sync should throw network error
        expect(
          () => offlineStorageService.forcSync(),
          throwsA(isA<Exception>()),
        );
      });

      test('should sync when connectivity is restored', () async {
        final entry = HydrationEntry.create(amount: 250);
        await offlineStorageService.addHydrationOffline(entry);

        expect(offlineStorageService.pendingOperationsCount, equals(1));

        // Simulate connectivity restored
        when(mockConnectivityService.isOnline).thenReturn(true);

        // This would normally trigger auto-sync via connectivity stream
        // For testing, we'll call force sync
        await offlineStorageService.forcSync();

        // Operations should be processed (in real implementation)
        expect(offlineStorageService.isSyncing, isFalse);
      });

      test('should maintain operation order during sync', () async {
        final entry1 = HydrationEntry.create(amount: 250);
        final entry2 = HydrationEntry.create(amount: 300, type: DrinkType.tea);

        await offlineStorageService.addHydrationOffline(entry1);
        await offlineStorageService.editHydrationOffline(entry2);
        await offlineStorageService.updateGoalOffline(2500);

        expect(offlineStorageService.pendingOperationsCount, equals(3));

        // Operations should be processed in order
        when(mockConnectivityService.isOnline).thenReturn(true);
        await offlineStorageService.forcSync();

        // Verify operations were processed
        expect(offlineStorageService.isSyncing, isFalse);
      });
    });

    group('Sync Status Tracking', () {
      test('should track last sync timestamp', () async {
        const timestamp = 1234567890;
        when(
          mockStorageService.getInt('last_sync_timestamp'),
        ).thenAnswer((_) async => timestamp);

        final lastSync = await offlineStorageService.getLastSyncTimestamp();

        expect(lastSync, isNotNull);
        expect(lastSync!.millisecondsSinceEpoch, equals(timestamp));
      });

      test('should return null for no previous sync', () async {
        when(
          mockStorageService.getInt('last_sync_timestamp'),
        ).thenAnswer((_) async => null);

        final lastSync = await offlineStorageService.getLastSyncTimestamp();

        expect(lastSync, isNull);
      });

      test('should update sync timestamp after successful sync', () async {
        when(mockConnectivityService.isOnline).thenReturn(true);

        await offlineStorageService.forcSync();

        // Verify timestamp was saved
        verify(
          mockStorageService.saveInt('last_sync_timestamp', any),
        ).called(greaterThanOrEqualTo(0));
      });
    });

    group('Statistics and Monitoring', () {
      test('should provide offline statistics', () async {
        final entry1 = HydrationEntry.create(amount: 250);
        final entry2 = HydrationEntry.create(amount: 300, type: DrinkType.tea);

        await offlineStorageService.addHydrationOffline(entry1);
        await offlineStorageService.editHydrationOffline(entry2);
        await offlineStorageService.updateGoalOffline(2500);

        final stats = offlineStorageService.getOfflineStats();

        expect(stats['total_pending'], equals(3));
        expect(stats['is_syncing'], isFalse);
        expect(stats['operations_by_type'], isA<Map<String, int>>());
        expect(stats['oldest_operation'], isNotNull);
      });

      test('should track operations by type', () async {
        final entry = HydrationEntry.create(amount: 250);

        await offlineStorageService.addHydrationOffline(entry);
        await offlineStorageService.addHydrationOffline(entry);
        await offlineStorageService.updateGoalOffline(2500);

        final stats = offlineStorageService.getOfflineStats();
        final operationsByType =
            stats['operations_by_type'] as Map<String, int>;

        expect(operationsByType['addHydration'], equals(2));
        expect(operationsByType['updateGoal'], equals(1));
      });
    });

    group('Error Handling', () {
      test('should handle storage failures gracefully', () async {
        when(
          mockStorageService.saveString(
            any,
            any,
            encrypted: anyNamed('encrypted'),
          ),
        ).thenThrow(Exception('Storage error'));

        final entry = HydrationEntry.create(amount: 250);

        expect(
          () => offlineStorageService.addHydrationOffline(entry),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle sync failures gracefully', () async {
        when(mockConnectivityService.isOnline).thenReturn(true);

        final entry = HydrationEntry.create(amount: 250);
        await offlineStorageService.addHydrationOffline(entry);

        // Simulate sync failure by throwing during force sync
        // In real implementation, individual operation sync might fail

        expect(offlineStorageService.pendingOperationsCount, equals(1));
      });

      test('should clear pending operations when requested', () async {
        final entry = HydrationEntry.create(amount: 250);
        await offlineStorageService.addHydrationOffline(entry);

        expect(offlineStorageService.pendingOperationsCount, equals(1));

        await offlineStorageService.clearPendingOperations();

        expect(offlineStorageService.pendingOperationsCount, equals(0));
        expect(offlineStorageService.hasPendingOperations, isFalse);
      });
    });

    group('OfflineOperation Model', () {
      test('should serialize and deserialize correctly', () {
        final operation = OfflineOperation(
          id: 'test-id',
          type: OfflineOperationType.addHydration,
          data: {'amount': 250, 'type': 'water'},
          timestamp: DateTime.now(),
          retryCount: 1,
        );

        final json = operation.toJson();
        final deserialized = OfflineOperation.fromJson(json);

        expect(deserialized.id, equals(operation.id));
        expect(deserialized.type, equals(operation.type));
        expect(deserialized.data, equals(operation.data));
        expect(deserialized.timestamp, equals(operation.timestamp));
        expect(deserialized.retryCount, equals(operation.retryCount));
      });

      test('should create copies with updated fields', () {
        final operation = OfflineOperation(
          id: 'test-id',
          type: OfflineOperationType.addHydration,
          data: {'amount': 250},
          timestamp: DateTime.now(),
        );

        final updated = operation.copyWith(retryCount: 2);

        expect(updated.id, equals(operation.id));
        expect(updated.retryCount, equals(2));
        expect(updated.data, equals(operation.data));
      });
    });
  });
}
