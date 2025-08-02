import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';

void main() {
  group('Header Navigation Simple Tests', () {
    testWidgets('header icons are present', (WidgetTester tester) async {
      final provider = HydrationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: provider,
            child: const Scaffold(body: MainHydrationPage()),
          ),
        ),
      );

      // Check for hamburger menu icon
      expect(find.byIcon(Icons.menu), findsOneWidget);

      // Check for profile icon
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      // Check for Today title
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('menu tap shows navigation options', (
      WidgetTester tester,
    ) async {
      final provider = HydrationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HydrationProvider>.value(
            value: provider,
            child: const Scaffold(body: MainHydrationPage()),
          ),
        ),
      );

      // Tap hamburger menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Should show navigation menu
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
