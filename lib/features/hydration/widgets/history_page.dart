import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

/// History page showing daily hydration intake entries
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildHydrationList(provider)),
                _buildFloatingActionButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build header with back button, title, and filter icon
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
                semanticLabel: "Today's hydration history",
              ),
            ),
          ),

          // Filter icon
          AccessibilityUtils.ensureMinTouchTarget(
            onTap: () {
              // Handle filter/sort
            },
            semanticLabel: 'Filter or sort entries',
            semanticHint: 'Double tap to filter or sort hydration entries',
            child: const Icon(
              Icons.filter_list,
              color: AppColors.textHeadline,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the list of hydration entries
  Widget _buildHydrationList(HydrationProvider provider) {
    final todaysEntries = provider.todaysEntries;

    if (todaysEntries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: todaysEntries.length,
      separatorBuilder:
          (context, index) => Divider(
            color: AppColors.getSemanticColor('background', 'primary'),
            height: 1,
            thickness: 1,
          ),
      itemBuilder: (context, index) {
        final entry = todaysEntries[index];
        return _buildHydrationEntry(entry);
      },
    );
  }

  /// Build individual hydration entry
  Widget _buildHydrationEntry(HydrationData entry) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Drink icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.waterFull,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDrinkIcon(entry.type),
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Amount text
          Expanded(
            child: AccessibilityUtils.createAccessibleText(
              text: _formatAmount(entry.waterContent),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
              ),
            ),
          ),

          // Time
          AccessibilityUtils.createAccessibleText(
            text: _formatTime(entry.timestamp),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textHeadline,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no entries
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 64,
            color: AppColors.textSubtitle.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          AccessibilityUtils.createAccessibleText(
            text: 'No hydration entries yet',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSubtitle,
            ),
          ),
          const SizedBox(height: 8),
          AccessibilityUtils.createAccessibleText(
            text: 'Add your first drink to start tracking',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSubtitle,
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AccessibilityUtils.ensureMinTouchTarget(
        onTap: () {
          // Handle add hydration
        },
        semanticLabel: 'Add hydration entry',
        semanticHint: 'Double tap to add a new hydration entry',
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.waterFull,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.waterFull.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  /// Get appropriate icon for drink type
  IconData _getDrinkIcon(DrinkType type) {
    switch (type) {
      case DrinkType.water:
        return Icons.water_drop;
      case DrinkType.coffee:
        return Icons.coffee;
      case DrinkType.tea:
        return Icons.local_cafe;
      case DrinkType.juice:
        return Icons.local_drink;
      case DrinkType.soda:
        return Icons.local_bar;
      case DrinkType.sports:
        return Icons.sports_bar;
      case DrinkType.other:
        return Icons.local_drink;
    }
  }

  /// Format amount for display
  String _formatAmount(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)} L';
    } else {
      return '$amount ml';
    }
  }

  /// Format time for display
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
