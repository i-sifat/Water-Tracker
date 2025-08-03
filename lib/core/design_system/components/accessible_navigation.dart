import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watertracker/core/design_system/design_system.dart';
import 'package:watertracker/core/design_system/accessibility/accessibility_helper.dart';

/// Accessible navigation button with proper focus management and semantics
class AccessibleNavigationButton extends StatelessWidget {
  const AccessibleNavigationButton({
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.isEnabled = true,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.createAccessibleButton(
      onPressed: isEnabled ? onPressed : null,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      enabled: isEnabled,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary,
          borderRadius: AppSpacing.borderRadiusMD,
        ),
        child: DefaultTextStyle(
          style: AppTypography.buttonMedium.copyWith(
            color: foregroundColor ?? AppColors.textOnPrimary,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Accessible tab navigation with proper focus management
class AccessibleTabNavigation extends StatelessWidget {
  const AccessibleTabNavigation({
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
    super.key,
  });

  final List<AccessibleTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children:
            tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: AccessibilityHelper.createAccessibleButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onTabChanged(index);
                  },
                  semanticLabel:
                      '${tab.label}${isSelected ? ', selected' : ''}',
                  tooltip: tab.tooltip,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.selectedShade
                              : Colors.transparent,
                      border:
                          isSelected
                              ? const Border(
                                top: BorderSide(
                                  color: AppColors.primary,
                                  width: 3,
                                ),
                              )
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: AppSpacing.iconMD,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                        ),
                        AppSpacing.verticalSpaceXS,
                        AppText.caption(
                          tab.label,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// Data class for accessible tab configuration
class AccessibleTab {
  const AccessibleTab({required this.label, required this.icon, this.tooltip});

  final String label;
  final IconData icon;
  final String? tooltip;
}

/// Accessible page indicator with proper semantics
class AccessiblePageIndicator extends StatelessWidget {
  const AccessiblePageIndicator({
    required this.currentPage,
    required this.totalPages,
    this.onPageTap,
    super.key,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${currentPage + 1} of $totalPages',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final isActive = index == currentPage;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: GestureDetector(
              onTap:
                  onPageTap != null
                      ? () {
                        HapticFeedback.selectionClick();
                        onPageTap!(index);
                      }
                      : null,
              child: Semantics(
                label: 'Page ${index + 1}${isActive ? ', current page' : ''}',
                button: onPageTap != null,
                selected: isActive,
                child: Container(
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? AppColors.pageIndicatorActive
                            : AppColors.pageIndicatorInactive,
                    borderRadius: AppSpacing.borderRadiusCircular,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Accessible back button with proper navigation semantics
class AccessibleBackButton extends StatelessWidget {
  const AccessibleBackButton({this.onPressed, this.semanticLabel, super.key});

  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.createAccessibleIconButton(
      icon: Icons.arrow_back,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      semanticLabel: semanticLabel ?? 'Go back',
      tooltip: 'Navigate to previous screen',
      iconSize: AppSpacing.iconMD,
      color: AppColors.textPrimary,
    );
  }
}

/// Accessible close button with proper semantics
class AccessibleCloseButton extends StatelessWidget {
  const AccessibleCloseButton({this.onPressed, this.semanticLabel, super.key});

  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.createAccessibleIconButton(
      icon: Icons.close,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      semanticLabel: semanticLabel ?? 'Close',
      tooltip: 'Close current screen',
      iconSize: AppSpacing.iconMD,
      color: AppColors.textPrimary,
    );
  }
}
