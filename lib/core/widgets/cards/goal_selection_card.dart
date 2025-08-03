import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/widgets/cards/base_selection_card.dart';

class GoalSelectionCard extends BaseSelectionCard {
  const GoalSelectionCard({
    required this.title,
    required super.onTap,
    required super.isSelected,
    required this.icon,
    required this.iconBackgroundColor,
    super.key,
  });

  final String title;
  final Widget icon;
  final Color iconBackgroundColor;

  @override
  Widget buildContent(BuildContext context) {
    return Row(
      children: [
        // Icon container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(child: icon),
        ),
        const SizedBox(width: 16),
        // Title text
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textHeadline,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        // Selection indicator
        SelectionIndicator(isSelected: isSelected),
      ],
    );
  }
}
