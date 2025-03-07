import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/colors.dart';
import 'package:watertracker/core/constants/typography.dart';

class PreferNotToAnswerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PreferNotToAnswerButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF3F1FF),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Prefer not to answer',
            style: AppTypography.buttonText.copyWith(
              color: AppColors.selectedBorder,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.close,
            size: 20,
            color: AppColors.selectedBorder,
          ),
        ],
      ),
    );
  }
}