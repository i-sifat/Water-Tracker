import 'package:flutter/material.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';

class SelectionBox extends StatelessWidget {
  const SelectionBox({
    required this.title,
    required this.onTap,
    super.key,
    this.subtitle,
    this.icon,
    this.isSelected = false,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.width,
    this.height,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: AppCard(
        onTap: onTap,
        isSelected: isSelected,
        backgroundColor:
            isSelected
                ? (selectedBackgroundColor ??
                    theme.colorScheme.primaryContainer)
                : backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 32,
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.8)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
