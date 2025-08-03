import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/widgets/text/calculation_text_display.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

/// Goal breakdown page showing different factors contributing to daily hydration goal
class GoalBreakdownPage extends StatelessWidget {
  const GoalBreakdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, hydrationProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildContent(context, hydrationProvider)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build header with back button, title, and checkmark icon
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back button
          AccessibilityUtils.ensureMinTouchTarget(
            onTap: () {
              Navigator.of(context).pop();
            },
            semanticLabel: 'Go back',
            semanticHint: 'Double tap to go back',
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textHeadline,
              size: 24,
            ),
          ),

          // Title
          Expanded(
            child: Center(
              child: AccessibilityUtils.createAccessibleText(
                text: 'Goal Breakdown',
                style: AppTypography.hydrationTitle.copyWith(
                  color: AppColors.textHeadline,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                semanticLabel: 'Goal breakdown',
              ),
            ),
          ),

          // Checkmark icon
          AccessibilityUtils.ensureMinTouchTarget(
            onTap: () {
              Navigator.of(context).pop();
            },
            semanticLabel: 'Save or confirm changes',
            semanticHint: 'Double tap to save changes',
            child: const Icon(
              Icons.check,
              color: AppColors.textHeadline,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// Build main content with goal breakdown sections
  Widget _buildContent(
    BuildContext context,
    HydrationProvider hydrationProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Manual volume section
          _buildGoalSection(
            context: context,
            icon: Icons.flag,
            iconColor: AppColors.textSubtitle,
            title: 'Manual volume',
            subtitle: 'Tap to change',
            value: '${hydrationProvider.dailyGoal} ml',
            onTap: () {
              _navigateToGoalSelection(context);
            },
          ),

          const SizedBox(height: 12),

          // Lifestyle section
          _buildGoalSection(
            context: context,
            icon: Icons.info_outline,
            iconColor: AppColors.textSubtitle,
            title: 'Lifestyle',
            subtitle: 'Inactive',
            value: '0 ml',
            onTap: () {
              // Handle lifestyle settings
            },
          ),

          const SizedBox(height: 12),

          // Weather section
          _buildGoalSection(
            context: context,
            icon: Icons.wb_sunny,
            iconColor: Colors.amber,
            title: 'Weather',
            subtitle: 'Normal',
            value: '0 ml',
            onTap: () {
              // Handle weather settings
            },
          ),

          const SizedBox(height: 20),

          // Total section
          _buildTotalSection(hydrationProvider),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build individual goal section
  Widget _buildGoalSection({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return AccessibilityUtils.ensureMinTouchTarget(
      onTap: onTap,
      semanticLabel: 'Edit $title',
      semanticHint: 'Double tap to edit $title',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textSubtitle.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),

            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccessibilityUtils.createAccessibleText(
                    text: title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AccessibilityUtils.createAccessibleText(
                    text: subtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSubtitle,
                    ),
                  ),
                ],
              ),
            ),

            // Edit icon and value
            Row(
              children: [
                const Icon(Icons.edit, color: AppColors.textSubtitle, size: 20),
                const SizedBox(width: 8),
                CalculationTextDisplay(
                  value: value.replaceAll(' ml', ''),
                  unit: 'ml',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                  ),
                  animationDuration: const Duration(milliseconds: 400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build total section at the bottom
  Widget _buildTotalSection(HydrationProvider hydrationProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.getSemanticColor('background', 'primary'),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Daily Goal:',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textHeadline,
            ),
          ),
          VolumeDisplay(
            volumeInMl: hydrationProvider.dailyGoal,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
            preferLiters: false,
            animationDuration: const Duration(milliseconds: 500),
          ),
        ],
      ),
    );
  }

  /// Navigate to goal selection screen
  void _navigateToGoalSelection(BuildContext context) {
    _showCustomGoalDialog(context);
  }

  /// Show custom goal input dialog
  void _showCustomGoalDialog(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(
      context,
      listen: false,
    );
    final controller = TextEditingController();
    bool useMetric = true; // true for liters, false for fl oz

    showDialog<void>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text(
                    'Update Daily Goal',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter your daily water goal',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.textSubtitle,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Unit toggle
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.checkBoxCircle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.textSubtitle.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // L button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    useMetric = true;
                                  });
                                },
                                borderRadius: BorderRadius.circular(7),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        useMetric
                                            ? AppColors.lightBlue
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    'L',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w600,
                                      color:
                                          useMetric
                                              ? Colors.white
                                              : AppColors.textHeadline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // FL OZ button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    useMetric = false;
                                  });
                                },
                                borderRadius: BorderRadius.circular(7),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        !useMetric
                                            ? AppColors.lightBlue
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    'FL OZ',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w600,
                                      color:
                                          !useMetric
                                              ? Colors.white
                                              : AppColors.textHeadline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixText: useMetric ? 'L' : 'FL OZ',
                          hintText: useMetric ? '2.0' : '68',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSubtitle),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final value = double.tryParse(controller.text);
                        if (value != null && value > 0) {
                          // Convert to milliliters
                          final goalInMilliliters =
                              useMetric
                                  ? (value * 1000).round()
                                  : (value * 29.5735)
                                      .round(); // FL OZ to ml conversion

                          try {
                            debugPrint(
                              'Setting daily goal to: $goalInMilliliters ml',
                            );
                            await hydrationProvider.setDailyGoal(
                              goalInMilliliters,
                            );
                            debugPrint(
                              'Goal set successfully. New goal: ${hydrationProvider.dailyGoal} ml',
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Daily goal updated to ${goalInMilliliters}ml',
                                  ),
                                  backgroundColor: AppColors.lightBlue,
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint('Failed to set daily goal: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update goal: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }
}
