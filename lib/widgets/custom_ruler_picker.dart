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
  final double _itemExtent = 15; // Reduced spacing between marks
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.value.round() - widget.minValue.round();
    _scrollController = ScrollController(
      initialScrollOffset: _selectedIndex * _itemExtent,
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final newIndex = (_scrollController.offset / _itemExtent).round();
    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
        final newValue = (widget.minValue + _selectedIndex).clamp(
          widget.minValue,
          widget.maxValue,
        );
        widget.onValueChanged(newValue);
        _provideHapticFeedback();
      });
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
    final totalItems = (widget.maxValue - widget.minValue).round() + 1;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Center indicator line
        Container(
          width: 10,
          height: 130,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        SizedBox(
          height: 120,
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
                final value = widget.minValue + index;
                final isSelected = index == _selectedIndex;
                final showNumber = value % (widget.isKg ? 5 : 10) == 0;
                final isHalfMark = value % (widget.isKg ? 1 : 2) == 0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 2,
                      height: showNumber ? 50 : (isHalfMark ? 35 : 15),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.lightBlue
                                : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    if (showNumber) ...[
                      const SizedBox(height: 8),
                      Text(
                        value.round().toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? AppColors.lightBlue
                                  : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
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
