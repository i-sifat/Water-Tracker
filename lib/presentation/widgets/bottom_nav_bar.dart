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
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 64 + 40,
        padding: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0),
              Colors.white,
            ],
            stops: const [0, 0.5],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarItem(
              icon: AppSymbols.water_drop,
              isSelected: currentPage == 0,
              onTap: () => onChanged(0),
            ),
            _NavBarItem(
              icon: AppSymbols.water_glass,
              isSelected: currentPage == 1,
              onTap: () => onChanged(1),
            ),
            _NavBarItem(
              icon: Icons.settings,
              isSelected: currentPage == 2,
              onTap: () => onChanged(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected ? theme.primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 32,
            color: isSelected ? Colors.white : theme.primaryColor,
          ),
        ),
      ),
    );
  }
}