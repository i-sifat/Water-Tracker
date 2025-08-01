import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class CustomRulerPicker extends StatelessWidget {
  const CustomRulerPicker({
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.leftLabel,
    required this.rightLabel,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String leftLabel;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Ruler track
            Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.fitnessSliderBackground,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  // Vertical markers
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return Container(
                          width: 2,
                          height: 24,
                          color: AppColors.fitnessSliderMarkers,
                        );
                      }),
                    ),
                  ),
                  // Selection indicator
                  Positioned(
                    top: 2,
                    left: _getSelectionPosition(constraints.maxWidth),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.lightPurple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lightPurple.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 16,
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        leftLabel,
                        style: TextStyle(
                          color: AppColors.textHeadline,
                          fontSize: 16,
                          fontWeight: value == min ? FontWeight.w700 : FontWeight.w400,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.fitnessQuestionMark,
                        ),
                        child: const Center(
                          child: Text(
                            '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    rightLabel,
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontSize: 16,
                      fontWeight: value == max ? FontWeight.w700 : FontWeight.w400,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  double _getSelectionPosition(double rulerWidth) {
    const circleWidth = 60.0;
    final availableWidth = rulerWidth - circleWidth;
    final step = availableWidth / (max - min);
    final position = (value - min) * step;
    
    // Ensure the circle stays within the ruler boundaries
    return position.clamp(0.0, availableWidth);
  }
}
