import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/core/resources/app_symbols.dart';
import 'package:watertracker/core/resources/assets.dart';

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
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            isSelected: currentPage == 0,
            icon: AppSymbols.water_drop,
            onTap: () => onChanged(0),
          ),
          _NavBarItem(
            isSelected: currentPage == 1,
            icon: AppSymbols.water_glass,
            onTap: () => onChanged(1),
          ),
          _NavBarItem(
            isSelected: currentPage == 2,
            icon: Icons.history,
            onTap: () => onChanged(2),
          ),
          _NavBarItem(
            isSelected: currentPage == 3,
            icon: Icons.bar_chart,
            onTap: () => onChanged(3),
          ),
          _NavBarItem(
            isSelected: currentPage == 4,
            icon: Icons.settings,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });
  
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        height: 80,
        padding: const EdgeInsets.all(16),
        child: Icon(
          icon,
          color: isSelected ? AppColors.lightBlue : AppColors.textSubtitle,
          size: 24,
        ),
      ),
    );
  }
}