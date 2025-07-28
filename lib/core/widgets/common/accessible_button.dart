import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watertracker/core/services/accessibility_service.dart';
import 'package:watertracker/core/utils/rtl_utils.dart';

/// An accessible button widget that ensures proper touch targets,
/// focus management, and semantic labels
class AccessibleButton extends StatefulWidget {
  const AccessibleButton({
    required this.child,
    super.key,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.autofocus = false,
    this.focusNode,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      HapticFeedback.lightImpact();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = Container(
      constraints: const BoxConstraints(
        minWidth: AccessibilityService.minimumTouchTargetSize,
        minHeight: AccessibilityService.minimumTouchTargetSize,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.primary,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        border:
            _isFocused
                ? Border.all(color: theme.colorScheme.onSurface, width: 2)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed != null ? _handleTap : null,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          child: Padding(
            padding:
                widget.padding ??
                RTLUtils.getDirectionalPadding(
                  start: 24,
                  end: 24,
                  top: 16,
                  bottom: 16,
                ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.foregroundColor ?? theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    // Add semantic label if provided
    if (widget.semanticLabel != null) {
      button = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: widget.onPressed != null,
        child: button,
      );
    }

    // Add tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip, child: button);
    }

    return button;
  }
}

/// An accessible icon button with proper touch targets
class AccessibleIconButton extends StatefulWidget {
  const AccessibleIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.color,
    this.size,
    this.autofocus = false,
    this.focusNode,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final Color? color;
  final double? size;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<AccessibleIconButton> createState() => _AccessibleIconButtonState();
}

class _AccessibleIconButtonState extends State<AccessibleIconButton> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      HapticFeedback.lightImpact();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = Container(
      width: AccessibilityService.minimumTouchTargetSize,
      height: AccessibilityService.minimumTouchTargetSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            _isFocused
                ? Border.all(color: theme.colorScheme.onSurface, width: 2)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onPressed != null ? _handleTap : null,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          customBorder: const CircleBorder(),
          child: Icon(
            widget.icon,
            color: widget.color ?? theme.colorScheme.onSurface,
            size: widget.size ?? 24,
          ),
        ),
      ),
    );

    // Add semantic label if provided
    if (widget.semanticLabel != null) {
      button = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: widget.onPressed != null,
        child: button,
      );
    }

    // Add tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip, child: button);
    }

    return button;
  }
}

/// An accessible text field with proper focus management
class AccessibleTextField extends StatefulWidget {
  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onTap,
    this.autofocus = false,
    this.focusNode,
    this.validator,
  });
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  @override
  State<AccessibleTextField> createState() => _AccessibleTextFieldState();
}

class _AccessibleTextFieldState extends State<AccessibleTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
    );

    // Add semantic label if provided
    if (widget.semanticLabel != null) {
      textField = Semantics(
        label: widget.semanticLabel,
        textField: true,
        child: textField,
      );
    }

    return textField;
  }
}
