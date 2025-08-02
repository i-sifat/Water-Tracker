import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_data.dart';
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

  /// Button configurations with amounts and colors
  static const Map<int, Color> _buttonConfigs = {
    500: Color(0xFFB39DDB), // Purple
    250: Color(0xFF81D4FA), // Light Blue
    400: Color(0xFFA5D6A7), // Light Green
    100: Color(0xFFFFF59D), // Light Yellow
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
              return QuickAddButton(
                amount: entry.key,
                color: entry.value,
                selectedDrinkType: selectedDrinkType,
                onPressed: () => _handleButtonPress(context, entry.key),
              );
            }).toList(),
      ),
    );
  }

  /// Handle button press and add hydration
  Future<void> _handleButtonPress(BuildContext context, int amount) async {
    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      await provider.addHydration(
        amount,
        type: selectedDrinkType,
        context: context,
      );
      onAmountAdded?.call();
    } catch (e) {
      // Error handling is managed by the provider
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

    _colorAnimation = ColorTween(
      begin: widget.color,
      end: _darkenColor(widget.color, 0.1),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _handlePress(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.amount} ml',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  if (widget.selectedDrinkType != DrinkType.water) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getWaterContentText(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ],
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
