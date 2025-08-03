import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/design_system.dart';
import 'package:watertracker/core/design_system/animations/micro_interactions.dart';

/// Collection of loading state components for smooth user experience
class LoadingStates {
  LoadingStates._();

  /// Creates a circular loading indicator with consistent styling
  static Widget circular({
    double size = 24.0,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );
  }

  /// Creates a linear loading indicator
  static Widget linear({Color? color, Color? backgroundColor, double? value}) {
    return LinearProgressIndicator(
      value: value,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      backgroundColor: backgroundColor ?? AppColors.progressBackground,
    );
  }

  /// Creates a skeleton loading placeholder
  static Widget skeleton({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return MicroInteractions.shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.progressBackground,
          borderRadius: borderRadius ?? AppSpacing.borderRadiusSM,
        ),
      ),
    );
  }

  /// Creates a skeleton text placeholder
  static Widget skeletonText({
    double? width,
    double height = 16.0,
    int lines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        final lineWidth = width ?? (isLastLine ? 100.0 : 200.0);

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < lines - 1 ? AppSpacing.xs : 0,
          ),
          child: skeleton(width: lineWidth, height: height),
        );
      }),
    );
  }

  /// Creates a skeleton card placeholder
  static Widget skeletonCard({
    double? width,
    double height = 120.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AppCard(
      padding: padding ?? AppSpacing.cardPaddingAll,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          skeleton(width: width ?? double.infinity, height: height * 0.6),
          AppSpacing.verticalSpaceSM,
          skeletonText(width: width, lines: 2),
        ],
      ),
    );
  }

  /// Creates a loading overlay
  static Widget overlay({
    required Widget child,
    required bool isLoading,
    String? loadingText,
    Color? overlayColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? AppColors.overlay,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  circular(size: 48.0),
                  if (loadingText != null) ...[
                    AppSpacing.verticalSpaceMD,
                    AppText.body(loadingText, color: AppColors.textOnPrimary),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Creates a loading button state
  static Widget loadingButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    AppButtonStyle style = AppButtonStyle.primary,
    AppButtonSize size = AppButtonSize.medium,
  }) {
    return AppButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      size: size,
      isLoading: isLoading,
      child: Text(text),
    );
  }

  /// Creates a pull-to-refresh indicator
  static Widget pullToRefresh({
    required Widget child,
    required Future<void> Function() onRefresh,
    Color? color,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primary,
      backgroundColor: AppColors.surface,
      child: child,
    );
  }

  /// Creates a loading list item
  static Widget loadingListItem({
    double height = 80.0,
    bool showAvatar = true,
    int textLines = 2,
  }) {
    return Container(
      height: height,
      padding: AppSpacing.cardPaddingAll,
      child: Row(
        children: [
          if (showAvatar) ...[
            skeleton(
              width: 48.0,
              height: 48.0,
              borderRadius: AppSpacing.borderRadiusCircular,
            ),
            AppSpacing.horizontalSpaceMD,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [skeletonText(lines: textLines)],
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a loading grid item
  static Widget loadingGridItem({double? width, double height = 120.0}) {
    return Container(
      width: width,
      height: height,
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: skeleton(width: double.infinity, height: double.infinity),
          ),
          AppSpacing.verticalSpaceSM,
          skeletonText(lines: 1),
        ],
      ),
    );
  }

  /// Creates a loading state for empty content
  static Widget empty({
    required String title,
    required String description,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 64.0, color: AppColors.textSecondary),
              AppSpacing.verticalSpaceLG,
            ],
            AppText.headline(
              title,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            AppSpacing.verticalSpaceSM,
            AppText.body(
              description,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            if (action != null) ...[AppSpacing.verticalSpaceLG, action],
          ],
        ),
      ),
    );
  }

  /// Creates an error state with retry option
  static Widget error({
    required String title,
    required String description,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64.0,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceLG,
            AppText.headline(
              title,
              textAlign: TextAlign.center,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceSM,
            AppText.body(
              description,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            if (onRetry != null) ...[
              AppSpacing.verticalSpaceLG,
              AppButton.primary(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates a success state
  static Widget success({
    required String title,
    required String description,
    VoidCallback? onContinue,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.check_circle_outline,
              size: 64.0,
              color: AppColors.success,
            ),
            AppSpacing.verticalSpaceLG,
            AppText.headline(
              title,
              textAlign: TextAlign.center,
              color: AppColors.success,
            ),
            AppSpacing.verticalSpaceSM,
            AppText.body(
              description,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            if (onContinue != null) ...[
              AppSpacing.verticalSpaceLG,
              AppButton.primary(
                onPressed: onContinue,
                child: const Text('Continue'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
