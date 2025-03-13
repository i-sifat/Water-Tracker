import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
    this.backgroundColor,
  });
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor ?? Colors.white),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                selectedIconPath:
                    'assets/images/icons/navbar/waterdropicons-selected.svg',
                unselectedIconPath:
                    'assets/images/icons/navbar/waterdropicons-unselect.svg',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                selectedIconPath:
                    'assets/images/icons/navbar/circle-notch-selected.svg',
                unselectedIconPath:
                    'assets/images/icons/navbar/circle-notch-non-selected.svg',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                selectedIconPath:
                    'assets/images/icons/navbar/options-selected.svg',
                unselectedIconPath:
                    'assets/images/icons/navbar/options-nonselected.svg',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String selectedIconPath,
    required String unselectedIconPath,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38305C) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: SvgPicture.asset(
          isSelected ? selectedIconPath : unselectedIconPath,
          width: 24,
          height: 24,
          color:
              isSelected ? Colors.white : const Color(0xFF323062).withAlpha(77),
        ),
      ),
    );
  }
}
