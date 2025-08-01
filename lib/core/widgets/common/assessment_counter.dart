import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class AssessmentCounter extends StatelessWidget {
  const AssessmentCounter({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${currentStep + 1} of $totalSteps',
        style: const TextStyle(
          color: AppColors.pageCounter,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 