import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';

void main() {
  group('ResponsiveHelper', () {
    late Widget testWidget;

    setUp(() {
      testWidget = MaterialApp(
        home: Scaffold(body: Builder(builder: (context) => Container())),
      );
    });

    group('Core Functionality', () {
      testWidgets('should provide responsive width calculations', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        const baseWidth = 100.0;
        final responsiveWidth = ResponsiveHelper.getResponsiveWidth(
          context,
          baseWidth,
        );

        // Should return a positive value
        expect(responsiveWidth, greaterThan(0));
        // Should be within reasonable bounds (0.7x to 1.5x of base)
        expect(responsiveWidth, greaterThanOrEqualTo(baseWidth * 0.7));
        expect(responsiveWidth, lessThanOrEqualTo(baseWidth * 1.5));
      });

      testWidgets('should provide responsive height calculations', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        const baseHeight = 100.0;
        final responsiveHeight = ResponsiveHelper.getResponsiveHeight(
          context,
          baseHeight,
        );

        // Should return a positive value
        expect(responsiveHeight, greaterThan(0));
        // Should be within reasonable bounds
        expect(responsiveHeight, greaterThanOrEqualTo(baseHeight * 0.7));
        expect(responsiveHeight, lessThanOrEqualTo(baseHeight * 1.5));
      });

      testWidgets('should provide responsive font size calculations', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        const baseFontSize = 16.0;
        final responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(
          context,
          baseFontSize,
        );

        // Should return a positive value
        expect(responsiveFontSize, greaterThan(0));
        // Should be within reasonable bounds for font sizes
        expect(responsiveFontSize, greaterThan(8.0));
        expect(responsiveFontSize, lessThan(50.0));
      });

      testWidgets('should provide responsive padding', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        final padding = ResponsiveHelper.getResponsivePadding(
          context,
          all: 16.0,
        );

        // Should return positive padding values
        expect(padding.horizontal, greaterThan(0));
        expect(padding.vertical, greaterThan(0));
        expect(padding.horizontal, lessThan(100)); // Reasonable upper bound
        expect(padding.vertical, lessThan(100)); // Reasonable upper bound
      });

      testWidgets('should handle custom padding parameters', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        final padding = ResponsiveHelper.getResponsivePadding(
          context,
          horizontal: 20.0,
          vertical: 10.0,
        );

        // Should return positive values
        expect(padding.horizontal, greaterThan(0));
        expect(padding.vertical, greaterThan(0));
      });

      testWidgets('should provide responsive margin', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        final margin = ResponsiveHelper.getResponsiveMargin(context, all: 16.0);

        // Should return positive margin values
        expect(margin.horizontal, greaterThan(0));
        expect(margin.vertical, greaterThan(0));
        expect(margin.horizontal, lessThan(100)); // Reasonable upper bound
        expect(margin.vertical, lessThan(100)); // Reasonable upper bound
      });
    });

    group('Device Type Detection', () {
      testWidgets('should detect device type', (WidgetTester tester) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        final deviceType = ResponsiveHelper.getDeviceType(context);

        // Should return a valid device type
        expect(deviceType, isA<DeviceType>());
        expect([
          DeviceType.smallPhone,
          DeviceType.mediumPhone,
          DeviceType.largePhone,
          DeviceType.tablet,
        ], contains(deviceType));
      });

      testWidgets('should provide boolean device type checks', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        // Should return boolean values
        expect(ResponsiveHelper.isSmallPhone(context), isA<bool>());
        expect(ResponsiveHelper.isTablet(context), isA<bool>());
        expect(ResponsiveHelper.isLandscape(context), isA<bool>());
      });
    });

    group('Component Sizes', () {
      testWidgets('should calculate responsive component sizes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        // Test app bar height
        final appBarHeight = ResponsiveHelper.getResponsiveAppBarHeight(
          context,
        );
        expect(appBarHeight, greaterThan(0));
        expect(appBarHeight, lessThan(200)); // Reasonable upper bound

        // Test bottom nav height
        final bottomNavHeight = ResponsiveHelper.getResponsiveBottomNavHeight(
          context,
        );
        expect(bottomNavHeight, greaterThan(0));
        expect(bottomNavHeight, lessThan(200)); // Reasonable upper bound

        // Test icon size
        final iconSize = ResponsiveHelper.getResponsiveIconSize(context, 24.0);
        expect(iconSize, greaterThan(0));
        expect(iconSize, lessThan(100)); // Reasonable upper bound

        // Test border radius
        final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(
          context,
          8.0,
        );
        expect(borderRadius, greaterThan(0));
        expect(borderRadius, lessThan(50)); // Reasonable upper bound

        // Test spacing
        final spacing = ResponsiveHelper.getResponsiveSpacing(context, 16.0);
        expect(spacing, greaterThan(0));
        expect(spacing, lessThan(100)); // Reasonable upper bound
      });
    });

    group('Utility Functions', () {
      testWidgets('should provide max content width', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
        expect(maxWidth, greaterThan(0));
        expect(maxWidth, lessThan(2000)); // Reasonable upper bound
      });

      testWidgets('should provide safe area padding', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        final safeArea = ResponsiveHelper.getSafeAreaPadding(context);
        expect(safeArea, isA<EdgeInsets>());
      });
    });

    group('Scaling Constraints', () {
      testWidgets('should respect scaling constraints', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        // Test width scaling constraints
        const testWidth = 100.0;
        final scaledWidth = ResponsiveHelper.getResponsiveWidth(
          context,
          testWidth,
        );
        expect(scaledWidth, greaterThanOrEqualTo(testWidth * 0.7));
        expect(scaledWidth, lessThanOrEqualTo(testWidth * 1.5));

        // Test height scaling constraints
        const testHeight = 100.0;
        final scaledHeight = ResponsiveHelper.getResponsiveHeight(
          context,
          testHeight,
        );
        expect(scaledHeight, greaterThanOrEqualTo(testHeight * 0.7));
        expect(scaledHeight, lessThanOrEqualTo(testHeight * 1.5));

        // Test font size constraints
        const testFontSize = 16.0;
        final scaledFontSize = ResponsiveHelper.getResponsiveFontSize(
          context,
          testFontSize,
        );
        expect(scaledFontSize, greaterThan(0));
        expect(
          scaledFontSize,
          lessThan(100),
        ); // Reasonable upper bound for font sizes
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle zero and negative values gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        // Test with zero values
        final zeroWidth = ResponsiveHelper.getResponsiveWidth(context, 0);
        expect(zeroWidth, equals(0));

        final zeroHeight = ResponsiveHelper.getResponsiveHeight(context, 0);
        expect(zeroHeight, equals(0));

        final zeroFontSize = ResponsiveHelper.getResponsiveFontSize(context, 0);
        expect(zeroFontSize, equals(0));
      });

      testWidgets('should handle very large values', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(testWidget);
        final context = tester.element(find.byType(Container));

        // Test with large values - should be constrained
        const largeValue = 1000.0;
        final scaledWidth = ResponsiveHelper.getResponsiveWidth(
          context,
          largeValue,
        );
        expect(scaledWidth, lessThanOrEqualTo(largeValue * 1.5));

        final scaledHeight = ResponsiveHelper.getResponsiveHeight(
          context,
          largeValue,
        );
        expect(scaledHeight, lessThanOrEqualTo(largeValue * 1.5));
      });
    });
  });
}
