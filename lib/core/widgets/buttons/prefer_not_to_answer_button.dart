import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';

class PreferNotToAnswerButton extends StatelessWidget {
  const PreferNotToAnswerButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPurple,
        foregroundColor: AppColors.lightPurple,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Prefer not to answer',
            style: TextStyle(
              color: AppColors.lightPurple,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Nunito',
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.close,
            color: AppColors.lightPurple,
            size: 20,
          ),
        ],
      ),
    );
  }
}
