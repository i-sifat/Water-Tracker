import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';

/// Widget for selecting drink types with water drop icon and edit functionality
class DrinkTypeSelector extends StatefulWidget {
  const DrinkTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
    super.key,
  });

  /// Currently selected drink type
  final DrinkType selectedType;

  /// Callback when drink type is changed
  final void Function(DrinkType) onTypeChanged;

  @override
  State<DrinkTypeSelector> createState() => _DrinkTypeSelectorState();
}

class _DrinkTypeSelectorState extends State<DrinkTypeSelector> {
  /// Show drink type picker modal
  Future<void> _showDrinkTypePicker() async {
    final selectedType = await showModalBottomSheet<DrinkType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DrinkTypePickerModal(selectedType: widget.selectedType),
    );

    if (selectedType != null && selectedType != widget.selectedType) {
      widget.onTypeChanged(selectedType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: AccessibilityUtils.ensureMinTouchTarget(
        onTap: _showDrinkTypePicker,
        semanticLabel: AccessibilityUtils.createDrinkTypeSelectorLabel(
          widget.selectedType.displayName,
          widget.selectedType.waterContent,
        ),
        semanticHint: 'Double tap to open drink type selection menu',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.getSemanticColor('background', 'surfaceVariant'),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Drink type icon
              Semantics(
                excludeSemantics: true, // Icon is decorative
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.selectedType.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.selectedType.icon,
                    color: widget.selectedType.color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Drink type name
              Expanded(
                child: AccessibilityUtils.createAccessibleText(
                  text: widget.selectedType.displayName,
                  style: AppTypography.buttonLargeText.copyWith(
                    fontSize: 16,
                    color: AppColors.getSemanticColor('text', 'headline'),
                  ),
                ),
              ),

              // Water content indicator for non-water drinks
              if (widget.selectedType != DrinkType.water) ...[
                AccessibilityUtils.createAccessibleText(
                  text:
                      '${(widget.selectedType.waterContent * 100).round()}% water',
                  style: AppTypography.buttonSmallText.copyWith(
                    color: AppColors.getSemanticColor('text', 'subtitle'),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Edit icon
              Semantics(
                excludeSemantics: true, // Icon is decorative
                child: Icon(
                  Icons.edit,
                  color: AppColors.getSemanticColor('text', 'subtitle'),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal bottom sheet for selecting drink types
class DrinkTypePickerModal extends StatelessWidget {
  const DrinkTypePickerModal({required this.selectedType, super.key});

  /// Currently selected drink type
  final DrinkType selectedType;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Drink type selection menu',
      hint: 'Choose a drink type from the list',
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Semantics(
              excludeSemantics: true, // Decorative element
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  AccessibilityUtils.createAccessibleText(
                    text: 'Select Drink Type',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const Spacer(),
                  AccessibilityUtils.ensureMinTouchTarget(
                    onTap: () => Navigator.of(context).pop(),
                    semanticLabel: 'Close drink type selection',
                    semanticHint: 'Double tap to close this menu',
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Drink type options
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: DrinkType.values.length,
                itemBuilder: (context, index) {
                  final drinkType = DrinkType.values[index];
                  final isSelected = drinkType == selectedType;

                  return DrinkTypeOption(
                    drinkType: drinkType,
                    isSelected: isSelected,
                    onTap: () => Navigator.of(context).pop(drinkType),
                  );
                },
              ),
            ),

            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}

/// Individual drink type option in the picker
class DrinkTypeOption extends StatelessWidget {
  const DrinkTypeOption({
    required this.drinkType,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// The drink type for this option
  final DrinkType drinkType;

  /// Whether this option is currently selected
  final bool isSelected;

  /// Callback when option is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final waterPercentage = (drinkType.waterContent * 100).round();

    return AccessibilityUtils.ensureMinTouchTarget(
      onTap: onTap,
      semanticLabel:
          '${drinkType.displayName}, $waterPercentage% water content${isSelected ? ', currently selected' : ''}',
      semanticHint: 'Double tap to select this drink type',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? drinkType.color.withValues(alpha: 0.1)
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? drinkType.color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Drink type icon
            Semantics(
              excludeSemantics: true, // Icon is decorative
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: drinkType.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(drinkType.icon, color: drinkType.color, size: 24),
              ),
            ),
            const SizedBox(width: 16),

            // Drink type info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccessibilityUtils.createAccessibleText(
                    text: drinkType.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? drinkType.color : Colors.black87,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 2),
                  AccessibilityUtils.createAccessibleText(
                    text: '$waterPercentage% water content',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            Semantics(
              excludeSemantics: true, // Selection state is in main label
              child:
                  isSelected
                      ? Icon(
                        Icons.check_circle,
                        color: drinkType.color,
                        size: 24,
                      )
                      : Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.grey[400],
                        size: 24,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
