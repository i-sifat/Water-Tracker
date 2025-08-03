import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/design_system.dart';

/// Accessible hydration button with proper touch targets and semantic labeling
class AccessibleHydrationButton extends StatefulWidget {
  const AccessibleHydrationButton({
    required this.amount,
    required this.onPressed,
    required this.backgroundColor,
    this.iconPath,
    this.isEnabled = true,
    super.key,
  });

  final int amount;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final String? iconPath;
  final bool isEnabled;

  @override
  State<AccessibleHydrationButton> createState() =>
      _AccessibleHydrationButtonState();
}

class _AccessibleHydrationButtonState extends State<AccessibleHydrationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    _animationController.forward();
    HapticFeedbackUtils.light();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTap() {
    if (!widget.isEnabled) return;
    HapticFeedbackUtils.waterAdded();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final semanticLabel =
        'Add ${widget.amount} milliliters of water to your daily intake';

    return Semantics(
      label: semanticLabel,
      hint: 'Double tap to add water',
      button: true,
      enabled: widget.isEnabled,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AccessibilityHelper.minTouchTargetSize,
          minHeight: AccessibilityHelper.minTouchTargetSize,
        ),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: _handleTap,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:
                        widget.isEnabled
                            ? widget.backgroundColor
                            : AppColors.buttonDisabled,
                    borderRadius: AppSpacing.borderRadiusLG,
                    boxShadow:
                        widget.isEnabled && !_isPressed
                            ? [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.iconPath != null) ...[
                        // Icon would go here if using SVG
                        Icon(
                          Icons.local_drink,
                          size: AppSpacing.iconLG,
                          color:
                              widget.isEnabled
                                  ? AppColors.textPrimary
                                  : AppColors.textDisabled,
                        ),
                        AppSpacing.verticalSpaceXS,
                      ],
                      AppText.label(
                        '${widget.amount}ml',
                        color:
                            widget.isEnabled
                                ? AppColors.textPrimary
                                : AppColors.textDisabled,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
