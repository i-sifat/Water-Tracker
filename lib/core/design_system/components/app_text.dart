import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/design_system.dart';

/// Standardized text component with consistent typography and accessibility features
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    this.style = AppTextStyle.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  });

  /// Creates a display text (large numbers, main titles)
  const AppText.display(
    this.text, {
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.display;

  /// Creates a headline text (page titles, section headers)
  const AppText.headline(
    this.text, {
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.headline;

  /// Creates a title text (card titles, dialog titles)
  const AppText.title(
    this.text, {
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.title;

  /// Creates body text (regular content)
  const AppText.body(
    this.text, {
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.body;

  /// Creates label text (form labels, button text)
  const AppText.label(
    this.text, {
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.label;

  /// Creates subtitle text (secondary information)
  const AppText.subtitle(
    this.text, {
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.subtitle;

  /// Creates caption text (small descriptive text)
  const AppText.caption(
    this.text, {
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.caption;

  /// Creates error text
  const AppText.error(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.error,
       color = null;

  /// Creates success text
  const AppText.success(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : style = AppTextStyle.success,
       color = null;

  final String text;
  final AppTextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: _getTextStyle().copyWith(color: color),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  TextStyle _getTextStyle() {
    switch (style) {
      case AppTextStyle.display:
        return AppTypography.displayMedium;
      case AppTextStyle.headline:
        return AppTypography.headlineMedium;
      case AppTextStyle.title:
        return AppTypography.titleMedium;
      case AppTextStyle.body:
        return AppTypography.bodyMedium;
      case AppTextStyle.label:
        return AppTypography.labelMedium;
      case AppTextStyle.subtitle:
        return AppTypography.subtitle;
      case AppTextStyle.caption:
        return AppTypography.caption;
      case AppTextStyle.error:
        return AppTypography.error;
      case AppTextStyle.success:
        return AppTypography.success;
    }
  }
}

/// Text style variants
enum AppTextStyle {
  display,
  headline,
  title,
  body,
  label,
  subtitle,
  caption,
  error,
  success,
}
