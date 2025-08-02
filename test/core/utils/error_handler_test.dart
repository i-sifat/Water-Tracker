import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler Tests', () {
    group('Error Conversion', () {
      testWidgets('should convert SocketException to NetworkError', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleError(
                        context,
                        const SocketException('No internet'),
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('No internet connection available'), findsOneWidget);
      });

      testWidgets('should convert TimeoutException to NetworkError', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleError(
                        context,
                        TimeoutException('Timeout', const Duration(seconds: 5)),
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Request timed out'), findsOneWidget);
      });

      testWidgets('should convert FormatException to ValidationError', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleError(
                        context,
                        const FormatException('Invalid format'),
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Invalid data format'), findsOneWidget);
      });

      testWidgets('should handle AppError directly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleError(
                        context,
                        ValidationError.invalidInput('test', 'Test error'),
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Test error'), findsOneWidget);
      });
    });

    group('User Feedback', () {
      testWidgets('should show custom error message when provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleError(
                        context,
                        Exception('Generic error'),
                        customMessage: 'Custom error message',
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Custom error message'), findsOneWidget);
      });

      testWidgets('should show retry button when onRetry provided', (
        tester,
      ) async {
        var retryPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleError(
                        context,
                        Exception('Test error'),
                        onRetry: () => retryPressed = true,
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(retryPressed, isTrue);
      });

      testWidgets('should not show snackbar when showSnackBar is false', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleError(
                        context,
                        Exception('Test error'),
                        showSnackBar: false,
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsNothing);
      });
    });

    group('Error Dialog', () {
      testWidgets('should show error dialog with title and message', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.showErrorDialog(
                        context,
                        'Error Title',
                        'Error message',
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Error Title'), findsOneWidget);
        expect(find.text('Error message'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
      });

      testWidgets('should show retry button in dialog when provided', (
        tester,
      ) async {
        var retryPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.showErrorDialog(
                        context,
                        'Error Title',
                        'Error message',
                        onRetry: () => retryPressed = true,
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(retryPressed, isTrue);
      });
    });

    group('Validation Methods', () {
      test('should validate hydration amounts correctly', () {
        expect(
          ErrorHandler.validateHydrationAmount(-1),
          isA<ValidationError>(),
        );
        expect(ErrorHandler.validateHydrationAmount(0), isA<ValidationError>());
        expect(
          ErrorHandler.validateHydrationAmount(6000),
          isA<ValidationError>(),
        );
        expect(ErrorHandler.validateHydrationAmount(250), isNull);
        expect(ErrorHandler.validateHydrationAmount(1000), isNull);
        expect(ErrorHandler.validateHydrationAmount(5000), isNull);
      });

      test('should validate daily goals correctly', () {
        expect(ErrorHandler.validateDailyGoal(-1), isA<ValidationError>());
        expect(ErrorHandler.validateDailyGoal(0), isA<ValidationError>());
        expect(ErrorHandler.validateDailyGoal(100), isA<ValidationError>());
        expect(ErrorHandler.validateDailyGoal(15000), isA<ValidationError>());
        expect(ErrorHandler.validateDailyGoal(500), isNull);
        expect(ErrorHandler.validateDailyGoal(2000), isNull);
        expect(ErrorHandler.validateDailyGoal(10000), isNull);
      });

      test('should validate notes correctly', () {
        expect(ErrorHandler.validateNotes(null), isNull);
        expect(ErrorHandler.validateNotes(''), isNull);
        expect(ErrorHandler.validateNotes('Valid notes'), isNull);
        expect(ErrorHandler.validateNotes('a' * 500), isNull);
        expect(ErrorHandler.validateNotes('a' * 501), isA<ValidationError>());
      });
    });

    group('Network Utilities', () {
      test('should check network availability', () async {
        final isAvailable = await ErrorHandler.isNetworkAvailable();
        expect(isAvailable, isA<bool>());
      });

      testWidgets('should handle network errors specifically', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleNetworkError(context);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('Please check your internet connection and try again.'),
          findsOneWidget,
        );
      });

      testWidgets('should handle validation errors specifically', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleValidationError(
                        context,
                        'amount',
                        'Invalid amount',
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Invalid amount'), findsOneWidget);
      });

      testWidgets('should handle storage errors specifically', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await ErrorHandler.handleStorageError(context);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Failed to write data to storage'), findsOneWidget);
      });
    });

    group('Retry Operations', () {
      test('should retry operation with exponential backoff', () async {
        var attemptCount = 0;

        final result = await ErrorHandler.retryOperation<String>(
          () async {
            attemptCount++;
            if (attemptCount < 3) {
              throw Exception('Temporary failure');
            }
            return 'Success';
          },
          initialDelay: const Duration(milliseconds: 10),
        );

        expect(result, equals('Success'));
        expect(attemptCount, equals(3));
      });

      test('should throw after max retries exceeded', () async {
        var attemptCount = 0;

        expect(
          () => ErrorHandler.retryOperation<String>(
            () async {
              attemptCount++;
              throw Exception('Persistent failure');
            },
            maxRetries: 2,
            initialDelay: const Duration(milliseconds: 10),
          ),
          throwsA(isA<Exception>()),
        );

        expect(attemptCount, equals(2));
      });
    });

    group('Safe Async Operations', () {
      test('should return result on success', () async {
        final result = await ErrorHandler.safeAsync<String>(
          () async => 'Success',
        );

        expect(result, equals('Success'));
      });

      test('should return fallback on error', () async {
        final result = await ErrorHandler.safeAsync<String>(
          () async => throw Exception('Error'),
          fallback: 'Fallback',
        );

        expect(result, equals('Fallback'));
      });

      test('should return null when no fallback provided', () async {
        final result = await ErrorHandler.safeAsync<String>(
          () async => throw Exception('Error'),
        );

        expect(result, isNull);
      });
    });

    group('Context Safety', () {
      testWidgets('should handle unmounted context gracefully', (tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  capturedContext = context;
                  return const Text('Test');
                },
              ),
            ),
          ),
        );

        // Remove the widget to unmount the context
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));

        // Should not throw when context is unmounted
        expect(
          () => ErrorHandler.handleError(
            capturedContext,
            Exception('Test error'),
          ),
          returnsNormally,
        );
      });
    });
  });

  group('SafeContext Extension Tests', () {
    testWidgets('should check if context is mounted', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedContext = context;
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      expect(capturedContext.isMounted, isTrue);

      // Remove the widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      expect(capturedContext.isMounted, isFalse);
    });

    testWidgets('should safely navigate when mounted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await context.safePush(
                      MaterialPageRoute<void>(
                        builder: (_) => const Scaffold(body: Text('New Page')),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('New Page'), findsOneWidget);
    });

    testWidgets('should safely show snackbar when mounted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    context.safeShowSnackBar(
                      const SnackBar(content: Text('Test SnackBar')),
                    );
                  },
                  child: const Text('Show SnackBar'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show SnackBar'));
      await tester.pumpAndSettle();

      expect(find.text('Test SnackBar'), findsOneWidget);
    });
  });
}
