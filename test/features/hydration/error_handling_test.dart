import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/services/connectivity_service.dart';
import 'package:watertracker/core/services/offline_storage_service.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/core/utils/error_handler.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';

import 'error_handling_test.mocks.dart';

@GenerateMocks([StorageService, ConnectivityService, OfflineStorageService])
void main() {
  group('Error Handling Tests', () {
    late MockStorageService mockStorageService;
    late MockConnectivityService mockConnectivityService;
    late MockOfflineStorageService mockOfflineStorageService;
    late HydrationProvider provider;

    setUp(() {
      mockStorageService = MockStorageService();
      mockConnectivityService = MockConnectivityService();
      mockOfflineStorageService = MockOfflineStorageService();

      // Setup default mock behaviors
      when(mockStorageService.initialize()).thenAnswer((_) async {});
      when(mockStorageService.getInt(any)).thenAnswer((_) async => null);
      when(
        mockStorageService.getString(any, encrypted: anyNamed('encrypted')),
      ).thenAnswer((_) async => null);
      when(
        mockStorageService.getBool(any, encrypted: anyNamed('encrypted')),
      ).thenAnswer((_) async => null);
      when(mockStorageService.saveInt(any, any)).thenAnswer((_) async => true);
      when(
        mockStorageService.saveString(
          any,
          any,
          encrypted: anyNamed('encrypted'),
        ),
      ).thenAnswer((_) async => true);
      when(
        mockStorageService.saveBool(any, value: anyNamed('value')),
      ).thenAnswer((_) async => true);

      when(mockConnectivityService.isOnline).thenReturn(true);
      when(
        mockConnectivityService.connectivityStream,
      ).thenAnswer((_) => Stream.value(true));

      provider = HydrationProvider(storageService: mockStorageService);
    });

    group('Validation Tests', () {
      testWidgets('should reject negative hydration amounts', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        // Wait for provider to initialize
        await tester.pumpAndSettle();

        expect(
          () => provider.addHydration(-100),
          throwsA(isA<ValidationError>()),
        );
      });

      testWidgets('should reject zero hydration amounts', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(() => provider.addHydration(0), throwsA(isA<ValidationError>()));
      });

      testWidgets('should reject excessive hydration amounts', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          () => provider.addHydration(6000), // Over 5000ml limit
          throwsA(isA<ValidationError>()),
        );
      });

      testWidgets('should reject invalid daily goals', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test negative goal
        expect(
          () => provider.setDailyGoal(-1000),
          throwsA(isA<ValidationError>()),
        );

        // Test zero goal
        expect(() => provider.setDailyGoal(0), throwsA(isA<ValidationError>()));

        // Test too low goal
        expect(
          () => provider.setDailyGoal(100),
          throwsA(isA<ValidationError>()),
        );

        // Test too high goal
        expect(
          () => provider.setDailyGoal(15000),
          throwsA(isA<ValidationError>()),
        );
      });

      testWidgets('should reject excessively long notes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final longNotes = 'a' * 501; // Over 500 character limit

        expect(
          () => provider.addHydration(250, notes: longNotes),
          throwsA(isA<ValidationError>()),
        );
      });

      testWidgets('should reject empty entry IDs for edit/delete', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          () => provider.editHydrationEntry(''),
          throwsA(isA<ValidationError>()),
        );

        expect(
          () => provider.deleteHydrationEntry(''),
          throwsA(isA<ValidationError>()),
        );
      });
    });

    group('Storage Error Handling', () {
      testWidgets('should handle storage write failures gracefully', (
        tester,
      ) async {
        // Setup storage to fail on save
        when(
          mockStorageService.saveInt(any, any),
        ).thenThrow(Exception('Storage full'));
        when(
          mockStorageService.saveString(
            any,
            any,
            encrypted: anyNamed('encrypted'),
          ),
        ).thenThrow(Exception('Storage full'));

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(() => provider.addHydration(250), throwsA(isA<StorageError>()));

        // Verify provider state wasn't corrupted
        expect(provider.lastError, isA<StorageError>());
      });

      testWidgets('should handle storage read failures gracefully', (
        tester,
      ) async {
        // Setup storage to fail on read
        when(
          mockStorageService.getString(any, encrypted: anyNamed('encrypted')),
        ).thenThrow(Exception('Storage corrupted'));

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Provider should still be usable despite read failure
        expect(provider.isInitialized, isTrue);
        expect(provider.lastError, isA<StorageError>());
      });
    });

    group('Network Error Handling', () {
      testWidgets('should handle network connectivity issues', (tester) async {
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(
          mockConnectivityService.connectivityStream,
        ).thenAnswer((_) => Stream.value(false));

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should still be able to add hydration offline
        await provider.addHydration(250);
        expect(provider.currentIntake, equals(250));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle rapid successive additions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Add multiple entries rapidly
        final futures = <Future<void>>[];
        for (var i = 0; i < 10; i++) {
          futures.add(provider.addHydration(100));
        }

        await Future.wait(futures);

        expect(provider.currentIntake, equals(1000));
        expect(provider.hydrationHistory.length, equals(10));
      });

      testWidgets('should handle daily intake limits', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Add large amount to approach daily limit
        await provider.addHydration(14000); // 14L

        // Should reject addition that would exceed 15L daily limit
        expect(
          () => provider.addHydration(2000), // Would make 16L total
          throwsA(isA<ValidationError>()),
        );
      });

      testWidgets('should handle non-existent entry operations', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          () => provider.editHydrationEntry('non-existent-id', amount: 250),
          throwsA(isA<ValidationError>()),
        );

        expect(
          () => provider.deleteHydrationEntry('non-existent-id'),
          throwsA(isA<ValidationError>()),
        );
      });
    });

    group('Error Recovery', () {
      testWidgets('should recover from transient errors', (tester) async {
        var failCount = 0;
        when(mockStorageService.saveInt(any, any)).thenAnswer((_) async {
          if (failCount < 2) {
            failCount++;
            throw Exception('Transient error');
          }
          return true;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // First attempt should fail
        expect(() => provider.addHydration(250), throwsA(isA<StorageError>()));

        // Reset mock for retry
        when(
          mockStorageService.saveInt(any, any),
        ).thenAnswer((_) async => true);
        when(
          mockStorageService.saveString(
            any,
            any,
            encrypted: anyNamed('encrypted'),
          ),
        ).thenAnswer((_) async => true);

        // Retry should succeed
        await provider.addHydration(250);
        expect(provider.currentIntake, equals(250));
        expect(provider.lastError, isNull);
      });

      testWidgets('should clear errors after successful operations', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Cause an error
        expect(
          () => provider.addHydration(-100),
          throwsA(isA<ValidationError>()),
        );

        expect(provider.lastError, isA<ValidationError>());

        // Successful operation should clear error
        await provider.addHydration(250);
        expect(provider.lastError, isNull);
      });
    });

    group('User Feedback', () {
      testWidgets('should show appropriate error messages in UI', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Setup storage to fail
        when(
          mockStorageService.saveInt(any, any),
        ).thenThrow(Exception('Storage error'));
        when(
          mockStorageService.saveString(
            any,
            any,
            encrypted: anyNamed('encrypted'),
          ),
        ).thenThrow(Exception('Storage error'));

        // Tap a quick add button
        await tester.tap(find.text('250 ml'));
        await tester.pumpAndSettle();

        // Should show error snackbar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('Failed to save hydration data. Please try again.'),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsOneWidget);
      });
    });
  });

  group('ErrorHandler Utility Tests', () {
    testWidgets('should validate hydration amounts correctly', (tester) async {
      expect(ErrorHandler.validateHydrationAmount(-1), isA<ValidationError>());
      expect(ErrorHandler.validateHydrationAmount(0), isA<ValidationError>());
      expect(
        ErrorHandler.validateHydrationAmount(6000),
        isA<ValidationError>(),
      );
      expect(ErrorHandler.validateHydrationAmount(250), isNull);
    });

    testWidgets('should validate daily goals correctly', (tester) async {
      expect(ErrorHandler.validateDailyGoal(-1), isA<ValidationError>());
      expect(ErrorHandler.validateDailyGoal(0), isA<ValidationError>());
      expect(ErrorHandler.validateDailyGoal(100), isA<ValidationError>());
      expect(ErrorHandler.validateDailyGoal(15000), isA<ValidationError>());
      expect(ErrorHandler.validateDailyGoal(2000), isNull);
    });

    testWidgets('should validate notes correctly', (tester) async {
      expect(ErrorHandler.validateNotes('a' * 501), isA<ValidationError>());
      expect(ErrorHandler.validateNotes('Valid notes'), isNull);
      expect(ErrorHandler.validateNotes(null), isNull);
    });
  });
}
