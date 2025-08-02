import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';
import 'package:watertracker/core/utils/app_colors.dart';

/// Goal breakdown page showing different factors contributing to daily hydration goal
class GoalBreakdownPage extends StatelessWidget {
  const GoalBreakdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build header with back button, title, and checkmark icon
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button
          AccessibilityUtils.ensureMinTouchTarget(
            onTap: () {
              // Handle back navigation
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
                text: 'Today',
                style: AppTypography.hydrationTitle.copyWith(
                  color: AppColors.textHeadline,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                semanticLabel: 'Today\'s goal breakdown',
              ),
            ),
          ),
          
          // Checkmark icon
          AccessibilityUtils.ensureMinTouchTarget(
            onTap: () {
              // Handle save/confirm
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
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Manual volume section
          _buildGoalSection(
            icon: Icons.flag,
            iconColor: AppColors.textSubtitle,
            title: 'Manual volume',
            subtitle: 'Tap to calculate',
            value: '3000 ml',
            onTap: () {
              // Handle manual volume calculation
            },
          ),
          
          const SizedBox(height: 16),
          
          // Lifestyle section
          _buildGoalSection(
            icon: Icons.info_outline,
            iconColor: AppColors.textSubtitle,
            title: 'Lifestyle',
            subtitle: 'Inactive',
            value: '0 ml',
            onTap: () {
              // Handle lifestyle settings
            },
          ),
          
          const SizedBox(height: 16),
          
          // Weather section
          _buildGoalSection(
            icon: Icons.wb_sunny,
            iconColor: Colors.amber,
            title: 'Weather',
            subtitle: 'Normal',
            value: '0 ml',
            onTap: () {
              // Handle weather settings
            },
          ),
          
          const Spacer(),
          
          // Total section
          _buildTotalSection(),
        ],
      ),
    );
  }

  /// Build individual goal section
  Widget _buildGoalSection({
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
            width: 1,
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
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
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
                Icon(
                  Icons.edit,
                  color: AppColors.textSubtitle,
                  size: 20,
                ),
                const SizedBox(width: 8),
                AccessibilityUtils.createAccessibleText(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build total section at the bottom
  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            color: AppColors.textSubtitle,
            size: 20,
          ),
          const SizedBox(width: 8),
          AccessibilityUtils.createAccessibleText(
            text: '3000 ml',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
              decoration: TextDecoration.underline,
              decorationThickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}
