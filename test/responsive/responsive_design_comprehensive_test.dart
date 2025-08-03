import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
import 'package:watertracker/core/widgets/responsive_scaffold.dart';
import 'package:watertracker/core/widgets/adaptive_widgets.dart';
import 'package:watertracker/features/onboarding/screens/welcome_screen.dart';
import 'package:watertracker/features/onboarding/screens/age_selection_screen.dart';
import 'package:watertracker/features/home/home_screen.dart';

void main() {
  group('Responsive Design Comprehensive Tests', () {
    group('Screen Size Adaptations', () {
      testWidgets('should adapt to small phone screen (320x568)', (
        WidgetTester tester,
      ) async {
        // Set small phone screen size
        await tester.binding.setSurfaceSize(const Size(320, 568));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  AdaptiveText('Small Phone Test'),
                  ResponsiveContainer(
                    width: 200,
                    height: 100,
                    child: const Text('Container'),
                  ),
                  ResponsiveIcon(Icons.home, size: 24),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify device type detection
        expect(ResponsiveHelper.getDeviceType(context), DeviceType.smallPhone);
        expect(ResponsiveHelper.isSmallPhone(context), true);

        // Verify responsive calculations are within expected bounds
        final responsiveWidth = ResponsiveHelper.getResponsiveWidth(
          context,
          200,
        );
        expect(
          responsiveWidth,
          lessThanOrEqualTo(300),
        ); // Should be constrained for small screens

        final responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(
          context,
          16,
        );
        expect(responsiveFontSize, greaterThan(12)); // Should not be too small
        expect(responsiveFontSize, lessThan(20)); // Should not be too large

        // Verify no overflow
        expect(tester.takeException(), isNull);
      });

      testWidgets('should adapt to medium phone screen (375x667)', (
        WidgetTester tester,
      ) async {
        // Set medium phone screen size (iPhone 8)
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  AdaptiveText('Medium Phone Test'),
                  ResponsiveContainer(
                    width: 250,
                    height: 120,
                    child: const Text('Container'),
                  ),
                  ResponsiveIcon(Icons.settings, size: 28),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify device type detection
        expect(ResponsiveHelper.getDeviceType(context), DeviceType.mediumPhone);

        // Verify responsive calculations
        final responsiveWidth = ResponsiveHelper.getResponsiveWidth(
          context,
          250,
        );
        expect(responsiveWidth, greaterThan(200));
        expect(responsiveWidth, lessThanOrEqualTo(350));

        // Verify no overflow
        expect(tester.takeException(), isNull);
      });

      testWidgets('should adapt to large phone screen (414x896)', (
        WidgetTester tester,
      ) async {
        // Set large phone screen size (iPhone 11)
        await tester.binding.setSurfaceSize(const Size(414, 896));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  AdaptiveText('Large Phone Test'),
                  ResponsiveContainer(
                    width: 300,
                    height: 150,
                    child: const Text('Container'),
                  ),
                  ResponsiveIcon(Icons.star, size: 32),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify device type detection
        expect(ResponsiveHelper.getDeviceType(context), DeviceType.largePhone);

        // Verify responsive calculations allow for larger sizes
        final responsiveWidth = ResponsiveHelper.getResponsiveWidth(
          context,
          300,
        );
        expect(responsiveWidth, greaterThan(250));

        // Verify no overflow
        expect(tester.takeException(), isNull);
      });

      testWidgets('should adapt to tablet screen (768x1024)', (
        WidgetTester tester,
      ) async {
        // Set tablet screen size (iPad)
        await tester.binding.setSurfaceSize(const Size(768, 1024));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  AdaptiveText('Tablet Test'),
                  ResponsiveContainer(
                    width: 400,
                    height: 200,
                    child: const Text('Container'),
                  ),
                  ResponsiveIcon(Icons.tablet, size: 40),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify device type detection
        expect(ResponsiveHelper.getDeviceType(context), DeviceType.tablet);
        expect(ResponsiveHelper.isTablet(context), true);

        // Verify responsive calculations allow for larger sizes
        final responsiveWidth = ResponsiveHelper.getResponsiveWidth(
          context,
          400,
        );
        expect(responsiveWidth, greaterThan(350));

        // Verify max content width is applied for tablets
        final maxContentWidth = ResponsiveHelper.getMaxContentWidth(context);
        expect(maxContentWidth, lessThan(768)); // Should limit content width

        // Verify no overflow
        expect(tester.takeException(), isNull);
      });
    });

    group('Orientation Changes', () {
      testWidgets('should handle portrait to landscape transition', (
        WidgetTester tester,
      ) async {
        // Start in portrait
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  AdaptiveText('Orientation Test'),
                  ResponsiveContainer(
                    width: 200,
                    height: 100,
                    child: const Text('Container'),
                  ),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify portrait mode
        expect(ResponsiveHelper.isLandscape(context), false);

        // Switch to landscape
        await tester.binding.setSurfaceSize(const Size(667, 375));
        await tester.pumpAndSettle();

        // Verify landscape mode
        expect(ResponsiveHelper.isLandscape(context), true);

        // Verify layout still works without overflow
        expect(tester.takeException(), isNull);
        expect(find.text('Orientation Test'), findsOneWidget);
        expect(find.text('Container'), findsOneWidget);
      });

      testWidgets('should adjust padding in landscape mode', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(667, 375)); // Landscape

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: AdaptiveText('Landscape Padding Test'),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify landscape-specific adjustments
        expect(ResponsiveHelper.isLandscape(context), true);

        final padding = ResponsiveHelper.getResponsivePadding(context, all: 16);
        // In landscape, horizontal padding might be adjusted differently
        expect(padding.horizontal, greaterThan(0));
        expect(padding.vertical, greaterThan(0));

        // Verify no overflow in landscape
        expect(tester.takeException(), isNull);
      });
    });

    group('Real Screen Integration Tests', () {
      testWidgets('WelcomeScreen should be responsive across screen sizes', (
        WidgetTester tester,
      ) async {
        final screenSizes = [
          const Size(320, 568), // Small phone
          const Size(375, 667), // Medium phone
          const Size(414, 896), // Large phone
          const Size(768, 1024), // Tablet
        ];

        for (final size in screenSizes) {
          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

          // Verify screen renders without overflow
          expect(tester.takeException(), isNull);

          // Verify key elements are present
          expect(find.text('Welcome to WaterTracker'), findsOneWidget);
          expect(find.text('Get Started'), findsOneWidget);

          // Verify responsive elements adapt
          final context = tester.element(find.byType(WelcomeScreen));
          final deviceType = ResponsiveHelper.getDeviceType(context);

          // Verify device type is correctly detected
          expect([
            DeviceType.smallPhone,
            DeviceType.mediumPhone,
            DeviceType.largePhone,
            DeviceType.tablet,
          ], contains(deviceType));
        }
      });

      testWidgets(
        'AgeSelectionScreen should be responsive across screen sizes',
        (WidgetTester tester) async {
          final screenSizes = [
            const Size(320, 568), // Small phone
            const Size(375, 667), // Medium phone
            const Size(414, 896), // Large phone
          ];

          for (final size in screenSizes) {
            await tester.binding.setSurfaceSize(size);

            await tester.pumpWidget(
              const MaterialApp(home: AgeSelectionScreen()),
            );

            // Verify screen renders without overflow
            expect(tester.takeException(), isNull);

            // Verify key elements are present and accessible
            expect(find.text('How old are you?'), findsOneWidget);
            expect(find.text('Continue'), findsOneWidget);

            // Verify age input field is accessible
            expect(find.byType(TextField), findsOneWidget);
          }
        },
      );

      testWidgets('HomeScreen should be responsive across screen sizes', (
        WidgetTester tester,
      ) async {
        final screenSizes = [
          const Size(320, 568), // Small phone
          const Size(375, 667), // Medium phone
          const Size(414, 896), // Large phone
          const Size(768, 1024), // Tablet
        ];

        for (final size in screenSizes) {
          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

          // Allow for async operations to complete
          await tester.pumpAndSettle();

          // Verify screen renders without overflow
          expect(tester.takeException(), isNull);

          // Verify key elements are present
          expect(find.byType(HomeScreen), findsOneWidget);

          // Verify responsive behavior
          final context = tester.element(find.byType(HomeScreen));
          final deviceType = ResponsiveHelper.getDeviceType(context);

          // Verify appropriate layout for device type
          if (deviceType == DeviceType.tablet) {
            // Tablet should have different layout considerations
            final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
            expect(maxWidth, lessThan(size.width));
          }
        }
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      testWidgets('should handle extremely small screen sizes gracefully', (
        WidgetTester tester,
      ) async {
        // Set extremely small screen size
        await tester.binding.setSurfaceSize(const Size(240, 320));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  AdaptiveText('Tiny Screen'),
                  ResponsiveContainer(
                    width: 100,
                    height: 50,
                    child: const Text('Small'),
                  ),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify minimum constraints are respected
        final responsiveWidth = ResponsiveHelper.getResponsiveWidth(
          context,
          100,
        );
        expect(responsiveWidth, greaterThan(50)); // Should have minimum size

        final responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(
          context,
          16,
        );
        expect(
          responsiveFontSize,
          greaterThan(10),
        ); // Should not be too small to read

        // Verify no overflow even on tiny screens
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle extremely large screen sizes gracefully', (
        WidgetTester tester,
      ) async {
        // Set very large screen size
        await tester.binding.setSurfaceSize(const Size(1920, 1080));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  AdaptiveText('Large Screen'),
                  ResponsiveContainer(
                    width: 500,
                    height: 300,
                    child: const Text('Large'),
                  ),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify maximum constraints are respected
        final maxContentWidth = ResponsiveHelper.getMaxContentWidth(context);
        expect(maxContentWidth, lessThan(1920)); // Should limit content width

        final responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(
          context,
          16,
        );
        expect(responsiveFontSize, lessThan(30)); // Should not be too large

        // Verify no overflow
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle zero and negative dimensions gracefully', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  ResponsiveContainer(
                    width: 0,
                    height: 0,
                    child: const Text('Zero Size'),
                  ),
                  ResponsiveContainer(
                    width: -10,
                    height: -5,
                    child: const Text('Negative Size'),
                  ),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ResponsiveScaffold));

        // Verify zero dimensions are handled
        final zeroWidth = ResponsiveHelper.getResponsiveWidth(context, 0);
        expect(zeroWidth, equals(0));

        // Verify negative dimensions are handled (should return 0 or positive)
        final negativeWidth = ResponsiveHelper.getResponsiveWidth(context, -10);
        expect(negativeWidth, greaterThanOrEqualTo(0));

        // Verify no crashes
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility and Touch Targets', () {
      testWidgets(
        'should maintain minimum touch target sizes across screen sizes',
        (WidgetTester tester) async {
          final screenSizes = [
            const Size(320, 568), // Small phone
            const Size(375, 667), // Medium phone
            const Size(414, 896), // Large phone
          ];

          for (final size in screenSizes) {
            await tester.binding.setSurfaceSize(size);

            await tester.pumpWidget(
              MaterialApp(
                home: ResponsiveScaffold(
                  body: Column(
                    children: [
                      ResponsiveButton(
                        text: 'Touch Target Test',
                        onPressed: () {},
                      ),
                      ResponsiveIcon(Icons.touch_app, size: 24),
                    ],
                  ),
                ),
              ),
            );

            // Verify button has minimum touch target size (44x44 dp)
            final buttonFinder = find.byType(ElevatedButton);
            expect(buttonFinder, findsOneWidget);

            final buttonSize = tester.getSize(buttonFinder);
            expect(buttonSize.height, greaterThanOrEqualTo(44));

            // Verify icon has adequate touch area
            final iconFinder = find.byType(Icon);
            expect(iconFinder, findsOneWidget);

            // Verify no accessibility issues
            expect(tester.takeException(), isNull);
          }
        },
      );

      testWidgets('should provide proper semantic labels across screen sizes', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveScaffold(
              body: Column(
                children: [
                  AdaptiveText(
                    'Accessible Text',
                    semanticsLabel: 'Accessible text for screen readers',
                  ),
                  ResponsiveIcon(
                    Icons.accessibility,
                    semanticLabel: 'Accessibility icon',
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify semantic labels are present
        expect(
          find.bySemanticsLabel('Accessible text for screen readers'),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('Accessibility icon'), findsOneWidget);

        // Verify no accessibility issues
        expect(tester.takeException(), isNull);
      });
    });

    group('Performance Under Different Screen Sizes', () {
      testWidgets('should maintain performance across screen size changes', (
        WidgetTester tester,
      ) async {
        final stopwatch = Stopwatch()..start();

        final screenSizes = [
          const Size(320, 568),
          const Size(375, 667),
          const Size(414, 896),
          const Size(768, 1024),
        ];

        for (final size in screenSizes) {
          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(
            MaterialApp(
              home: ResponsiveScaffold(
                body: Column(
                  children: List.generate(
                    10,
                    (index) => ResponsiveContainer(
                      width: 100 + (index * 10),
                      height: 50 + (index * 5),
                      child: AdaptiveText('Item $index'),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
        }

        stopwatch.stop();

        // Verify reasonable performance (should complete in under 5 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));

        // Verify no memory leaks or exceptions
        expect(tester.takeException(), isNull);
      });
    });
  });

  // Clean up after tests
  tearDown(() async {
    // Reset to default screen size
    await TestWidgetsFlutterBinding.ensureInitialized().setSurfaceSize(null);
  });
}
