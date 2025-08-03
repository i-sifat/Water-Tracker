import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';

/// Base class for selection cards to eliminate duplicate styling and behavior
abstract class BaseSelectionCard extends StatelessWidget {
  const BaseSelectionCard({
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final bool isSelected;
  final VoidCallback onTap;

  /// Subclasses must implement this to provide the card content
  Widget buildContent(BuildContext context);

  /// Subclasses can override this to customize the container decoration
  BoxDecoration getDecoration(BuildContext context) {
    return BoxDecoration(
      color: getBackgroundColor(context),
      borderRadius: BorderRadius.circular(16),
      border: getBorder(context),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Subclasses can override this to customize the background color
  Color getBackgroundColor(BuildContext context) {
    return Colors.white;
  }

  /// Subclasses can override this to customize the border
  Border? getBorder(BuildContext context) {
    return isSelected ? Border.all(color: AppColors.primary, width: 2) : null;
  }

  /// Subclasses can override this to customize the padding
  EdgeInsets getPadding(BuildContext context) {
    return const EdgeInsets.all(16);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: getPadding(context),
        decoration: getDecoration(context),
        child: buildContent(context),
      ),
    );
  }
}

/// Utility widget for creating consistent selection indicators
class SelectionIndicator extends StatelessWidget {
  const SelectionIndicator({
    required this.isSelected,
    super.key,
    this.size = 24,
  });

  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.unselectedBorder,
          width: 2,
        ),
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      child:
          isSelected
              ? const Center(
                child: Icon(Icons.check, size: 16, color: Colors.white),
              )
              : null,
    );
  }
}
