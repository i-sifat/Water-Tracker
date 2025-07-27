import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/settings/providers/settings_provider.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late SettingsProvider mockSettingsProvider;

    setUp(() {
      mockSettingsProvider = SettingsProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<SettingsProvider>.value(
          value: mockSettingsProvider,
          child: const SettingsScreen(),
        ),
      );
    }

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has app bar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('has custom bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
    });

    testWidgets('has scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('contains list view for settings options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('has user profile section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Profile'), findsWidgets);
    });

    testWidgets('has notification settings option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Notifications'), findsOneWidget);
    });

    testWidgets('has theme settings option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Theme'), findsOneWidget);
    });

    testWidgets('has language settings option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Language'), findsOneWidget);
    });

    testWidgets('has data management option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Data'), findsWidgets);
    });

    testWidgets('has accessibility settings option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Accessibility'), findsOneWidget);
    });

    testWidgets('has premium status display', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Premium'), findsWidgets);
    });

    testWidgets('settings options are interactive', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsWidgets);
      
      // Tap first settings option
      if (listTiles.evaluate().isNotEmpty) {
        await tester.tap(listTiles.first);
        await tester.pump();
      }
      
      // Should not throw errors
    });

    testWidgets('has proper section dividers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('shows app version information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Version'), findsOneWidget);
    });

    testWidgets('has about section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('About'), findsOneWidget);
    });

    testWidgets('has backup and restore options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Backup'), findsWidgets);
      expect(find.textContaining('Restore'), findsWidgets);
    });

    testWidgets('has export data option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Export'), findsOneWidget);
    });

    testWidgets('has clear data option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.textContaining('Clear'), findsWidgets);
    });

    testWidgets('shows user avatar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('has proper padding and margins', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('consumes settings provider correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(Consumer<SettingsProvider>), findsWidgets);
    });

    testWidgets('has switch widgets for toggle settings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('bottom navigation is at correct index', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final bottomNav = tester.widget<CustomBottomNavigationBar>(
        find.byType(CustomBottomNavigationBar),
      );
      expect(bottomNav.selectedIndex, equals(2)); // Settings is typically index 2
    });

    testWidgets('has leading icons for settings options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      
      for (final tile in listTiles) {
        if (tile.leading != null) {
          expect(tile.leading, isA<Icon>());
        }
      }
    });

    testWidgets('has trailing icons for navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byIcon(Icons.arrow_forward_ios), findsWidgets);
    });
  });
}