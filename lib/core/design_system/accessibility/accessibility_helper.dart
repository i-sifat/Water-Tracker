import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watertracker/core/design_system/design_system.dart';

/// Helper class for implementing consistent accessibility features throughout the app
class AccessibilityHelper {
  AccessibilityHelper._();

  /// Minimum touch target size as per accessibility guidelines (44x44 dp)
  static const double minTouchTargetSize = 44.0;
  static const Size minTouchTargetSizeBox = Size(
    minTouchTargetSize,
    minTouchTargetSize,
  );

  /// Ensures a widget meets minimum touch target size requirements
  static Widget ensureMinTouchTarget({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    String? tooltip,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: minTouchTargetSize,
        minHeight: minTouchTargetSize,
      ),
      child: _wrapWithSemantics(
        child:
            onTap != null
                ? InkWell(
                  onTap: onTap,
                  borderRadius: AppSpacing.borderRadiusSM,
                  child: Center(child: child),
                )
                : Center(child: child),
        semanticLabel: semanticLabel,
        tooltip: tooltip,
        isButton: onTap != null,
      ),
    );
  }

  /// Creates an accessible button with proper semantics and haptic feedback
  static Widget createAccessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    bool enabled = true,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: tooltip,
      button: true,
      enabled: enabled && onPressed != null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: minTouchTargetSize,
          minHeight: minTouchTargetSize,
        ),
        child: InkWell(
          onTap:
              enabled && onPressed != null
                  ? () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  }
                  : null,
          borderRadius: AppSpacing.borderRadiusMD,
          child: Center(child: child),
        ),
      ),
    );
  }

  /// Creates accessible text with proper contrast and semantic labeling
  static Widget createAccessibleText({
    required String text,
    TextStyle? style,
    String? semanticLabel,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  /// Creates an accessible form field with proper labeling
  static Widget createAccessibleFormField({
    required Widget child,
    required String label,
    String? hint,
    String? error,
    bool required = false,
  }) {
    return Semantics(
      label: required ? '$label (required)' : label,
      hint: hint,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            AppText.label(
              required ? '$label *' : label,
              color: AppColors.textPrimary,
            ),
            AppSpacing.verticalSpaceSM,
          ],
          child,
          if (error != null) ...[
            AppSpacing.verticalSpaceXS,
            AppText.error(error),
          ],
        ],
      ),
    );
  }

  /// Creates an accessible icon button with proper semantics
  static Widget createAccessibleIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? tooltip,
    double? iconSize,
    Color? color,
    bool enabled = true,
  }) {
    return Tooltip(
      message: tooltip ?? semanticLabel,
      child: Semantics(
        label: semanticLabel,
        hint: tooltip,
        button: true,
        enabled: enabled && onPressed != null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: minTouchTargetSize,
            minHeight: minTouchTargetSize,
          ),
          child: IconButton(
            onPressed:
                enabled && onPressed != null
                    ? () {
                      HapticFeedback.lightImpact();
                      onPressed!();
                    }
                    : null,
            icon: Icon(
              icon,
              size: iconSize ?? AppSpacing.iconMD,
              color: color ?? AppColors.textPrimary,
            ),
            iconSize: iconSize ?? AppSpacing.iconMD,
          ),
        ),
      ),
    );
  }

  /// Creates an accessible card with proper focus management
  static Widget createAccessibleCard({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    String? tooltip,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    final card = AppCard(padding: padding, margin: margin, child: child);

    if (onTap != null) {
      return Semantics(
        label: semanticLabel,
        hint: tooltip,
        button: true,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppSpacing.borderRadiusLG,
          child: card,
        ),
      );
    }

    return Semantics(label: semanticLabel, child: card);
  }

  /// Creates an accessible slider with proper semantics
  static Widget createAccessibleSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required String semanticLabel,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String Function(double)? semanticFormatterCallback,
  }) {
    return Semantics(
      label: semanticLabel,
      value: semanticFormatterCallback?.call(value) ?? value.toString(),
      slider: true,
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        semanticFormatterCallback: semanticFormatterCallback,
      ),
    );
  }

  /// Creates an accessible switch with proper semantics
  static Widget createAccessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    String? description,
  }) {
    return Semantics(
      label: label,
      hint: description,
      toggled: value,
      child: SwitchListTile(
        title: AppText.body(label),
        subtitle: description != null ? AppText.caption(description) : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Creates an accessible checkbox with proper semantics
  static Widget createAccessibleCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    String? description,
  }) {
    return Semantics(
      label: label,
      hint: description,
      checked: value,
      child: CheckboxListTile(
        title: AppText.body(label),
        subtitle: description != null ? AppText.caption(description) : null,
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  /// Creates an accessible radio button with proper semantics
  static Widget createAccessibleRadio<T>({
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    required String label,
    String? description,
  }) {
    return Semantics(
      label: label,
      hint: description,
      selected: value == groupValue,
      child: RadioListTile<T>(
        title: AppText.body(label),
        subtitle: description != null ? AppText.caption(description) : null,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }

  /// Wraps a widget with proper semantic information
  static Widget _wrapWithSemantics({
    required Widget child,
    String? semanticLabel,
    String? tooltip,
    bool isButton = false,
  }) {
    Widget result = child;

    if (tooltip != null) {
      result = Tooltip(message: tooltip, child: result);
    }

    if (semanticLabel != null) {
      result = Semantics(label: semanticLabel, button: isButton, child: result);
    }

    return result;
  }

  /// Checks if a color combination meets WCAG contrast requirements
  static bool meetsContrastRequirements(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();

    final lighter =
        foregroundLuminance > backgroundLuminance
            ? foregroundLuminance
            : backgroundLuminance;
    final darker =
        foregroundLuminance > backgroundLuminance
            ? backgroundLuminance
            : foregroundLuminance;

    final contrastRatio = (lighter + 0.05) / (darker + 0.05);

    // WCAG AA standard requires 4.5:1 for normal text, 3:1 for large text
    return contrastRatio >= 4.5;
  }

  /// Provides haptic feedback for different interaction types
  static void provideFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }
}

/// Types of haptic feedback
enum HapticFeedbackType { light, medium, heavy, selection }
