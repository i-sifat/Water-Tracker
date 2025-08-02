import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class GoalSelectionCard extends StatelessWidget {
  const GoalSelectionCard({
    required this.title,
    required this.onTap,
    required this.isSelected,
    required this.icon,
    required this.iconBackgroundColor,
    super.key,
  });

  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final Widget icon;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: AppColors.lightPurple,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: icon,
              ),
            ),
            const SizedBox(width: 16),
            // Title text
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeadline,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.lightPurple
                      : AppColors.unselectedBorder,
                  width: 2,
                ),
                color: isSelected ? AppColors.lightPurple : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}