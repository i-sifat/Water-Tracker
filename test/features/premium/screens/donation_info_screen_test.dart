import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/buttons/secondary_button.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';
import 'package:watertracker/features/premium/screens/donation_info_screen.dart';

void main() {
  group('DonationInfoScreen Widget Tests', () {
    late PremiumProvider mockPremiumProvider;

    setUp(() {
      mockPremiumProvider = PremiumProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<PremiumProvider>.value(
          value: mockPremiumProvider,
          child: const DonationInfoScreen(),
        ),
      );
    }

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(DonationInfoScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has app bar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Unlock Premium'), findsOneWidget);
    });

    testWidgets('app bar is centered', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('has scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Padding),
        ).first,
      );
      expect(padding.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('contains column layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(Column), findsOneWidget);
      
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.stretch));
    });

    testWidgets('shows header section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Look for premium unlock related text
      expect(find.textContaining('Premium'), findsWidgets);
    });

    testWidgets('displays device code', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should show device code section
      expect(find.textContaining('Device Code'), findsOneWidget);
    });

    testWidgets('shows bKash payment information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should show bKash related information
      expect(find.textContaining('bKash'), findsWidgets);
    });

    testWidgets('has instructions section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should show instructions
      expect(find.textContaining('Instructions'), findsOneWidget);
    });

    testWidgets('has action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(PrimaryButton), findsWidgets);
      expect(find.byType(SecondaryButton), findsWidgets);
    });

    testWidgets('has submit donation proof button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Submit'), findsWidgets);
      expect(find.textContaining('Proof'), findsWidgets);
    });

    testWidgets('has already have code option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Already'), findsWidgets);
      expect(find.textContaining('Code'), findsWidgets);
    });

    testWidgets('buttons are interactive', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final primaryButtons = find.byType(PrimaryButton);
      final secondaryButtons = find.byType(SecondaryButton);
      
      expect(primaryButtons, findsWidgets);
      expect(secondaryButtons, findsWidgets);
      
      // Tap first primary button
      if (primaryButtons.evaluate().isNotEmpty) {
        await tester.tap(primaryButtons.first);
        await tester.pump();
      }
      
      // Should not throw errors
    });

    testWidgets('has proper spacing between sections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      
      // Should have spacing of 24 between sections
      final spacing24 = sizedBoxes.where((box) => box.height == 24);
      expect(spacing24, isNotEmpty);
      
      // Should have spacing of 32 before action buttons
      final spacing32 = sizedBoxes.where((box) => box.height == 32);
      expect(spacing32, isNotEmpty);
      
      // Should have spacing of 16 between buttons
      final spacing16 = sizedBoxes.where((box) => box.height == 16);
      expect(spacing16, isNotEmpty);
    });

    testWidgets('consumes premium provider correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(Consumer<PremiumProvider>), findsOneWidget);
    });

    testWidgets('shows QR code section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should show QR code related content
      expect(find.textContaining('QR'), findsWidgets);
    });

    testWidgets('displays donation amount information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should show donation amount
      expect(find.textContaining('৳'), findsWidgets); // Taka symbol
    });

    testWidgets('has copy device code functionality', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should have copy functionality for device code
      expect(find.byIcon(Icons.copy), findsWidgets);
    });

    testWidgets('navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Should have back button in app bar
      expect(find.byType(BackButton), findsOneWidget);
    });
  });
}
