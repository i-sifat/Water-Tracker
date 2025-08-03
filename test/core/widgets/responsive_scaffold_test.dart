import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/responsive_scaffold.dart';

void main() {
  group('ResponsiveScaffold', () {
    testWidgets('should render basic scaffold with body', (
      WidgetTester tester,
    ) async {
      const testText = 'Test Body';

      await tester.pumpWidget(
        MaterialApp(home: ResponsiveScaffold(body: Text(testText))),
      );

      expect(find.text(testText), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should apply safe area by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(body: Container(key: Key('test-body'))),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should apply responsive padding by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(body: Container(key: Key('test-body'))),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should render app bar when provided', (
      WidgetTester tester,
    ) async {
      const appBarTitle = 'Test App Bar';

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(
            appBar: AppBar(title: Text(appBarTitle)),
            body: Container(),
          ),
        ),
      );

      expect(find.text(appBarTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render bottom navigation bar when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(
            body: Container(),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should render floating action button when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(
            body: Container(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should handle all scaffold properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(
            body: Text('Body'),
            appBar: AppBar(title: Text('Title')),
            backgroundColor: Colors.red,
            drawer: Drawer(child: Text('Drawer')),
            endDrawer: Drawer(child: Text('End Drawer')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            resizeToAvoidBottomInset: false,
          ),
        ),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.red);
      expect(scaffold.resizeToAvoidBottomInset, false);
      expect(
        scaffold.floatingActionButtonLocation,
        FloatingActionButtonLocation.centerFloat,
      );
    });
  });

  group('ResponsiveAppBar', () {
    testWidgets('should render basic app bar', (WidgetTester tester) async {
      const title = 'Responsive Title';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: ResponsiveAppBar(title: Text(title)),
            body: Container(),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render leading widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: ResponsiveAppBar(
              title: Text('Title'),
              leading: Icon(Icons.menu),
            ),
            body: Container(),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should render actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: ResponsiveAppBar(
              title: Text('Title'),
              actions: [
                Icon(Icons.search),
                IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            body: Container(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should have correct preferred size', (
      WidgetTester tester,
    ) async {
      const appBar = ResponsiveAppBar(title: Text('Title'));

      expect(appBar.preferredSize, isA<Size>());
      expect(appBar.preferredSize.height, greaterThan(0));
    });

    testWidgets('should handle app bar properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: ResponsiveAppBar(
              title: Text('Title'),
              backgroundColor: Colors.blue,
              elevation: 4.0,
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Container(),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.blue);
      expect(appBar.elevation, 4.0);
      expect(appBar.centerTitle, true);
      expect(appBar.automaticallyImplyLeading, false);
    });
  });

  group('ResponsiveBottomNavigationBar', () {
    testWidgets('should render navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            bottomNavigationBar: ResponsiveBottomNavigationBar(
              currentIndex: 0,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            bottomNavigationBar: ResponsiveBottomNavigationBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      expect(tappedIndex, equals(1));
    });

    testWidgets('should apply custom colors', (WidgetTester tester) async {
      const selectedColor = Colors.blue;
      const unselectedColor = Colors.grey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            bottomNavigationBar: ResponsiveBottomNavigationBar(
              currentIndex: 0,
              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      expect(bottomNavBar.selectedItemColor, equals(selectedColor));
      expect(bottomNavBar.unselectedItemColor, equals(unselectedColor));
    });

    testWidgets('should handle bottom navigation bar properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            bottomNavigationBar: ResponsiveBottomNavigationBar(
              currentIndex: 1,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 8.0,
              iconSize: 28.0,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      expect(bottomNavBar.currentIndex, 1);
      expect(bottomNavBar.type, BottomNavigationBarType.fixed);
      expect(bottomNavBar.backgroundColor, Colors.white);
      expect(bottomNavBar.elevation, 8.0);
    });
  });

  group('ScaffoldExtension', () {
    testWidgets('should convert regular scaffold to responsive', (
      WidgetTester tester,
    ) async {
      final regularScaffold = Scaffold(
        appBar: AppBar(title: Text('Title')),
        body: Text('Body'),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );

      final responsiveScaffold = regularScaffold.toResponsive();

      await tester.pumpWidget(MaterialApp(home: responsiveScaffold));

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(ResponsiveScaffold), findsOneWidget);
    });

    testWidgets('should convert with custom parameters', (
      WidgetTester tester,
    ) async {
      final regularScaffold = Scaffold(body: Text('Body'));

      final responsiveScaffold = regularScaffold.toResponsive(
        padding: EdgeInsets.all(20.0),
        applySafeArea: false,
        applyResponsivePadding: false,
        limitContentWidth: false,
      );

      await tester.pumpWidget(MaterialApp(home: responsiveScaffold));

      expect(find.text('Body'), findsOneWidget);
      expect(find.byType(ResponsiveScaffold), findsOneWidget);
    });
  });
}
