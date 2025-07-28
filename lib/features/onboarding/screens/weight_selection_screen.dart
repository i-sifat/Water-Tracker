import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/features/onboarding/screens/exercise_frequency_screen.dart';

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool _isKg = true;
  double _weight = 65;
  final double _minWeight = 0;
  final double _maxWeight = 150;

  @override
  void initState() {
    super.initState();
    _loadSavedWeight();
  }

  Future<void> _loadSavedWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnit = prefs.getBool('weight_unit_is_kg') ?? true;
    final savedWeight = prefs.getDouble('user_weight') ?? 65.0;

    setState(() {
      _isKg = savedUnit;
      _weight = _clampWeight(savedWeight);
    });
  }

  double _convertKgToLbs(double kg) => kg * 2.20462;
  double _convertLbsToKg(double lbs) => lbs / 2.20462;

  double _clampWeight(double value) {
    return value.clamp(_minWeight, _maxWeight);
  }

  Future<void> _saveWeight() async {
    final prefs = await SharedPreferences.getInstance();
    // Always save the actual weight value in kg for consistency
    final weightToSave = _isKg ? _weight : _convertLbsToKg(_weight);
    await prefs.setDouble('user_weight', weightToSave);
    await prefs.setBool('weight_unit_is_kg', _isKg);
  }

  void _handleUnitChange(bool isKg) {
    if (_isKg == isKg) return;

    setState(() {
      // Convert the current weight to the new unit
      _weight = _isKg ? _convertKgToLbs(_weight) : _convertLbsToKg(_weight);
      _weight = _clampWeight(_weight);
      _isKg = isKg;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.onBoardingpagebackground,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.assessmentText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('Assessment', style: AppTypography.subtitle),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '5 of 10',
              style: TextStyle(
                color: AppColors.pageCounter,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "What's your current\nweight right now?",
                    style: AppTypography.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildUnitButton('kg', true),
                        const SizedBox(width: 8),
                        _buildUnitButton('lbs', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _weight.toStringAsFixed(1),
                        style: AppTypography.headline.copyWith(fontSize: 89),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isKg ? 'kg' : 'lbs',
                        style: AppTypography.subtitle.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Custom Ruler Picker
                  SizedBox(
                    height: 80,
                    child: CustomRulerPicker(
                      value: _weight,
                      minValue: _minWeight,
                      maxValue: _maxWeight,
                      onValueChanged: (value) {
                        setState(() => _weight = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: ContinueButton(
              onPressed: () async {
                await _saveWeight();
                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FitnessLevelScreen(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String unit, bool isKg) {
    final isSelected = _isKg == isKg;

    return GestureDetector(
      onTap: () => _handleUnitChange(isKg),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedBorder : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.assessmentText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class CustomRulerPicker extends StatefulWidget {

  const CustomRulerPicker({
    required this.value, required this.minValue, required this.maxValue, required this.onValueChanged, super.key,
  });
  final double value;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onValueChanged;

  @override
  State<CustomRulerPicker> createState() => _CustomRulerPickerState();
}

class _CustomRulerPickerState extends State<CustomRulerPicker> {
  late ScrollController _scrollController;
  final double _tickSpacing = 8; // Space between small ticks
  final double _ticksPerUnit = 10; // 10 small ticks per unit (0.1 precision)

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _valueToOffset(widget.value),
    );
  }

  @override
  void didUpdateWidget(CustomRulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _scrollController.animateTo(
        _valueToOffset(widget.value),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _valueToOffset(double value) {
    return (value - widget.minValue) * _ticksPerUnit * _tickSpacing;
  }

  double _offsetToValue(double offset) {
    final value = widget.minValue + (offset / (_ticksPerUnit * _tickSpacing));
    return double.parse(value.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    final totalTicks = ((widget.maxValue - widget.minValue) * _ticksPerUnit).toInt();
    final screenWidth = MediaQuery.of(context).size.width;
    final centerOffset = screenWidth / 2;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final offset = _scrollController.offset + centerOffset;
              final newValue = _offsetToValue(offset).clamp(widget.minValue, widget.maxValue);
              if (newValue != widget.value) {
                widget.onValueChanged(newValue);
              }
            }
            return true;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: totalTicks * _tickSpacing + screenWidth,
              child: CustomPaint(
                painter: RulerPainter(
                  minValue: widget.minValue,
                  maxValue: widget.maxValue,
                  tickSpacing: _tickSpacing,
                  ticksPerUnit: _ticksPerUnit,
                  centerOffset: centerOffset,
                  scrollOffset: _scrollController.hasClients ? _scrollController.offset : 0,
                  currentValue: widget.value,
                ),
                size: Size(totalTicks * _tickSpacing + screenWidth, 80),
              ),
            ),
          ),
        ),
        // Center indicator
        Positioned(
          left: centerOffset - 1,
          top: 0,
          child: Container(
            width: 2,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.selectedBorder,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}

class RulerPainter extends CustomPainter {

  RulerPainter({
    required this.minValue,
    required this.maxValue,
    required this.tickSpacing,
    required this.ticksPerUnit,
    required this.centerOffset,
    required this.scrollOffset,
    required this.currentValue,
  });
  final double minValue;
  final double maxValue;
  final double tickSpacing;
  final double ticksPerUnit;
  final double centerOffset;
  final double scrollOffset;
  final double currentValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final totalTicks = ((maxValue - minValue) * ticksPerUnit).toInt();
    final currentPosition = centerOffset + scrollOffset;

    for (var i = 0; i <= totalTicks; i++) {
      final x = centerOffset + (i * tickSpacing);
      final tickValue = minValue + (i / ticksPerUnit);
      final isBigTick = i % ticksPerUnit.toInt() == 0;
      
      // Determine tick color based on position relative to current selection
      final isPassed = x < currentPosition;
      paint.color = isPassed ? AppColors.selectedBorder : Colors.grey.shade400;

      if (isBigTick) {
        // Big tick (every unit)
        canvas.drawLine(
          Offset(x, size.height - 40),
          Offset(x, size.height),
          paint,
        );
        
        // Draw number labels for big ticks
        if (tickValue % 5 == 0) { // Show labels every 5 units to avoid crowding
          final textPainter = TextPainter(
            text: TextSpan(
              text: tickValue.toInt().toString(),
              style: TextStyle(
                color: isPassed ? AppColors.selectedBorder : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter..layout()
          ..paint(
            canvas,
            Offset(x - textPainter.width / 2, size.height - 35),
          );
        }
      } else {
        // Small tick (0.1 precision)
        canvas.drawLine(
          Offset(x, size.height - 20),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
