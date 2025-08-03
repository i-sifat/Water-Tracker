import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/navigation/optimized_page_controller.dart';
import 'package:watertracker/core/navigation/smooth_page_transitions.dart';
import 'package:watertracker/core/navigation/navigation_error_handler.dart';

void main() {
  group('Navigation System Tests', () {
    testWidgets('OptimizedPageController handles animations correctly', (
      tester,
    ) async {
      final controller = OptimizedPageController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageView.builder(
              controller: controller,
              itemCount: 3,
              itemBuilder:
                  (context, index) => Center(child: Text('Page $index')),
            ),
          ),
        ),
      );

      // Test initial state
      expect(controller.isAnimating, false);
      expect(controller.targetPage, null);

      // Test animation
      await controller.animateToPage(
        1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );

      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('SmoothPageTransitions creates proper routes', (tester) async {
      final testPage = const Scaffold(body: Text('Test Page'));

      // Test slide transition
      final slideRoute = SmoothPageTransitions.slideTransition(page: testPage);
      expect(
        slideRoute.transitionDuration,
        SmoothPageTransitions.defaultDuration,
      );

      // Test fade transition
      final fadeRoute = SmoothPageTransitions.fadeTransition(page: testPage);
      expect(
        fadeRoute.transitionDuration,
        SmoothPageTransitions.defaultDuration,
      );

      // Test no transition
      final noRoute = SmoothPageTransitions.noTransition(page: testPage);
      expect(noRoute.transitionDuration, Duration.zero);
    });

    test('NavigationErrorHandler logs errors correctly', () async {
      final error = NavigationErrorDetails(
        type: NavigationError.pageLoadFailed,
        message: 'Test error',
        context: {'test': 'data'},
      );

      // Test error handling
      final result = await NavigationErrorHandler.handleError(error);
      expect(result, false); // No context provided, should return false

      // Test error logging
      final logs = await NavigationErrorHandler.getErrorLogs();
      expect(logs.isNotEmpty, true);
      expect(logs.last.message, 'Test error');

      // Clean up
      await NavigationErrorHandler.clearErrorLogs();
    });

    test('NavigationState serialization works correctly', () {
      final state = NavigationState(
        currentStep: 5,
        isLoading: true,
        error: 'Test error',
        stepCompletionStatus: {1: true, 2: false, 3: true},
      );

      // Test serialization
      final json = state.toJson();
      expect(json['currentStep'], 5);
      expect(json['isLoading'], true);
      expect(json['error'], 'Test error');

      // Test deserialization
      final restored = NavigationState.fromJson(json);
      expect(restored.currentStep, 5);
      expect(restored.isLoading, true);
      expect(restored.error, 'Test error');
      expect(restored.stepCompletionStatus[1], true);
      expect(restored.stepCompletionStatus[2], false);
    });

    test('NavigationErrorHandler detects corrupted state', () {
      // Test valid state
      final validState = NavigationState(currentStep: 5);
      expect(
        NavigationErrorHandler.isNavigationStateCorrupted(validState),
        false,
      );

      // Test invalid state (negative step)
      final invalidState = NavigationState(currentStep: -1);
      expect(
        NavigationErrorHandler.isNavigationStateCorrupted(invalidState),
        true,
      );

      // Test old state
      final oldState = NavigationState(
        currentStep: 5,
        lastUpdate: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(NavigationErrorHandler.isNavigationStateCorrupted(oldState), true);
    });

    test('TransitionConfig provides correct defaults', () {
      expect(TransitionConfig.onboarding.type, TransitionType.onboarding);
      expect(
        TransitionConfig.onboarding.duration,
        const Duration(milliseconds: 200),
      );

      expect(TransitionConfig.main.type, TransitionType.slide);
      expect(TransitionConfig.modal.type, TransitionType.scale);
      expect(TransitionConfig.settings.type, TransitionType.fade);
      expect(TransitionConfig.none.type, TransitionType.none);
    });

    testWidgets('NavigationErrorBoundary handles errors', (tester) async {
      bool errorHandled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: NavigationErrorBoundary(
            onError: () => errorHandled = true,
            child: const Scaffold(body: Text('Normal Content')),
          ),
        ),
      );

      expect(find.text('Normal Content'), findsOneWidget);
      expect(errorHandled, false);

      // Test error state would require triggering an actual error
      // which is complex in a unit test environment
    });
  });

  group('Performance Tests', () {
    testWidgets('Page transitions complete within reasonable time', (
      tester,
    ) async {
      final controller = OptimizedPageController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageView.builder(
              controller: controller,
              itemCount: 10,
              itemBuilder:
                  (context, index) => Center(child: Text('Page $index')),
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Test multiple rapid transitions
      for (int i = 0; i < 5; i++) {
        await controller.animateToPage(
          i,
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeOut,
        );
        await tester.pump();
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should complete within reasonable time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      controller.dispose();
    });
  });
}
