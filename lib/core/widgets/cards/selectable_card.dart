import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';

/// Reusable selectable card widget for weather and other selections
class SelectableCardWithIcon extends StatelessWidget {
  const SelectableCardWithIcon({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.selectedColor,
    this.unselectedColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? (selectedColor ?? AppColors.weatherSelectedCard)
              : (unselectedColor ?? AppColors.weatherUnselectedCard),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : AppColors.textSubtitle,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textHeadline,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.8) 
                    : AppColors.textSubtitle,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}