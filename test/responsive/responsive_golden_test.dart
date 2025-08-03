import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/responsive_scaffold.dart';
import 'package:watertracker/core/widgets/adaptive_widgets.dart';
import 'package:watertracker/features/onboarding/screens/welcome_screen.dart';
import 'package:watertracker/features/onboarding/screens/age_selection_screen.dart';

void main() {
  group('Responsive Golden Tests', () {
    group('Screen Size Golden Tests', () {
      testWidgets('should match golden for small phone layout', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              fontFamily: 'Roboto', // Ensure consistent font for golden tests
            ),
            home: ResponsiveScaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AdaptiveText(
                    'Small Phone Layout',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ResponsiveContainer(
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Center(
                      child: AdaptiveText('Responsive Container'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ResponsiveIcon(Icons.home, size: 24, color: Colors.blue),
                      ResponsiveIcon(
                        Icons.settings,
                        size: 24,
                        color: Colors.green,
                      ),
                      ResponsiveIcon(
                        Icons.person,
                        size: 24,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ResponsiveButton(
                    text: 'Small Phone Button',
                    onPressed: () {},
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/responsive_small_phone.png'),
        );
      });

      testWidgets('should match golden for medium phone layout', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: ResponsiveScaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AdaptiveText(
                    'Medium Phone Layout',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ResponsiveContainer(
                    width: 250,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Center(
                      child: AdaptiveText('Responsive Container'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ResponsiveIcon(Icons.home, size: 28, color: Colors.blue),
                      ResponsiveIcon(
                        Icons.settings,
                        size: 28,
                        color: Colors.green,
                      ),
                      ResponsiveIcon(
                        Icons.person,
                        size: 28,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ResponsiveButton(
                    text: 'Medium Phone Button',
                    onPressed: () {},
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/responsive_medium_phone.png'),
        );
      });

      testWidgets('should match golden for large phone layout', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(414, 896));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: ResponsiveScaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AdaptiveText(
                    'Large Phone Layout',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ResponsiveContainer(
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Center(
                      child: AdaptiveText('Responsive Container'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ResponsiveIcon(Icons.home, size: 32, color: Colors.blue),
                      ResponsiveIcon(
                        Icons.settings,
                        size: 32,
                        color: Colors.green,
                      ),
                      ResponsiveIcon(
                        Icons.person,
                        size: 32,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ResponsiveButton(
                    text: 'Large Phone Button',
                    onPressed: () {},
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/responsive_large_phone.png'),
        );
      });

      testWidgets('should match golden for tablet layout', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: ResponsiveScaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AdaptiveText(
                    'Tablet Layout',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ResponsiveContainer(
                    width: 400,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: const Center(
                      child: AdaptiveText(
                        'Tablet Responsive Container',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ResponsiveIcon(Icons.home, size: 40, color: Colors.blue),
                      ResponsiveIcon(
                        Icons.settings,
                        size: 40,
                        color: Colors.green,
                      ),
                      ResponsiveIcon(
                        Icons.person,
                        size: 40,
                        color: Colors.orange,
                      ),
                      ResponsiveIcon(
                        Icons.tablet,
                        size: 40,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ResponsiveButton(
                    text: 'Tablet Button',
                    onPressed: () {},
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/responsive_tablet.png'),
        );
      });
    });

    group('Orientation Golden Tests', () {
      testWidgets('should match golden for portrait orientation', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: ResponsiveScaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AdaptiveText(
                    'Portrait Mode',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ResponsiveContainer(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: AdaptiveText('Tall Container')),
                  ),
                  ResponsiveButton(text: 'Portrait Button', onPressed: () {}),
                ],
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/responsive_portrait.png'),
        );
      });

      testWidgets('should match golden for landscape orientation', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(667, 375));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: ResponsiveScaffold(
              body: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AdaptiveText(
                        'Landscape Mode',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ResponsiveButton(
                        text: 'Landscape Button',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  ResponsiveContainer(
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: AdaptiveText('Wide Container')),
                  ),
                ],
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/responsive_landscape.png'),
        );
      });
    });

    group('Real Screen Golden Tests', () {
      testWidgets('WelcomeScreen should match golden for small phone', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: const WelcomeScreen(),
          ),
        );

        // Allow for any animations to complete
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/welcome_screen_small_phone.png'),
        );
      });

      testWidgets('WelcomeScreen should match golden for medium phone', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: const WelcomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/welcome_screen_medium_phone.png'),
        );
      });

      testWidgets('WelcomeScreen should match golden for tablet', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: const WelcomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/welcome_screen_tablet.png'),
        );
      });

      testWidgets('AgeSelectionScreen should match golden for medium phone', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: const AgeSelectionScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/age_selection_screen_medium_phone.png'),
        );
      });
    });

    group('Component Golden Tests', () {
      testWidgets('ResponsiveButton variations should match golden', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: ResponsiveScaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ResponsiveButton(
                    text: 'Elevated Button',
                    onPressed: () {},
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  ResponsiveButton(
                    text: 'Outlined Button',
                    type: ResponsiveButtonType.outlined,
                    onPressed: () {},
                  ),
                  ResponsiveButton(
                    text: 'Text Button',
                    type: ResponsiveButtonType.text,
                    onPressed: () {},
                  ),
                  ResponsiveButton(text: 'Disabled Button', onPressed: null),
                ],
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/responsive_button_variations.png'),
        );
      });

      testWidgets('ResponsiveCard variations should match golden', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: ResponsiveScaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ResponsiveCard(
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: AdaptiveText('Default Card'),
                    ),
                  ),
                  ResponsiveCard(
                    color: Colors.blue.shade50,
                    elevation: 8,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: AdaptiveText('Elevated Blue Card'),
                    ),
                  ),
                  ResponsiveCard(
                    color: Colors.green.shade50,
                    elevation: 2,
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: AdaptiveText('Green Card with Custom Padding'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/responsive_card_variations.png'),
        );
      });
    });
  });

  // Clean up after tests
  tearDown(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().setSurfaceSize(null);
  });
}
