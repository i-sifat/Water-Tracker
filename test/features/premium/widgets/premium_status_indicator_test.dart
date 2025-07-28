import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';
import 'package:watertracker/features/premium/widgets/premium_status_indicator.dart';

// Mock PremiumProvider for testing
class MockPremiumProvider extends ChangeNotifier implements PremiumProvider {
  bool _isPremium = false;
  bool _isInitialized = true;
  final String _deviceCode = 'test-device-code';
  DateTime? _unlockedAt;
  DateTime? _expiresAt;

  @override
  bool get isPremium => _isPremium;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get deviceCode => _deviceCode;

  @override
  DateTime? get unlockedAt => _unlockedAt;

  @override
  DateTime? get expiresAt => _expiresAt;

  @override
  int? get daysRemaining {
    if (_expiresAt == null) return null;
    final now = DateTime.now();
    final difference = _expiresAt!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  @override
  String get statusSummary => _isPremium ? 'Premium Active' : 'Free Version';

  void setPremium(bool premium) {
    _isPremium = premium;
    if (premium) {
      _unlockedAt = DateTime.now();
      _expiresAt = DateTime.now().add(const Duration(days: 365));
    } else {
      _unlockedAt = null;
      _expiresAt = null;
    }
    notifyListeners();
  }

  void setInitialized(bool initialized) {
    _isInitialized = initialized;
    notifyListeners();
  }

  // Implement other required methods with minimal functionality
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

  @override
  bool isFeatureUnlocked(dynamic feature) => _isPremium;

  @override
  String getFeatureName(dynamic feature) => 'Test Feature';

  @override
  String getFeatureDescription(dynamic feature) => 'Test Description';

}

void main() {
  group('PremiumStatusIndicator Tests', () {
    late MockPremiumProvider mockPremiumProvider;

    setUp(() {
      mockPremiumProvider = MockPremiumProvider();
    });

    Widget createTestWidget({
      bool showLabel = true,
      PremiumIndicatorSize size = PremiumIndicatorSize.normal,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<PremiumProvider>.value(
          value: mockPremiumProvider,
          child: Scaffold(
            body: PremiumStatusIndicator(
              showLabel: showLabel,
              size: size,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    testWidgets('shows nothing when not initialized', (WidgetTester tester) async {
      mockPremiumProvider.setInitialized(false);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Premium'), findsNothing);
      expect(find.text('Free'), findsNothing);
    });

    testWidgets('shows Free status when not premium', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(false);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Free'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows Premium status when premium', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(true);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Premium'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });

    testWidgets('hides label when showLabel is false', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(false);

      await tester.pumpWidget(createTestWidget(showLabel: false));

      expect(find.text('Free'), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows only icon when showLabel is false', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(true);

      await tester.pumpWidget(createTestWidget(showLabel: false));

      expect(find.text('Premium'), findsNothing);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });

    testWidgets('calls custom onTap when provided', (WidgetTester tester) async {
      var wasTapped = false;
      mockPremiumProvider.setPremium(false);

      await tester.pumpWidget(createTestWidget(
        onTap: () => wasTapped = true,
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('responds to tap when not premium', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(false);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(GestureDetector), findsOneWidget);
      
      // Tap should be handled (would navigate to donation screen in real app)
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      
      // No exception should be thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows dialog when premium and tapped', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(true);

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Premium Status'), findsOneWidget);
    });

    testWidgets('updates when premium status changes', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(false);

      await tester.pumpWidget(createTestWidget());

      // Initially shows Free
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Premium'), findsNothing);

      // Change to premium
      mockPremiumProvider.setPremium(true);
      await tester.pump();

      // Now shows Premium
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Free'), findsNothing);
    });

    testWidgets('applies different sizes correctly', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(true);

      // Test small size
      await tester.pumpWidget(createTestWidget(size: PremiumIndicatorSize.small));
      expect(find.byType(PremiumStatusIndicator), findsOneWidget);

      // Test large size
      await tester.pumpWidget(createTestWidget(size: PremiumIndicatorSize.large));
      expect(find.byType(PremiumStatusIndicator), findsOneWidget);
    });
  });

  group('PremiumBadge Tests', () {
    late MockPremiumProvider mockPremiumProvider;

    setUp(() {
      mockPremiumProvider = MockPremiumProvider();
    });

    Widget createTestWidget({VoidCallback? onTap}) {
      return MaterialApp(
        home: ChangeNotifierProvider<PremiumProvider>.value(
          value: mockPremiumProvider,
          child: Scaffold(
            body: PremiumBadge(onTap: onTap),
          ),
        ),
      );
    }

    testWidgets('shows nothing when not initialized', (WidgetTester tester) async {
      mockPremiumProvider.setInitialized(false);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('shows nothing when not premium', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(false);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('shows PRO badge when premium', (WidgetTester tester) async {
      mockPremiumProvider.setPremium(true);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('PRO'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var wasTapped = false;
      mockPremiumProvider.setPremium(true);

      await tester.pumpWidget(createTestWidget(
        onTap: () => wasTapped = true,
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(wasTapped, isTrue);
    });
  });

  group('PremiumLockedIndicator Tests', () {
    Widget createTestWidget({
      String message = 'Premium Feature',
      VoidCallback? onUnlockTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PremiumLockedIndicator(
            message: message,
            onUnlockTap: onUnlockTap,
          ),
        ),
      );
    }

    testWidgets('renders with default message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Premium Feature'), findsOneWidget);
      expect(find.text('Unlock premium features to access this content'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Unlock Premium'), findsOneWidget);
    });

    testWidgets('renders with custom message', (WidgetTester tester) async {
      const customMessage = 'Custom Premium Message';

      await tester.pumpWidget(createTestWidget(message: customMessage));

      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('calls custom onUnlockTap when provided', (WidgetTester tester) async {
      var wasTapped = false;

      await tester.pumpWidget(createTestWidget(
        onUnlockTap: () => wasTapped = true,
      ));

      await tester.tap(find.text('Unlock Premium'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('has correct spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for SizedBox widgets with specific heights for spacing
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      
      // Should have spacing boxes with heights 8, 4, and 12
      expect(sizedBoxes.any((box) => box.height == 8), isTrue);
      expect(sizedBoxes.any((box) => box.height == 4), isTrue);
      expect(sizedBoxes.any((box) => box.height == 12), isTrue);
    });

    testWidgets('button has correct icon and text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
      expect(find.text('Unlock Premium'), findsOneWidget);
    });
  });
}
