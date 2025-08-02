import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';

/// Example app demonstrating the MainHydrationPage widget
class MainHydrationPageExample extends StatelessWidget {
  const MainHydrationPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Hydration Page Example',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Nunito'),
      home: ChangeNotifierProvider(
        create: (context) => HydrationProvider(),
        child: const MainHydrationPageExampleScreen(),
      ),
    );
  }
}

/// Example screen showing the MainHydrationPage
class MainHydrationPageExampleScreen extends StatefulWidget {
  const MainHydrationPageExampleScreen({super.key});

  @override
  State<MainHydrationPageExampleScreen> createState() =>
      _MainHydrationPageExampleScreenState();
}

class _MainHydrationPageExampleScreenState
    extends State<MainHydrationPageExampleScreen> {
  int _currentPage = 1; // 0: History, 1: Main, 2: Goal Breakdown
  final int _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainHydrationPage(
        currentPage: _currentPage,
        totalPages: _totalPages,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Build bottom navigation to demonstrate page switching
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentPage,
      onTap: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(
          icon: Icon(Icons.water_drop),
          label: 'Hydration',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
      ],
    );
  }
}

/// Main function to run the example
void main() {
  runApp(const MainHydrationPageExample());
}
