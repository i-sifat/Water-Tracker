import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/domain/models/water_history.dart';

class WeekSelector extends StatelessWidget {
  const WeekSelector({
    required this.weeks,
    required this.selectedWeek,
    required this.onWeekSelected,
    super.key,
  });
  
  final List<WeeklyWaterData> weeks;
  final int selectedWeek;
  final ValueChanged<int> onWeekSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weeks.length,
        itemBuilder: (context, index) {
          final week = weeks[index];
          final isSelected = week.weekNumber == selectedWeek;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _WeekButton(
              weekNumber: week.weekNumber,
              isSelected: isSelected,
              onTap: () => onWeekSelected(week.weekNumber),
            ),
          );
        },
      ),
    );
  }
}

class _WeekButton extends StatelessWidget {
  const _WeekButton({
    required this.weekNumber,
    required this.isSelected,
    required this.onTap,
  });
  
  final int weekNumber;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.darkBlue,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'week $weekNumber',
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}