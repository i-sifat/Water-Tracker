import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_symbols.dart';

class BottomNavBar extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onChanged;

  const BottomNavBar({
    super.key,
    required this.currentPage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: currentPage,
      onDestinationSelected: onChanged,
      destinations: [
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