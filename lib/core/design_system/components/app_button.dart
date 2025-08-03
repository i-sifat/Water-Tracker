import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/design_system.dart';

/// Standardized button component with consistent styling and accessibility features
class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    required this.child,
    this.style = AppButtonStyle.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.semanticLabel,
    super.key,
  });

  /// Creates a primary button with standard styling
  const AppButton.primary({
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.semanticLabel,
    super.key,
  }) : style = AppButtonStyle.primary;

  /// Creates a secondary button with outline styling
  const AppButton.secondary({
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.semanticLabel,
    super.key,
  }) : style = AppButtonStyle.secondary;

  /// Creates a text button with minimal styling
  const AppButton.text({
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.semanticLabel,
    super.key,
  }) : style = AppButtonStyle.text;

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonStyle style;
  final AppButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isInteractive = isEnabled && !isLoading && onPressed != null;

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: isInteractive,
      child: SizedBox(
        width: width,
        height: height ?? _getButtonHeight(),
        child: _buildButton(context, isInteractive),
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isInteractive) {
    final buttonChild =
        isLoading
            ? SizedBox(
              width: _getIconSize(),
              height: _getIconSize(),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
              ),
            )
            : child;

    switch (style) {
      case AppButtonStyle.primary:
        return ElevatedButton(
          onPressed: isInteractive ? _handlePress : null,
          style: _getPrimaryButtonStyle(),
          child: buttonChild,
        );
      case AppButtonStyle.secondary:
        return OutlinedButton(
          onPressed: isInteractive ? _handlePress : null,
          style: _getSecondaryButtonStyle(),
          child: buttonChild,
        );
      case AppButtonStyle.text:
        return TextButton(
          onPressed: isInteractive ? _handlePress : null,
          style: _getTextButtonStyle(),
          child: buttonChild,
        );
    }
  }

  void _handlePress() {
    // Add haptic feedback for better user experience
    HapticFeedbackUtils.buttonPress();
    onPressed?.call();
  }

  double _getButtonHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36.0;
      case AppButtonSize.medium:
        return AppSpacing.minTouchTarget;
      case AppButtonSize.large:
        return 56.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.iconSM;
      case AppButtonSize.medium:
        return AppSpacing.iconMD;
      case AppButtonSize.large:
        return AppSpacing.iconLG;
    }
  }

  Color _getLoadingColor() {
    switch (style) {
      case AppButtonStyle.primary:
        return AppColors.textOnPrimary;
      case AppButtonStyle.secondary:
      case AppButtonStyle.text:
        return AppColors.primary;
    }
  }

  ButtonStyle _getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor:
          isEnabled ? AppColors.buttonPrimary : AppColors.buttonDisabled,
      foregroundColor: AppColors.buttonText,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      minimumSize: Size(0, _getButtonHeight()),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMD),
      elevation: isEnabled ? 2 : 0,
    );
  }

  ButtonStyle _getSecondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: isEnabled ? AppColors.primary : AppColors.textDisabled,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      minimumSize: Size(0, _getButtonHeight()),
      side: BorderSide(
        color: isEnabled ? AppColors.primary : AppColors.textDisabled,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMD),
    );
  }

  ButtonStyle _getTextButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: isEnabled ? AppColors.primary : AppColors.textDisabled,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      minimumSize: Size(0, _getButtonHeight()),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSM),
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.buttonSmall;
      case AppButtonSize.medium:
        return AppTypography.buttonMedium;
      case AppButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        );
    }
  }
}

/// Button style variants
enum AppButtonStyle { primary, secondary, text }

/// Button size variants
enum AppButtonSize { small, medium, large }
