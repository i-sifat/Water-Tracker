import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/base_button.dart';

class ContinueButton extends BaseButton {
  const ContinueButton({
    required VoidCallback onPressed,
    super.key,
    bool isDisabled = false,
  }) : super(
         onPressed: onPressed,
         text: 'Continue',
         isDisabled: isDisabled,
         icon: Icons.arrow_forward,
       );

  @override
  ButtonStyle getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.textOnPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Color getTextColor(BuildContext context) {
    return AppColors.textOnPrimary;
  }

  @override
  Color getLoadingIndicatorColor(BuildContext context) {
    return AppColors.textOnPrimary;
  }

  @override
  TextStyle? getTextStyle(BuildContext context) {
    return const TextStyle(
      color: AppColors.textOnPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Nunito',
    );
  }
}
