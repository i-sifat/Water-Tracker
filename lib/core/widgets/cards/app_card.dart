import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.elevation = 0,
    this.onTap,
    this.isSelected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final effectiveBackgroundColor = backgroundColor ?? 
        (isSelected ? theme.colorScheme.primaryContainer : theme.cardColor);
    
    final effectiveBorderColor = borderColor ?? 
        (isSelected ? theme.colorScheme.primary : theme.colorScheme.outline);

    Widget cardWidget = Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      cardWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
