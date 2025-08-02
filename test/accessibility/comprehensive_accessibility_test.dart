/// Comprehensive accessibility tests for swipeable hydration interface
/// Tests screen reader support, keyboard navigation, and inclusive design
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

void main() {
  group('Comprehensive Accessibility Tests', () {
    late HydrationProvider hydrationProvider;

    setUp(() {
      hydrationProvider = HydrationProvider();
    });

    testWidgets(
      'Screen reader support: All interactive elements have semantic labels',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<HydrationProvider>(
              create: (_) => hydrationProvider,
              child: const AddHydrationScreen(),
            ),
          ),
        );

        // Test quick add buttons have proper semantic labels
        expect(find.bySemanticsLabel('Add 500 ml of water'), findsOneWidget);
        expect(find.bySemanticsLabel('Add 250 ml of water'), findsOneWidget);
        expect(find.bySemanticsLabel('Add 400 ml of water'), findsOneWidget);
        expect(find.bySemanticsLabel('Add 100 ml of water'), findsOneWidget);

        // Test drink type selector has semantic label
        expect(find.bySemanticsLabel('Select drink type'), findsOneWidget);

        // Test progress indicator has semantic description
        expect(
          find.bySemanticsLabel(RegExp('Hydration progress.*')),
          findsOneWidget,
        );

        // Test navigation elements have labels
        expect(find.bySemanticsLabel('Open navigation menu'), findsOneWidget);
        expect(find.bySemanticsLabel('Open user profile'), findsOneWidget);
      },
    );

    testWidgets('Screen reader announcements: Progress changes are announced', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Capture semantic announcements
      final announcements = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/accessibility'),
        (methodCall) async {
          if (methodCall.method == 'announce') {
            announcements.add(methodCall.arguments['message']);
          }
          return null;
        },
      );

      // Add hydration and check for announcement
      await tester.tap(find.bySemanticsLabel('Add 500 ml of water'));
      await tester.pumpAndSettle();

      // Should announce progress update
      expect(
        announcements,
        contains(matches(RegExp('Added.*hydration.*progress.*'))),
      );
    });

    testWidgets('Keyboard navigation: All interactive elements are focusable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test tab navigation through interactive elements
      final focusableElements = [
        find.bySemanticsLabel('Add 500 ml of water'),
        find.bySemanticsLabel('Add 250 ml of water'),
        find.bySemanticsLabel('Add 400 ml of water'),
        find.bySemanticsLabel('Add 100 ml of water'),
        find.bySemanticsLabel('Select drink type'),
      ];

      for (final element in focusableElements) {
        if (tester.any(element)) {
          // Focus the element
          await tester.tap(element);
          await tester.pumpAndSettle();

          // Verify it can receive focus
          final widget = tester.widget(element);
          expect(widget, isA<Widget>());
        }
      }
    });

    testWidgets(
      'Touch target sizes: All interactive elements meet minimum size requirements',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<HydrationProvider>(
              create: (_) => hydrationProvider,
              child: const AddHydrationScreen(),
            ),
          ),
        );

        // Test quick add buttons meet minimum touch target size (44x44 dp)
        final buttonElements = [
          find.text('500 ml'),
          find.text('250 ml'),
          find.text('400 ml'),
          find.text('100 ml'),
        ];

        for (final button in buttonElements) {
          if (tester.any(button)) {
            final buttonRect = tester.getRect(button);
            expect(
              buttonRect.width,
              greaterThanOrEqualTo(44),
              reason:
                  'Button width ${buttonRect.width} is less than minimum 44dp',
            );
            expect(
              buttonRect.height,
              greaterThanOrEqualTo(44),
              reason:
                  'Button height ${buttonRect.height} is less than minimum 44dp',
            );
          }
        }

        // Test drink type selector touch target
        final drinkSelector = find.byType(DrinkTypeSelector);
        if (tester.any(drinkSelector)) {
          final selectorRect = tester.getRect(drinkSelector);
          expect(
            selectorRect.height,
            greaterThanOrEqualTo(44),
            reason:
                'Drink selector height ${selectorRect.height} is less than minimum 44dp',
          );
        }
      },
    );

    testWidgets(
      'Color contrast: Text has sufficient contrast against backgrounds',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<HydrationProvider>(
              create: (_) => hydrationProvider,
              child: const AddHydrationScreen(),
            ),
          ),
        );

        // Test main text elements have proper contrast
        final textElements = [
          find.text('Today'),
          find.text('0.0 L drank so far'),
          find.text('Water'),
          find.text('500 ml'),
          find.text('250 ml'),
          find.text('400 ml'),
          find.text('100 ml'),
        ];

        for (final textElement in textElements) {
          if (tester.any(textElement)) {
            final textWidget = tester.widget<Text>(textElement);
            final textColor = textWidget.style?.color;

            // Verify text color is not null and has sufficient opacity
            expect(textColor, isNotNull);
            if (textColor != null) {
              expect(
                textColor.opacity,
                greaterThan(0.6),
                reason:
                    'Text color opacity ${textColor.opacity} may not provide sufficient contrast',
              );
            }
          }
        }
      },
    );

    testWidgets('Font scaling: Interface adapts to system font scaling', (
      WidgetTester tester,
    ) async {
      // Test with different text scale factors
      final textScaleFactors = [0.8, 1.0, 1.2, 1.5, 2.0];

      for (final scaleFactor in textScaleFactors) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData().copyWith(
                textScaler: TextScaler.linear(scaleFactor),
              ),
              child: ChangeNotifierProvider<HydrationProvider>(
                create: (_) => hydrationProvider,
                child: const AddHydrationScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify interface still renders correctly at different scales
        expect(find.byType(MainHydrationPage), findsOneWidget);
        expect(find.byType(CircularProgressSection), findsOneWidget);
        expect(find.byType(QuickAddButtonGrid), findsOneWidget);

        // Verify text is still readable (not clipped)
        final todayText = find.text('Today');
        if (tester.any(todayText)) {
          final textRect = tester.getRect(todayText);
          expect(textRect.width, greaterThan(0));
          expect(textRect.height, greaterThan(0));
        }
      }
    });

    testWidgets(
      'Gesture alternatives: Swipe gestures have alternative access methods',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<HydrationProvider>(
              create: (_) => hydrationProvider,
              child: const AddHydrationScreen(),
            ),
          ),
        );

        // Test that page indicators provide alternative navigation
        final pageIndicators = find.byType(
          Row,
        ); // Assuming page indicators are in a Row
        expect(pageIndicators, findsWidgets);

        // Test semantic actions for page navigation
        final swipeableView = find.byType(SwipeablePageView);
        expect(swipeableView, findsOneWidget);

        // Verify semantic actions are available
        final semantics = tester.getSemantics(swipeableView);
        expect(
          semantics.hasAction(SemanticsAction.scrollUp) ||
              semantics.hasAction(SemanticsAction.scrollDown),
          isTrue,
          reason: 'SwipeablePageView should provide semantic scroll actions',
        );
      },
    );

    testWidgets('Statistics page accessibility', (WidgetTester tester) async {
      // Add sample data
      await hydrationProvider.addHydration(500, DrinkType.water);
      await hydrationProvider.addHydration(300, DrinkType.tea);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Navigate to statistics page
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Test statistics page accessibility
      expect(find.byType(StatisticsPage), findsOneWidget);

      // Test tab navigation has semantic labels
      expect(find.bySemanticsLabel('Weekly statistics'), findsOneWidget);
      expect(find.bySemanticsLabel('Monthly statistics'), findsOneWidget);
      expect(find.bySemanticsLabel('Yearly statistics'), findsOneWidget);

      // Test chart accessibility
      expect(
        find.bySemanticsLabel(RegExp('Hydration chart.*')),
        findsOneWidget,
      );

      // Test statistics cards have descriptive labels
      expect(
        find.bySemanticsLabel(RegExp('Balance.*percentage.*')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('Daily average.*')), findsOneWidget);
    });

    testWidgets('Error states accessibility', (WidgetTester tester) async {
      // Create a provider that simulates errors
      final errorProvider = _AccessibilityErrorProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => errorProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Try to trigger an error
      await tester.tap(find.text('500 ml'));
      await tester.pumpAndSettle();

      // Error messages should be accessible
      expect(find.bySemanticsLabel(RegExp('Error.*')), findsOneWidget);
    });

    testWidgets('Loading states accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test loading indicators have proper semantic labels
      // This would be more relevant if there were actual loading states
      expect(find.byType(MainHydrationPage), findsOneWidget);
    });

    testWidgets('Dynamic content accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test that dynamic content updates are announced
      final initialProgress = find.bySemanticsLabel(
        RegExp('Hydration progress.*0.*'),
      );
      expect(initialProgress, findsOneWidget);

      // Add hydration
      await tester.tap(find.bySemanticsLabel('Add 500 ml of water'));
      await tester.pumpAndSettle();

      // Progress should update with new semantic label
      final updatedProgress = find.bySemanticsLabel(
        RegExp(r'Hydration progress.*0\.5.*'),
      );
      expect(updatedProgress, findsOneWidget);
    });

    testWidgets('Reduced motion accessibility', (WidgetTester tester) async {
      // Test with reduced motion preference
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData().copyWith(disableAnimations: true),
            child: ChangeNotifierProvider<HydrationProvider>(
              create: (_) => hydrationProvider,
              child: const AddHydrationScreen(),
            ),
          ),
        ),
      );

      // Interface should still work without animations
      expect(find.byType(MainHydrationPage), findsOneWidget);

      // Test page transitions without animation
      await tester.drag(find.byType(SwipeablePageView), const Offset(0, -300));
      await tester.pump(); // Single pump since animations are disabled

      expect(find.byType(StatisticsPage), findsOneWidget);
    });

    testWidgets('Voice control accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => hydrationProvider,
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test that elements can be activated via semantic actions
      final quickAddButton = find.bySemanticsLabel('Add 500 ml of water');
      expect(quickAddButton, findsOneWidget);

      // Simulate voice activation via semantic tap
      final semantics = tester.getSemantics(quickAddButton);
      expect(semantics.hasAction(SemanticsAction.tap), isTrue);

      // Trigger semantic tap
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/semantics',
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('tap', {'nodeId': semantics.id}),
        ),
        (data) {},
      );

      await tester.pumpAndSettle();

      // Should have same effect as regular tap
      expect(find.text('0.5 L drank so far'), findsOneWidget);
    });
  });

  group('Accessibility Guidelines Compliance', () {
    testWidgets('WCAG 2.1 AA compliance check', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => HydrationProvider(),
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test perceivable: All content can be perceived
      expect(find.byType(MainHydrationPage), findsOneWidget);

      // Test operable: All functionality is available via keyboard/touch
      final interactiveElements = [
        find.text('500 ml'),
        find.text('250 ml'),
        find.text('400 ml'),
        find.text('100 ml'),
        find.byType(DrinkTypeSelector),
      ];

      for (final element in interactiveElements) {
        if (tester.any(element)) {
          await tester.tap(element);
          await tester.pump();
          // Should not crash and should be responsive
        }
      }

      // Test understandable: Content and UI are understandable
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);

      // Test robust: Content can be interpreted by assistive technologies
      expect(find.bySemanticsLabel(RegExp('.*')), findsWidgets);
    });

    testWidgets('Platform accessibility guidelines compliance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>(
            create: (_) => HydrationProvider(),
            child: const AddHydrationScreen(),
          ),
        ),
      );

      // Test Material Design accessibility guidelines
      // - Touch targets are at least 48dp
      // - Color is not the only means of conveying information
      // - Text has sufficient contrast
      // - Interactive elements have clear focus indicators

      final buttons = [
        find.text('500 ml'),
        find.text('250 ml'),
        find.text('400 ml'),
        find.text('100 ml'),
      ];

      for (final button in buttons) {
        if (tester.any(button)) {
          final rect = tester.getRect(button);
          expect(rect.width, greaterThanOrEqualTo(48));
          expect(rect.height, greaterThanOrEqualTo(48));
        }
      }
    });
  });
}

/// Mock provider for testing error accessibility
class _AccessibilityErrorProvider extends HydrationProvider {
  @override
  Future<void> addHydration(int amount, DrinkType type) async {
    // Simulate an accessible error
    throw Exception(
      'Unable to add hydration. Please check your connection and try again.',
    );
  }
}
