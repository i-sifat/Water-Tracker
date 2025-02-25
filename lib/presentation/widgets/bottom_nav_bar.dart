import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_symbols.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.currentPage,
    required this.onChanged,
    super.key,
  });
  final int currentPage;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentPage,
      onDestinationSelected: onChanged,
      destinations: const [
        NavigationDestination(
          icon: Icon(AppSymbols.water_drop),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(AppSymbols.water_glass),
          label: 'Progress',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
