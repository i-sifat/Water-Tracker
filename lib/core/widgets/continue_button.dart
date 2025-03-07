import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    required this.onPressed,
    super.key,
    this.isDisabled = false,
  });
  final VoidCallback onPressed;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.selectedBorder,
        foregroundColor: AppColors.buttonText,
        disabledBackgroundColor: Colors.grey[300],
        disabledForegroundColor: Colors.grey[500],
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Continue', style: AppTypography.buttonText),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: AppColors.buttonText, size: 20),
        ],
      ),
    );
  }
}
