import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/design_system/design_system.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool _isKg = true;
  double _weight = 65;
  final double _minWeight = 0;
  final double _maxWeightKg = 150;
  final double _maxWeightLbs = 330; // 150 kg * 2.20462

  @override
  void initState() {
    super.initState();
  }

  double _convertKgToLbs(double kg) => kg * 2.20462;
  double _convertLbsToKg(double lbs) => lbs / 2.20462;

  void _handleUnitChange(bool isKg) {
    if (_isKg == isKg) return;

    setState(() {
      if (_isKg) {
        // Converting from kg to lbs
        _weight = _convertKgToLbs(_weight);
        // Clamp to lbs range
        _weight = _weight.clamp(_minWeight, _maxWeightLbs);
      } else {
        // Converting from lbs to kg
        _weight = _convertLbsToKg(_weight);
        // Clamp to kg range
        _weight = _weight.clamp(_minWeight, _maxWeightKg);
      }
      _isKg = isKg;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    final weightToSave = _isKg ? _weight : _convertLbsToKg(_weight);
    provider.updateWeight(weightToSave);
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: "What's your current\nweight right now?",
          backgroundColor: AppColors.onboardingBackground,
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            horizontal: 24,
            vertical: 40,
          ).copyWith(bottom: 24),
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 50)),

              // Unit selection buttons
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.weightUnitUnselected,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(context, 28),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildUnitButton('kg', true)),
                    SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 8)),
                    Expanded(child: _buildUnitButton('lbs', false)),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 60)),

              // Weight display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _weight.toInt().toString(),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 89),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 4)),
                  Text(
                    _isKg ? 'kg' : 'lbs',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSubtitle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 40)),

              // Custom Ruler Picker - removed number reading
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 80),
                child: CustomRulerPicker(
                  value: _weight,
                  minValue: _minWeight,
                  maxValue: _isKg ? _maxWeightKg : _maxWeightLbs,
                  onValueChanged: (value) {
                    setState(() => _weight = value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitButton(String unit, bool isKg) {
    final isSelected = _isKg == isKg;

    return GestureDetector(
      onTap: () => _handleUnitChange(isKg),
      child: Container(
        padding: ResponsiveHelper.getResponsivePadding(context, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.weightUnitSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(context, 24),
          ),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? AppColors.weightUnitTextSelected : AppColors.weightUnitTextUnselected,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
class C
ustomRulerPicker extends StatefulWidget {
  const CustomRulerPicker({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onValueChanged,
    super.key,
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
  late double _tickSpacing;
  final double _ticksPerUnit = 10;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _valueToOffset(widget.value),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Make tick spacing responsive
    _tickSpacing = ResponsiveHelper.getResponsiveWidth(context, 8);
  }

  @override
  void didUpdateWidget(CustomRulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isDragging) {
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
    return (value * 10).round() / 10.0;
  }

  @override
  Widget build(BuildContext context) {
    final totalTicks = ((widget.maxValue - widget.minValue) * _ticksPerUnit).toInt();
    final screenWidth = MediaQuery.of(context).size.width;
    final centerOffset = screenWidth / 2;
    final rulerHeight = ResponsiveHelper.getResponsiveHeight(context, 80);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              _isDragging = true;
            } else if (notification is ScrollEndNotification) {
              _isDragging = false;
            } else if (notification is ScrollUpdateNotification && _isDragging) {
              final offset = _scrollController.offset + centerOffset;
              final newValue = _offsetToValue(offset).clamp(widget.minValue, widget.maxValue);
              if ((newValue - widget.value).abs() >= 0.1) {
                widget.onValueChanged(newValue);
              }
            }
            return true;
          },
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (_scrollController.hasClients) {
                final newOffset = _scrollController.offset + details.delta.dx;
                final clampedOffset = newOffset.clamp(
                  0.0,
                  _scrollController.position.maxScrollExtent,
                );
                _scrollController.jumpTo(clampedOffset);
                
                final offset = clampedOffset + centerOffset;
                final newValue = _offsetToValue(offset).clamp(widget.minValue, widget.maxValue);
                if ((newValue - widget.value).abs() >= 0.1) {
                  widget.onValueChanged(newValue);
                }
              }
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
                    context: context,
                  ),
                  size: Size(totalTicks * _tickSpacing + screenWidth, rulerHeight),
                ),
              ),
            ),
          ),
        ),
        // Center indicator
        Positioned(
          left: centerOffset - ResponsiveHelper.getResponsiveWidth(context, 1),
          top: 0,
          child: Container(
            width: ResponsiveHelper.getResponsiveWidth(context, 2),
            height: rulerHeight,
            decoration: BoxDecoration(
              color: AppColors.lightPurple,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveBorderRadius(context, 1),
              ),
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
    required this.context,
  });
  final double minValue;
  final double maxValue;
  final double tickSpacing;
  final double ticksPerUnit;
  final double centerOffset;
  final double scrollOffset;
  final double currentValue;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = ResponsiveHelper.getResponsiveWidth(context, 1.5)
      ..strokeCap = StrokeCap.round;

    final totalTicks = ((maxValue - minValue) * ticksPerUnit).toInt();
    final currentPosition = centerOffset + scrollOffset;
    final bigTickHeight = ResponsiveHelper.getResponsiveHeight(context, 40);
    final smallTickHeight = ResponsiveHelper.getResponsiveHeight(context, 20);

    for (var i = 0; i <= totalTicks; i++) {
      final x = centerOffset + (i * tickSpacing);
      final isBigTick = i % ticksPerUnit.toInt() == 0;

      // Determine tick color based on position relative to current selection
      final isPassed = x < currentPosition;
      paint.color = isPassed ? AppColors.lightPurple : Colors.grey.shade400;

      if (isBigTick) {
        // Big tick (every unit)
        canvas.drawLine(
          Offset(x, size.height - bigTickHeight),
          Offset(x, size.height),
          paint,
        );
      } else {
        // Small tick (0.1 precision)
        canvas.drawLine(
          Offset(x, size.height - smallTickHeight),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}