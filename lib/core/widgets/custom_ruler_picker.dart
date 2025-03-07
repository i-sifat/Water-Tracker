import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:watertracker/utils/app_colors.dart';

class CustomRulerPicker extends StatefulWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onValueChanged;
  final bool isKg;

  const CustomRulerPicker({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onValueChanged,
    required this.isKg,
  });

  @override
  State<CustomRulerPicker> createState() => _CustomRulerPickerState();
}

class _CustomRulerPickerState extends State<CustomRulerPicker> {
  late ScrollController _scrollController;
  final double _itemExtent = 17.0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    // Calculate initial scroll position based on precise value
    final initialOffset = (widget.value - widget.minValue) * _itemExtent;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isScrolling) _isScrolling = true;

    // Snap to nearest integer value for lbs, 1 decimal for kg
    final rawIndex = _scrollController.offset / _itemExtent;
    final snappedIndex = widget.isKg ? rawIndex : rawIndex.roundToDouble();
    final newValue = (widget.minValue + snappedIndex).clamp(
      widget.minValue,
      widget.maxValue,
    );

    if (newValue != widget.value) {
      widget.onValueChanged(newValue);
      _provideHapticFeedback();
    }

    // Magnetic snap when scrolling ends
    if (!_scrollController.position.isScrollingNotifier.value) {
      _isScrolling = false;
      final targetOffset = (newValue - widget.minValue) * _itemExtent;
      if (_scrollController.offset != targetOffset) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  Future<void> _provideHapticFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 20, amplitude: 40);
    } else {
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure integer values for lbs, decimal for kg
    final adjustedMin =
        widget.isKg ? widget.minValue : widget.minValue.roundToDouble();
    final adjustedMax =
        widget.isKg ? widget.maxValue : widget.maxValue.roundToDouble();
    final totalItems = (adjustedMax - adjustedMin).round() + 1;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Center indicator line
        Container(
          width: 4,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        SizedBox(
          height: 160,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white,
                  Colors.white,
                  Colors.white.withOpacity(0.1),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemExtent: _itemExtent,
              itemCount: totalItems,
              itemBuilder: (context, index) {
                final value = adjustedMin + index;
                final isSelected =
                    (value - widget.value).abs() < (widget.isKg ? 0.05 : 0.5);
                final showNumber =
                    widget.isKg ? value % 5 == 0 : value % 10 == 0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 2,
                      height: showNumber ? 80 : (value % 1 == 0 ? 60 : 40),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.lightBlue
                                : Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    if (showNumber) ...[const SizedBox(height: 8)],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
