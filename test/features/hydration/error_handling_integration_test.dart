import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/services/storage_service.dart';
import 'package:watertracker/core/utils/error_handler.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';

import 'error_handling_integration_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  group('Error Handling Integration Tests', () {
    late MockStorageService mockStorageService;
    late HydrationProvider provider;

    setUp(() {
      mockStorageService = MockStorageService();

      // Setup default successful mock behaviors
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

      provider = HydrationProvider(storageService: mockStorageService);
    });

    group('Complete Error Handling Flow', () {
      testWidgets('should handle validation errors with user feedback', (
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

        // Test validation error handling
        try {
          await provider.addHydration(-100);
          fail('Should have thrown validation error');
        } catch (e) {
          expect(e, isA<ValidationError>());
          expect(provider.lastError, isA<ValidationError>());
        }

        // Verify provider state is consistent
        expect(provider.currentIntake, equals(0));
        expect(provider.hydrationHistory.length, equals(0));
      });

      testWidgets('should handle storage errors with recovery', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Setup storage to fail initially
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

        // Attempt to add hydration - should fail
        try {
          await provider.addHydration(250);
          fail('Should have thrown storage error');
        } catch (e) {
          expect(e, isA<StorageError>());
          expect(provider.lastError, isA<StorageError>());
        }

        // Verify state wasn't corrupted
        expect(provider.currentIntake, equals(0));
        expect(provider.hydrationHistory.length, equals(0));

        // Fix storage and retry
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

        // Should succeed now
        await provider.addHydration(250);
        expect(provider.currentIntake, equals(250));
        expect(provider.lastError, isNull);
      });

      testWidgets('should handle edge cases gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test daily limit validation
        await provider.addHydration(14000); // 14L
        expect(provider.currentIntake, equals(14000));

        // Should reject addition that exceeds daily limit
        try {
          await provider.addHydration(2000); // Would make 16L total
          fail('Should have thrown validation error');
        } catch (e) {
          expect(e, isA<ValidationError>());
          expect(e.toString(), contains('exceed safe daily intake limits'));
        }

        // Verify state is still consistent
        expect(provider.currentIntake, equals(14000));
      });

      testWidgets('should handle rapid operations without corruption', (
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

        // Perform rapid operations
        final futures = <Future<void>>[];
        for (var i = 0; i < 10; i++) {
          futures.add(provider.addHydration(100));
        }

        await Future.wait(futures);

        // Verify all operations completed successfully
        expect(provider.currentIntake, equals(1000));
        expect(provider.hydrationHistory.length, equals(10));
        expect(provider.lastError, isNull);
      });

      testWidgets('should handle mixed success and failure operations', (
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

        // Add some successful entries
        await provider.addHydration(250);
        await provider.addHydration(300);
        expect(provider.currentIntake, equals(550));

        // Try invalid operations
        try {
          await provider.addHydration(-100);
          fail('Should have thrown validation error');
        } catch (e) {
          expect(e, isA<ValidationError>());
        }

        try {
          await provider.addHydration(6000); // Over limit
          fail('Should have thrown validation error');
        } catch (e) {
          expect(e, isA<ValidationError>());
        }

        // Verify successful operations weren't affected
        expect(provider.currentIntake, equals(550));
        expect(provider.hydrationHistory.length, equals(2));

        // Add another successful entry
        await provider.addHydration(200);
        expect(provider.currentIntake, equals(750));
        expect(provider.hydrationHistory.length, equals(3));
        expect(provider.lastError, isNull);
      });
    });

    group('Error Recovery Scenarios', () {
      testWidgets('should recover from transient storage errors', (
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

        var saveAttempts = 0;
        when(mockStorageService.saveInt(any, any)).thenAnswer((_) async {
          saveAttempts++;
          if (saveAttempts <= 2) {
            throw Exception('Transient storage error');
          }
          return true;
        });

        when(
          mockStorageService.saveString(
            any,
            any,
            encrypted: anyNamed('encrypted'),
          ),
        ).thenAnswer((_) async {
          if (saveAttempts <= 2) {
            throw Exception('Transient storage error');
          }
          return true;
        });

        // First attempts should fail
        try {
          await provider.addHydration(250);
          fail('Should have thrown storage error');
        } catch (e) {
          expect(e, isA<StorageError>());
        }

        try {
          await provider.addHydration(250);
          fail('Should have thrown storage error');
        } catch (e) {
          expect(e, isA<StorageError>());
        }

        // Third attempt should succeed
        await provider.addHydration(250);
        expect(provider.currentIntake, equals(250));
        expect(provider.lastError, isNull);
      });

      testWidgets('should maintain data integrity during errors', (
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

        // Add successful entry
        await provider.addHydration(250);
        expect(provider.currentIntake, equals(250));

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

        // Try to add another entry - should fail and revert
        try {
          await provider.addHydration(300);
          fail('Should have thrown storage error');
        } catch (e) {
          expect(e, isA<StorageError>());
        }

        // Verify original state is preserved
        expect(provider.currentIntake, equals(250));
        expect(provider.hydrationHistory.length, equals(1));
        expect(provider.hydrationHistory.first.amount, equals(250));
      });
    });

    group('Validation Edge Cases', () {
      testWidgets('should validate all input parameters', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test various invalid amounts
        final invalidAmounts = [-1, 0, 5001, 10000];
        for (final amount in invalidAmounts) {
          try {
            await provider.addHydration(amount);
            fail('Should have thrown validation error for amount: $amount');
          } catch (e) {
            expect(e, isA<ValidationError>());
          }
        }

        // Test valid amounts
        final validAmounts = [1, 100, 250, 500, 1000, 5000];
        for (final amount in validAmounts) {
          await provider.addHydration(amount);
        }

        expect(provider.hydrationHistory.length, equals(validAmounts.length));
        expect(provider.lastError, isNull);
      });

      testWidgets('should validate notes length', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test valid notes
        await provider.addHydration(250, notes: 'Valid notes');
        expect(provider.hydrationHistory.length, equals(1));

        // Test empty notes (should be valid)
        await provider.addHydration(250, notes: '');
        expect(provider.hydrationHistory.length, equals(2));

        // Test null notes (should be valid)
        await provider.addHydration(250);
        expect(provider.hydrationHistory.length, equals(3));

        // Test long notes (should fail)
        final longNotes = 'a' * 501;
        try {
          await provider.addHydration(250, notes: longNotes);
          fail('Should have thrown validation error for long notes');
        } catch (e) {
          expect(e, isA<ValidationError>());
          expect(e.toString(), contains('cannot exceed 500 characters'));
        }

        // Verify state wasn't corrupted
        expect(provider.hydrationHistory.length, equals(3));
      });

      testWidgets('should validate goal settings', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(body: QuickAddButtonGrid()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test invalid goals
        final invalidGoals = [-1, 0, 100, 15000];
        for (final goal in invalidGoals) {
          try {
            await provider.setDailyGoal(goal);
            fail('Should have thrown validation error for goal: $goal');
          } catch (e) {
            expect(e, isA<ValidationError>());
          }
        }

        // Test valid goals
        final validGoals = [500, 1000, 2000, 3000, 10000];
        for (final goal in validGoals) {
          await provider.setDailyGoal(goal);
          expect(provider.dailyGoal, equals(goal));
        }

        expect(provider.lastError, isNull);
      });
    });

    group('Error State Management', () {
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
        try {
          await provider.addHydration(-100);
          fail('Should have thrown validation error');
        } catch (e) {
          expect(e, isA<ValidationError>());
        }

        expect(provider.lastError, isA<ValidationError>());

        // Successful operation should clear error
        await provider.addHydration(250);
        expect(provider.lastError, isNull);
        expect(provider.currentIntake, equals(250));
      });

      testWidgets('should maintain error state until cleared', (tester) async {
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

        // Cause storage error
        try {
          await provider.addHydration(250);
          fail('Should have thrown storage error');
        } catch (e) {
          expect(e, isA<StorageError>());
        }

        expect(provider.lastError, isA<StorageError>());

        // Error should persist until manually cleared or successful operation
        expect(provider.lastError, isA<StorageError>());

        // Clear error manually
        provider.clearError();
        expect(provider.lastError, isNull);
      });
    });
  });

  group('ErrorHandler Utility Integration', () {
    test('should provide comprehensive validation', () {
      // Test hydration amount validation
      expect(ErrorHandler.validateHydrationAmount(-1), isA<ValidationError>());
      expect(ErrorHandler.validateHydrationAmount(0), isA<ValidationError>());
      expect(
        ErrorHandler.validateHydrationAmount(6000),
        isA<ValidationError>(),
      );
      expect(ErrorHandler.validateHydrationAmount(250), isNull);

      // Test goal validation
      expect(ErrorHandler.validateDailyGoal(-1), isA<ValidationError>());
      expect(ErrorHandler.validateDailyGoal(0), isA<ValidationError>());
      expect(ErrorHandler.validateDailyGoal(100), isA<ValidationError>());
      expect(ErrorHandler.validateDailyGoal(15000), isA<ValidationError>());
      expect(ErrorHandler.validateDailyGoal(2000), isNull);

      // Test notes validation
      expect(ErrorHandler.validateNotes('a' * 501), isA<ValidationError>());
      expect(ErrorHandler.validateNotes('Valid notes'), isNull);
      expect(ErrorHandler.validateNotes(null), isNull);
    });

    test('should handle retry operations correctly', () async {
      var attemptCount = 0;

      final result = await ErrorHandler.retryOperation<String>(
        () async {
          attemptCount++;
          if (attemptCount < 3) {
            throw Exception('Temporary failure');
          }
          return 'Success';
        },
        initialDelay: const Duration(milliseconds: 1),
      );

      expect(result, equals('Success'));
      expect(attemptCount, equals(3));
    });

    test('should provide safe async operations', () async {
      // Test successful operation
      final success = await ErrorHandler.safeAsync<String>(
        () async => 'Success',
      );
      expect(success, equals('Success'));

      // Test failed operation with fallback
      final fallback = await ErrorHandler.safeAsync<String>(
        () async => throw Exception('Error'),
        fallback: 'Fallback',
      );
      expect(fallback, equals('Fallback'));

      // Test failed operation without fallback
      final nullResult = await ErrorHandler.safeAsync<String>(
        () async => throw Exception('Error'),
      );
      expect(nullResult, isNull);
    });
  });
}
