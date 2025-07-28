import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

// Mock PremiumProvider for testing
class MockPremiumProvider extends ChangeNotifier implements PremiumProvider {
  bool _isPremium = false;
  final Map<PremiumFeature, bool> _unlockedFeatures = {};

  @override
  bool get isPremium => _isPremium;

  @override
  bool isFeatureUnlocked(PremiumFeature feature) {
    return _isPremium || _unlockedFeatures[feature] == true;
  }

  @override
  String getFeatureName(PremiumFeature feature) {
    return PremiumFeatures.featureNames[feature] ?? 'Unknown Feature';
  }

  @override
  String getFeatureDescription(PremiumFeature feature) {
    return PremiumFeatures.featureDescriptions[feature] ?? 'Feature description';
  }

  void setFeatureUnlocked(PremiumFeature feature, bool unlocked) {
    _unlockedFeatures[feature] = unlocked;
    notifyListeners();
  }

  void setPremium(bool premium) {
    _isPremium = premium;
    notifyListeners();
  }

  // Implement other required methods with minimal functionality
  @override
  String? get deviceCode => 'test-device-code';

  @override
  bool get isGeneratingCode => false;

  @override
  bool get isSubmittingProof => false;

  @override
  bool get isValidatingCode => false;

  @override
  Future<void> generateDeviceCode() async {}

  @override
  Future<bool> submitDonationProof(dynamic screenshot) async => true;

  @override
  Future<bool> unlockWithCode(String code) async => true;

}

void main() {
  group('PremiumGate Widget Tests', () {
    late MockPremiumProvider mockPremiumProvider;

    setUp(() {
      mockPremiumProvider = MockPremiumProvider();
    });

    Widget createTestWidget({
      required PremiumFeature feature,
      required Widget child,
      Widget? lockedChild,
      VoidCallback? onUnlockPressed,
      String? title,
      String? description,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<PremiumProvider>.value(
          value: mockPremiumProvider,
          child: Scaffold(
            body: PremiumGate(
              feature: feature,
              lockedChild: lockedChild,
              onUnlockPressed: onUnlockPressed,
              title: title,
              description: description,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('shows child when feature is unlocked', (WidgetTester tester) async {
      const childText = 'Premium Content';
      mockPremiumProvider.setFeatureUnlocked(PremiumFeature.advancedAnalytics, true);

      await tester.pumpWidget(
        createTestWidget(
          feature: PremiumFeature.advancedAnalytics,
          child: const Text(childText),
        ),
      );

      expect(find.text(childText), findsOneWidget);
      expect(find.byType(PremiumLockedWidget), findsNothing);
    });

    testWidgets('shows locked widget when feature is locked', (WidgetTester tester) async {
      const childText = 'Premium Content';
      mockPremiumProvider.setFeatureUnlocked(PremiumFeature.advancedAnalytics, false);

      await tester.pumpWidget(
        createTestWidget(
          feature: PremiumFeature.advancedAnalytics,
          child: const Text(childText),
        ),
      );

      expect(find.text(childText), findsNothing);
      expect(find.byType(PremiumLockedWidget), findsOneWidget);
    });

    testWidgets('shows custom locked child when provided', (WidgetTester tester) async {
      const childText = 'Premium Content';
      const lockedText = 'Custom Locked Content';
      mockPremiumProvider.setFeatureUnlocked(PremiumFeature.advancedAnalytics, false);

      await tester.pumpWidget(
        createTestWidget(
          feature: PremiumFeature.advancedAnalytics,
          child: const Text(childText),
          lockedChild: const Text(lockedText),
        ),
      );

      expect(find.text(childText), findsNothing);
      expect(find.text(lockedText), findsOneWidget);
      expect(find.byType(PremiumLockedWidget), findsNothing);
    });

    testWidgets('updates when premium status changes', (WidgetTester tester) async {
      const childText = 'Premium Content';
      mockPremiumProvider.setFeatureUnlocked(PremiumFeature.advancedAnalytics, false);

      await tester.pumpWidget(
        createTestWidget(
          feature: PremiumFeature.advancedAnalytics,
          child: const Text(childText),
        ),
      );

      // Initially locked
      expect(find.text(childText), findsNothing);
      expect(find.byType(PremiumLockedWidget), findsOneWidget);

      // Unlock the feature
      mockPremiumProvider.setFeatureUnlocked(PremiumFeature.advancedAnalytics, true);
      await tester.pump();

      // Now unlocked
      expect(find.text(childText), findsOneWidget);
      expect(find.byType(PremiumLockedWidget), findsNothing);
    });
  });

  group('PremiumLockedWidget Tests', () {
    late MockPremiumProvider mockPremiumProvider;

    setUp(() {
      mockPremiumProvider = MockPremiumProvider();
    });

    Widget createTestWidget({
      required PremiumFeature feature,
      VoidCallback? onUnlockPressed,
      String? title,
      String? description,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<PremiumProvider>.value(
          value: mockPremiumProvider,
          child: Scaffold(
            body: PremiumLockedWidget(
              feature: feature,
              onUnlockPressed: onUnlockPressed,
              title: title,
              description: description,
            ),
          ),
        ),
      );
    }

    testWidgets('renders lock icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(feature: PremiumFeature.advancedAnalytics),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('renders unlock premium button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(feature: PremiumFeature.advancedAnalytics),
      );

      expect(find.text('Unlock Premium'), findsOneWidget);
    });

    testWidgets('uses custom title when provided', (WidgetTester tester) async {
      const customTitle = 'Custom Premium Title';

      await tester.pumpWidget(
        createTestWidget(
          feature: PremiumFeature.advancedAnalytics,
          title: customTitle,
        ),
      );

      expect(find.text(customTitle), findsOneWidget);
    });

    testWidgets('uses default title when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(feature: PremiumFeature.advancedAnalytics),
      );

      expect(find.text('Advanced Analytics'), findsOneWidget);
    });

    testWidgets('uses custom description when provided', (WidgetTester tester) async {
      const customDescription = 'Custom premium description';

      await tester.pumpWidget(
        createTestWidget(
          feature: PremiumFeature.advancedAnalytics,
          description: customDescription,
        ),
      );

      expect(find.text(customDescription), findsOneWidget);
    });

    testWidgets('uses default description when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(feature: PremiumFeature.advancedAnalytics),
      );

      expect(find.text('Detailed charts and progress tracking'), findsOneWidget);
    });

    testWidgets('calls custom onUnlockPressed when provided', (WidgetTester tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        createTestWidget(
          feature: PremiumFeature.advancedAnalytics,
          onUnlockPressed: () => wasPressed = true,
        ),
      );

      await tester.tap(find.text('Unlock Premium'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(feature: PremiumFeature.advancedAnalytics),
      );

      // Check that main elements are present
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget); // Icon container
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('centers content properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(feature: PremiumFeature.advancedAnalytics),
      );

      final center = tester.widget<Center>(find.byType(Center));
      expect(center, isNotNull);

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('has proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(feature: PremiumFeature.advancedAnalytics),
      );

      // Check for SizedBox widgets with specific heights for spacing
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      
      // Should have spacing boxes with heights 24, 12, and 32
      expect(sizedBoxes.any((box) => box.height == 24), isTrue);
      expect(sizedBoxes.any((box) => box.height == 12), isTrue);
      expect(sizedBoxes.any((box) => box.height == 32), isTrue);
    });

    testWidgets('icon container has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(feature: PremiumFeature.advancedAnalytics),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(80));
      expect(container.constraints?.maxHeight, equals(80));

      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
    });
  });
}
