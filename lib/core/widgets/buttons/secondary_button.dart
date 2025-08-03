import 'package:flutter/material.dart';
import 'package:watertracker/core/widgets/buttons/base_button.dart';

class SecondaryButton extends BaseButton {
  const SecondaryButton({
    required super.onPressed,
    required super.text,
    super.key,
    super.isLoading = false,
    super.isDisabled = false,
    super.icon,
    super.width,
    super.height = 56,
  });

  @override
  ButtonStyle getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.styleFrom(
      side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget buildButton(BuildContext context, Widget child) {
    return OutlinedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: getButtonStyle(context),
      child: child,
    );
  }

  @override
  Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Color getLoadingIndicatorColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
}
