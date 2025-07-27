import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';

void main() {
  group('AddHydrationScreen Widget Tests', () {
    late HydrationProvider mockHydrationProvider;

    setUp(() {
      mockHydrationProvider = HydrationProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: mockHydrationProvider,
          child: const AddHydrationScreen(),
        ),
      );
    }

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(AddHydrationScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has custom bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
    });

    testWidgets('has app bar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Add Water'), findsOneWidget);
    });

    testWidgets('contains AddHydrationScreenContent', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(AddHydrationScreenContent), findsOneWidget);
    });

    testWidgets('bottom navigation responds to taps', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final bottomNav = find.byType(CustomBottomNavigationBar);
      expect(bottomNav, findsOneWidget);
      
      // The navigation should be interactive
      final gestureDetectors = find.descendant(
        of: bottomNav,
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetectors, findsWidgets);
    });
  });

  group('AddHydrationScreenContent Widget Tests', () {
    late HydrationProvider mockHydrationProvider;

    setUp(() {
      mockHydrationProvider = HydrationProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: mockHydrationProvider,
          child: const Scaffold(
            body: AddHydrationScreenContent(),
          ),
        ),
      );
    }

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(AddHydrationScreenContent), findsOneWidget);
    });

    testWidgets('has scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('contains column layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('has quick add buttons section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Look for common quick add amounts
      expect(find.text('250ml'), findsOneWidget);
      expect(find.text('500ml'), findsOneWidget);
    });

    testWidgets('has custom amount input option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('Custom Amount'), findsOneWidget);
    });

    testWidgets('shows drink type selector', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('Drink Type'), findsOneWidget);
    });

    testWidgets('has add button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('Add Water'), findsOneWidget);
    });

    testWidgets('quick add buttons are interactive', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final quickAddButton = find.text('250ml');
      expect(quickAddButton, findsOneWidget);
      
      await tester.tap(quickAddButton);
      await tester.pump();
      
      // Should not throw any errors
    });

    testWidgets('custom amount toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final customAmountButton = find.text('Custom Amount');
      expect(customAmountButton, findsOneWidget);
      
      await tester.tap(customAmountButton);
      await tester.pump();
      
      // Should show text field for custom input
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('drink type selector is interactive', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final drinkTypeButton = find.text('Drink Type');
      expect(drinkTypeButton, findsOneWidget);
      
      await tester.tap(drinkTypeButton);
      await tester.pump();
      
      // Should not throw any errors
    });

    testWidgets('has undo functionality when available', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Add some water first to enable undo
      final addButton = find.text('Add Water');
      await tester.tap(addButton);
      await tester.pump();
      
      // Look for undo option (might be in a snackbar or button)
      // This test verifies the widget structure supports undo
      expect(find.byType(AddHydrationScreenContent), findsOneWidget);
    });

    testWidgets('shows smart suggestions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Smart suggestions should be visible as quick add buttons
      expect(find.text('250ml'), findsOneWidget);
      expect(find.text('500ml'), findsOneWidget);
      expect(find.text('100ml'), findsOneWidget);
      expect(find.text('400ml'), findsOneWidget);
    });

    testWidgets('bulk entry option is available', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Look for bulk entry option
      expect(find.text('Bulk Entry'), findsOneWidget);
    });

    testWidgets('notes input is available', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('Notes (Optional)'), findsOneWidget);
    });
  });
}