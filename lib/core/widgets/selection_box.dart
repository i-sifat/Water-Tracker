import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class SelectionBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;

  const SelectionBox({
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
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedShade : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.selectedBorder
                    : AppColors.unselectedBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? AppColors.boxIconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headline.copyWith(
                        fontSize: 18,
                        color:
                            isSelected
                                ? AppColors.selectedBorder
                                : AppColors.assessmentText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.subtitle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
