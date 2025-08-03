import 'package:flutter/material.dart';

/// Base button widget that provides common functionality for all button types
/// This eliminates duplicate code across different button implementations
abstract class BaseButton extends StatelessWidget {
  const BaseButton({
    required this.onPressed,
    required this.text,
    super.key,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final double height;

  /// Subclasses must implement this to provide button-specific styling
  ButtonStyle getButtonStyle(BuildContext context);

  /// Subclasses can override this to customize the loading indicator
  Widget buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          getLoadingIndicatorColor(context),
        ),
      ),
    );
  }

  /// Subclasses can override this to customize the text style
  TextStyle? getTextStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: getTextColor(context));
  }

  /// Subclasses must implement this to provide text color
  Color getTextColor(BuildContext context);

  /// Subclasses must implement this to provide loading indicator color
  Color getLoadingIndicatorColor(BuildContext context);

  /// Subclasses can override this to customize the button widget type
  Widget buildButton(BuildContext context, Widget child) {
    return ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: getButtonStyle(context),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: buildButton(
        context,
        isLoading
            ? buildLoadingIndicator(context)
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: getTextColor(context)),
                  const SizedBox(width: 8),
                ],
                Text(text, style: getTextStyle(context)),
              ],
            ),
      ),
    );
  }
}
