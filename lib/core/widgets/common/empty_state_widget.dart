import 'package:flutter/material.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.illustration,
    this.actionText,
    this.onActionPressed,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or illustration
            if (illustration != null)
              illustration!
            else if (icon != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Action button
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: onActionPressed,
                text: actionText!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}