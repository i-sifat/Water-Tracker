import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';

class LargeSelectionBox extends StatelessWidget {
  const LargeSelectionBox({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.iconBackgroundColor,
  });
  final String title;
  final String subtitle;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      onTap: onTap,
      isSelected: isSelected,
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? 
                  (isSelected 
                      ? theme.colorScheme.primaryContainer 
                      : AppColors.boxIconBackground),
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
