import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/design_system.dart';

/// Standardized card component with consistent styling and accessibility features
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.margin,
    this.elevation = 2,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  /// Creates a card with standard padding
  const AppCard.padded({
    required this.child,
    this.margin,
    this.elevation = 2,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.semanticLabel,
    super.key,
  }) : padding = AppSpacing.cardPaddingAll;

  /// Creates a clickable card with hover effects
  const AppCard.clickable({
    required this.child,
    required this.onTap,
    this.padding,
    this.margin,
    this.elevation = 2,
    this.backgroundColor,
    this.borderRadius,
    this.semanticLabel,
    super.key,
  });

  /// Creates a card with minimal elevation
  const AppCard.flat({
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.semanticLabel,
    super.key,
  }) : elevation = 0;

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation,
      color: backgroundColor ?? AppColors.surface,
      margin: margin ?? const EdgeInsets.all(AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? AppSpacing.borderRadiusLG,
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (onTap != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusLG,
          child: card,
        ),
      );
    }

    return Semantics(label: semanticLabel, child: card);
  }
}
