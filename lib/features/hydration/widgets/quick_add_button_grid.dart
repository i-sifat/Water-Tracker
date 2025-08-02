import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/app_error.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

/// A 2x2 grid of quick add buttons for common hydration amounts
class QuickAddButtonGrid extends StatelessWidget {
  const QuickAddButtonGrid({
    super.key,
    this.onAmountAdded,
    this.selectedDrinkType = DrinkType.water,
  });

  /// Callback when an amount is successfully added
  final VoidCallback? onAmountAdded;

  /// Currently selected drink type for water content calculation
  final DrinkType selectedDrinkType;

  /// Button configurations with amounts and colors - Updated to match design mockup
  static const Map<int, Color> _buttonConfigs = {
    500: AppColors.box1, // Purple
    250: AppColors.box2, // Light Blue
    400: AppColors.box3, // Light Green
    100: AppColors.box4, // Light Yellow
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children:
            _buttonConfigs.entries.map((entry) {
              // Performance optimization: RepaintBoundary around each button
              return RepaintBoundary(
                child: QuickAddButton(
                  amount: entry.key,
                  color: entry.value,
                  selectedDrinkType: selectedDrinkType,
                  onPressed: () => _handleButtonPress(context, entry.key),
                ),
              );
            }).toList(),
      ),
    );
  }

  /// Handle button press and add hydration with comprehensive error handling
  Future<void> _handleButtonPress(BuildContext context, int amount) async {
    if (!context.mounted) return;

    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);

      // Show loading state briefly
      await provider.addHydration(
        amount,
        type: selectedDrinkType,
        context: context.mounted ? context : null,
      );

      if (!context.mounted) return;

      // Announce hydration addition to screen readers
      AccessibilityUtils.announceHydrationAdded(
        context,
        amount,
        selectedDrinkType.displayName,
      );

      // Provide haptic feedback for accessibility
      await AccessibilityUtils.provideAccessibilityFeedback();

      onAmountAdded?.call();
    } catch (e) {
      if (!context.mounted) return;

      // Show user-friendly error message
      var errorMessage = 'Failed to add hydration';

      if (e is ValidationError) {
        errorMessage = e.userMessage;
      } else if (e is StorageError) {
        errorMessage = 'Failed to save hydration data. Please try again.';
      } else if (e is NetworkError) {
        errorMessage = 'No internet connection. Data will be saved locally.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _handleButtonPress(context, amount),
          ),
        ),
      );

      debugPrint('Failed to add hydration: $e');
    }
  }
}

/// Individual quick add button widget
class QuickAddButton extends StatefulWidget {
  const QuickAddButton({
    required this.amount,
    required this.color,
    required this.onPressed,
    super.key,
    this.selectedDrinkType = DrinkType.water,
  });

  /// Amount in milliliters
  final int amount;

  /// Button background color
  final Color color;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Currently selected drink type for water content calculation
  final DrinkType selectedDrinkType;

  @override
  State<QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<QuickAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  // Performance optimization: Cache darkened color
  Color? _cachedDarkenedColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Performance optimization: Cache darkened color calculation
    _cachedDarkenedColor = _darkenColor(widget.color, 0.1);
    _colorAnimation = ColorTween(
      begin: widget.color,
      end: _cachedDarkenedColor,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Performance optimization: Proper animation controller disposal
    _animationController.dispose();
    _cachedDarkenedColor = null;
    super.dispose();
  }

  /// Darken a color by a given factor
  Color _darkenColor(Color color, double factor) {
    return Color.fromRGBO(
      ((color.r * 255.0).round() * (1 - factor)).round(),
      ((color.g * 255.0).round() * (1 - factor)).round(),
      ((color.b * 255.0).round() * (1 - factor)).round(),
      color.a,
    );
  }

  /// Handle button press with animation
  Future<void> _handlePress() async {
    await _animationController.forward();
    widget.onPressed();
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AccessibilityUtils.createAccessibleButton(
          semanticLabel: AccessibilityUtils.createQuickAddButtonLabel(
            widget.amount,
            widget.selectedDrinkType.displayName,
          ),
          semanticHint: 'Double tap to add this amount to your hydration log',
          onPressed: _handlePress,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _handlePress(),
              onTapCancel: () => _animationController.reverse(),
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: AccessibilityUtils.minTouchTargetSize,
                  minHeight: AccessibilityUtils.minTouchTargetSize,
                ),
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Increased for better design
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.15,
                      ), // Slightly more prominent shadow
                      blurRadius: 8, // Increased blur for softer shadow
                      offset: const Offset(0, 4), // Increased offset for depth
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.05,
                      ), // Additional subtle shadow
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AccessibilityUtils.createAccessibleText(
                      text: '${widget.amount} ml',
                      style: AppTypography.buttonLargeText,
                    ),
                    if (widget.selectedDrinkType != DrinkType.water) ...[
                      const SizedBox(height: 4),
                      AccessibilityUtils.createAccessibleText(
                        text: _getWaterContentText(),
                        style: AppTypography.buttonSmallText,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Get water content text for non-water drinks
  String _getWaterContentText() {
    final waterContent =
        (widget.amount * widget.selectedDrinkType.waterContent).round();
    return '${waterContent}ml water';
  }
}
