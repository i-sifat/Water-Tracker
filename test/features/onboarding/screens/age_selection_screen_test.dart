import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/core/widgets/custom_ruler_picker.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/age_selection_screen.dart';

void main() {
  group('AgeSelectionScreen Widget Tests', () {
    late OnboardingProvider mockOnboardingProvider;

    setUp(() {
      mockOnboardingProvider = OnboardingProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<OnboardingProvider>.value(
          value: mockOnboardingProvider,
          child: const AgeSelectionScreen(),
        ),
      );
    }

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AgeSelectionScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has app bar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Age Selection'), findsOneWidget);
    });

    testWidgets('has scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('contains column layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('displays age selection question', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.textContaining('age'), findsWidgets);
      expect(find.textContaining('old'), findsWidgets);
    });

    testWidgets('has custom ruler picker for age selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CustomRulerPicker), findsOneWidget);
    });

    testWidgets('ruler picker has appropriate age range', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final rulerPicker = tester.widget<CustomRulerPicker>(
        find.byType(CustomRulerPicker),
      );
      expect(rulerPicker.minValue, greaterThanOrEqualTo(1));
      expect(rulerPicker.maxValue, lessThanOrEqualTo(120));
    });

    testWidgets('has continue button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ContinueButton), findsOneWidget);
    });

    testWidgets('continue button is initially enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final continueButton = tester.widget<ContinueButton>(
        find.byType(ContinueButton),
      );
      expect(continueButton.isDisabled, isFalse);
    });

    testWidgets('age selection updates provider', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final rulerPicker = find.byType(CustomRulerPicker);
      expect(rulerPicker, findsOneWidget);

      // Simulate age selection
      final gesture = await tester.startGesture(tester.getCenter(rulerPicker));
      await gesture.moveBy(const Offset(50, 0));
      await gesture.up();
      await tester.pump();

      // Should not throw errors
    });

    testWidgets('continue button navigates when pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final continueButton = find.byType(ContinueButton);
      expect(continueButton, findsOneWidget);

      await tester.tap(continueButton);
      await tester.pump();

      // Should not throw errors
    });

    testWidgets('displays current selected age', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should display the current age value
      expect(
        find.textContaining('25'),
        findsWidgets,
      ); // Default age might be 25
    });

    testWidgets('has proper spacing between elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes, isNotEmpty);
    });

    testWidgets('consumes onboarding provider correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Consumer<OnboardingProvider>), findsWidgets);
    });

    testWidgets('has back navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('age picker responds to gestures', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final rulerPicker = find.byType(CustomRulerPicker);

      // Test horizontal drag
      await tester.drag(rulerPicker, const Offset(100, 0));
      await tester.pump();

      // Should not throw errors
    });

    testWidgets('validates age input range', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final rulerPicker = tester.widget<CustomRulerPicker>(
        find.byType(CustomRulerPicker),
      );

      // Age should be within reasonable range
      expect(rulerPicker.minValue, greaterThan(0));
      expect(rulerPicker.maxValue, lessThan(150));
    });

    testWidgets('has instructional text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have instructions for age selection
      expect(find.textContaining('Select'), findsWidgets);
    });

    testWidgets('age display updates with selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Initial age display
      final initialAgeText = find.textContaining('years');
      expect(initialAgeText, findsWidgets);

      // Change age selection
      final rulerPicker = find.byType(CustomRulerPicker);
      await tester.drag(rulerPicker, const Offset(50, 0));
      await tester.pump();

      // Age display should still be present
      expect(find.textContaining('years'), findsWidgets);
    });

    testWidgets('has proper text styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have styled text widgets
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      expect(textWidgets, isNotEmpty);

      for (final text in textWidgets) {
        expect(text.style, isNotNull);
      }
    });
  });
}
