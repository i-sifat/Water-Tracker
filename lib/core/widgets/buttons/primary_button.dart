import 'package:flutter/material.dart';
import 'package:watertracker/core/widgets/buttons/base_button.dart';

class PrimaryButton extends BaseButton {
  const PrimaryButton({
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
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  @override
  Color getLoadingIndicatorColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }
}
