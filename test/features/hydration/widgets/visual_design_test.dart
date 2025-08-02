import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';

void main() {
  group('Visual Design Tests', () {
    testWidgets('AppColors contains design mockup colors', (
      WidgetTester tester,
    ) async {
      // Test that the new gradient colors are defined
      expect(AppColors.gradientTop, equals(const Color(0xFF6B73FF)));
      expect(AppColors.gradientBottom, equals(const Color(0xFF9546C4)));

      // Test that button colors match design mockup
      expect(AppColors.box1, equals(const Color(0xFFB39DDB))); // Purple
      expect(AppColors.box2, equals(const Color(0xFF81D4FA))); // Light Blue
      expect(AppColors.box3, equals(const Color(0xFFA5D6A7))); // Light Green
      expect(AppColors.box4, equals(const Color(0xFFFFF59D))); // Light Yellow

      // Test page indicator colors
      expect(AppColors.pageIndicatorActive, equals(const Color(0xFFFFFFFF)));
      expect(AppColors.pageIndicatorInactive, equals(const Color(0x4DFFFFFF)));
    });

    testWidgets('AppTypography contains hydration interface styles', (
      WidgetTester tester,
    ) async {
      // Test hydration title style
      expect(AppTypography.hydrationTitle.fontSize, equals(24));
      expect(AppTypography.hydrationTitle.fontWeight, equals(FontWeight.w700));
      expect(AppTypography.hydrationTitle.color, equals(Colors.white));
      expect(AppTypography.hydrationTitle.fontFamily, equals('Nunito'));

      // Test progress text styles
      expect(AppTypography.progressMainText.fontSize, equals(18));
      expect(
        AppTypography.progressMainText.fontWeight,
        equals(FontWeight.w600),
      );
      expect(
        AppTypography.progressMainText.color,
        equals(AppColors.textHeadline),
      );

      expect(AppTypography.progressSubText.fontSize, equals(14));
      expect(AppTypography.progressSubText.fontWeight, equals(FontWeight.w400));
      expect(
        AppTypography.progressSubText.color,
        equals(AppColors.textSubtitle),
      );

      // Test button text styles
      expect(AppTypography.buttonLargeText.fontSize, equals(18));
      expect(AppTypography.buttonLargeText.fontWeight, equals(FontWeight.w600));
      expect(AppTypography.buttonLargeText.color, equals(Colors.white));

      expect(AppTypography.buttonSmallText.fontSize, equals(12));
      expect(AppTypography.buttonSmallText.fontWeight, equals(FontWeight.w400));
      expect(AppTypography.buttonSmallText.color, equals(Colors.white70));
    });

    testWidgets(
      'AppCard has improved design with rounded corners and shadows',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: AppCard(child: Text('Test Card'))),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration! as BoxDecoration;

        // Test improved border radius
        expect(decoration.borderRadius, equals(BorderRadius.circular(20)));

        // Test improved shadows
        expect(decoration.boxShadow, isNotNull);
        expect(
          decoration.boxShadow!.length,
          equals(2),
        ); // Two shadows for depth

        // Test shadow properties
        final firstShadow = decoration.boxShadow!.first;
        expect(firstShadow.color, equals(Colors.black.withValues(alpha: 0.08)));
        expect(firstShadow.blurRadius, equals(4.0)); // elevation * 2
        expect(firstShadow.offset, equals(const Offset(0, 2))); // elevation

        final secondShadow = decoration.boxShadow![1];
        expect(
          secondShadow.color,
          equals(Colors.black.withValues(alpha: 0.04)),
        );
        expect(secondShadow.blurRadius, equals(2.0)); // elevation
        expect(
          secondShadow.offset,
          equals(const Offset(0, 1)),
        ); // elevation / 2
      },
    );

    testWidgets('Gradient background uses correct colors', (
      WidgetTester tester,
    ) async {
      const gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.gradientTop, AppColors.gradientBottom],
        stops: [0.0, 1.0],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(gradient: gradient),
              child: const Text('Gradient Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      final testGradient = decoration.gradient! as LinearGradient;

      expect(testGradient.colors.first, equals(AppColors.gradientTop));
      expect(testGradient.colors.last, equals(AppColors.gradientBottom));
      expect(testGradient.begin, equals(Alignment.topCenter));
      expect(testGradient.end, equals(Alignment.bottomCenter));
    });

    testWidgets('Typography uses consistent Nunito font family', (
      WidgetTester tester,
    ) async {
      const styles = [
        AppTypography.hydrationTitle,
        AppTypography.progressMainText,
        AppTypography.progressSubText,
        AppTypography.progressSmallText,
        AppTypography.buttonLargeText,
        AppTypography.buttonSmallText,
        AppTypography.timeIndicatorText,
      ];

      for (final style in styles) {
        expect(
          style.fontFamily,
          equals('Nunito'),
          reason: 'All typography styles should use Nunito font family',
        );
      }
    });

    testWidgets('Color consistency across components', (
      WidgetTester tester,
    ) async {
      // Test that waterFull color is updated to match gradient
      expect(AppColors.waterFull, equals(const Color(0xFF6B73FF)));

      // Test that progress colors are defined
      expect(AppColors.progressBackground, equals(const Color(0xFFE5E5E5)));
      expect(AppColors.progressGradientStart, equals(const Color(0xFF2196F3)));
      expect(AppColors.progressGradientEnd, equals(const Color(0xFF1976D2)));
      expect(AppColors.progressInnerRing, equals(const Color(0xFF4CAF50)));
    });
  });
}
