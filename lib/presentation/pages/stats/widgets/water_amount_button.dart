import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_colors.dart';

class WaterAmountButton extends StatelessWidget {
  const WaterAmountButton({
    required this.amount,
    required this.color,
    required this.onTap,
    super.key,
  });
  
  final int amount;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          '$amount ml',
          style: const TextStyle(
            color: AppColors.darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}