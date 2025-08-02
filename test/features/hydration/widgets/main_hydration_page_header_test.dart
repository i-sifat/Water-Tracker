import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';

void main() {
  group('MainHydrationPage Header Navigation Tests', () {
    late HydrationProvider mockProvider;

    setUp(() {
      mockProvider = HydrationProvider();
    });

    Widget createTestWidget({Widget? child}) {
      return MaterialApp(
        home: ChangeNotifierProvider<HydrationProvider>.value(
          value: mockProvider,
          child: Scaffold(
            body: child ?? const MainHydrationPage(),
          ),
        ),
        routes: {
          SettingsScreen.routeName: (context) => const SettingsScreen(),
        },
      );
    }

    testWidgets('should display header with Today title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('should display hamburger menu icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should display profile icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should display three time range indicators', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should find 3 time indicators (start time, next reminder, end time)
      final timeIndicators = find.byType(Container).evaluate()
          .where((element) {
            final widget = element.widget as Container;
            return widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color != null &&
                (widget.decoration! as BoxDecoration).color!.alpha < 255;
          });
      
      expect(timeIndicators.length, greaterThanOrEqualTo(3));
    });

    testWidgets('should show navigation menu when hamburger menu is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap hamburger menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Should show bottom sheet with menu items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('should navigate to settings when profile icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap profile icon
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Should navigate to settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('should navigate to settings from menu', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap hamburger menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap settings in menu
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Should navigate to settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('should show help dialog when help is tapped from menu', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap hamburger menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap help & support
      await tester.tap(find.text('Help & Support'));
      await tester.pumpAndSettle();

      // Should show help dialog
      expect(find.text('Help & Support'), findsWidgets);
      expect(find.text('Welcome to Water Tracker!'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('should close help dialog when Got it is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open help dialog
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Help & Support'));
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Welcome to Water Tracker!'), findsNothing);
    });

    testWidgets('should show snackbar for history feature', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap hamburger menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap history
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('History feature coming soon'), findsOneWidget);
    });

    testWidgets('should navigate to home when home is tapped from menu', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap hamburger menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Menu should be closed
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('should close menu when tapping outside', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap outside menu (on barrier)
      await tester.tapAt(const Offset(50, 50));
      await tester.pumpAndSettle();

      // Menu should be closed
      expect(find.text('Home'), findsNothing);
    });

    group('Time Range Indicators', () {
      testWidgets('should format time correctly', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Time indicators should be present and formatted
        // We can't test exact times due to dynamic nature, but we can test format
        final timeTexts = tester.widgetList<Text>(find.byType(Text))
            .where((text) => text.data != null && 
                (text.data!.contains('AM') || text.data!.contains('PM') || text.data!.contains('min')))
            .toList();

        expect(timeTexts.length, greaterThanOrEqualTo(2));
      });

      testWidgets('should update time indicators on init', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should have time indicators displayed
        final containers = tester.widgetList<Container>(find.byType(Container))
            .where((container) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  decoration.borderRadius != null &&
                  decoration.color != null;
            }).toList();

        expect(containers.length, greaterThanOrEqualTo(3));
      });
    });

    group('Header Styling', () {
      testWidgets('should have correct header styling', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check Today title styling
        final titleText = tester.widget<Text>(find.text('Today'));
        expect(titleText.style?.fontSize, 24);
        expect(titleText.style?.fontWeight, FontWeight.w700);
        expect(titleText.style?.color, Colors.white);
      });

      testWidgets('should have correct icon button styling', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check icon containers
        final iconContainers = tester.widgetList<Container>(find.byType(Container))
            .where((container) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  container.width == 40 &&
                  container.height == 40;
            }).toList();

        expect(iconContainers.length, greaterThanOrEqualTo(2));
      });

      testWidgets('should have gradient background', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find the main container with gradient
        final mainContainer = tester.widgetList<Container>(find.byType(Container))
            .firstWhere((container) {
              final decoration = container.decoration;
              return decoration is BoxDecoration &&
                  decoration.gradient is LinearGradient;
            });

        final gradient = (mainContainer.decoration! as BoxDecoration).gradient! as LinearGradient;
        expect(gradient.colors.length, 2);
        expect(gradient.colors[0], const Color(0xFF6B73FF));
        expect(gradient.colors[1], const Color(0xFF9546C4));
      });
    });
  });
}