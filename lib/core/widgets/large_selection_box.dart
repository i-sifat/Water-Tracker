import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class LargeSelectionBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;

  const LargeSelectionBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.selectedBorder
                    : AppColors.unselectedBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? AppColors.boxIconBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headline.copyWith(
                      fontSize: 20,
                      color:
                          isSelected
                              ? AppColors.selectedBorder
                              : AppColors.assessmentText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
