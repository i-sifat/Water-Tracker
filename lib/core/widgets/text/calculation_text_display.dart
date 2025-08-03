import 'package:flutter/material.dart';
import 'package:watertracker/core/widgets/animations/smooth_text_transition.dart';

/// Specialized text widget for calculation displays that prevents text disappearing
/// and provides smooth transitions for value updates
class CalculationTextDisplay extends StatefulWidget {
  const CalculationTextDisplay({
    required this.value,
    required this.style,
    super.key,
    this.label,
    this.unit,
    this.prefix,
    this.suffix,
    this.textAlign = TextAlign.center,
    this.animationDuration = const Duration(milliseconds: 400),
    this.slideDistance = 25.0,
    this.semanticLabel,
  });

  /// The main value to display (e.g., "2.5", "85%", "1500")
  final String value;

  /// Text style for the main value
  final TextStyle style;

  /// Optional label above the value (e.g., "Daily Goal", "Progress")
  final String? label;

  /// Optional unit after the value (e.g., "L", "ml", "%")
  final String? unit;

  /// Optional prefix before the value (e.g., "$", "+")
  final String? prefix;

  /// Optional suffix after the value (e.g., "remaining", "completed")
  final String? suffix;

  /// Text alignment
  final TextAlign textAlign;

  /// Animation duration for transitions
  final Duration animationDuration;

  /// Distance for slide animation
  final double slideDistance;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  State<CalculationTextDisplay> createState() => _CalculationTextDisplayState();
}

class _CalculationTextDisplayState extends State<CalculationTextDisplay> {
  // Use keys to prevent unnecessary rebuilds of text widgets
  late Key _valueKey;
  late Key _labelKey;
  late Key _unitKey;

  @override
  void initState() {
    super.initState();
    _updateKeys();
  }

  @override
  void didUpdateWidget(CalculationTextDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update keys only when content actually changes
    if (oldWidget.value != widget.value ||
        oldWidget.label != widget.label ||
        oldWidget.unit != widget.unit) {
      _updateKeys();
    }
  }

  void _updateKeys() {
    _valueKey = ValueKey('value_${widget.value}');
    _labelKey = ValueKey('label_${widget.label}');
    _unitKey = ValueKey('unit_${widget.unit}');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? _buildSemanticLabel(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label (if provided)
          if (widget.label != null) ...[
            SmoothTextTransition(
              key: _labelKey,
              text: widget.label!,
              style: widget.style.copyWith(
                fontSize: (widget.style.fontSize ?? 16) * 0.7,
                fontWeight: FontWeight.w400,
                color: widget.style.color?.withOpacity(0.7),
              ),
              textAlign: widget.textAlign,
              duration: widget.animationDuration,
              slideDistance: widget.slideDistance * 0.5,
            ),
            const SizedBox(height: 4),
          ],

          // Main value with prefix/suffix
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Prefix
              if (widget.prefix != null)
                Text(
                  widget.prefix!,
                  style: widget.style.copyWith(
                    fontSize: (widget.style.fontSize ?? 16) * 0.8,
                  ),
                ),

              // Main value with smooth transition
              SmoothTextTransition(
                key: _valueKey,
                text: widget.value,
                style: widget.style,
                textAlign: widget.textAlign,
                duration: widget.animationDuration,
                slideDistance: widget.slideDistance,
              ),

              // Unit
              if (widget.unit != null) ...[
                const SizedBox(width: 2),
                SmoothTextTransition(
                  key: _unitKey,
                  text: widget.unit!,
                  style: widget.style.copyWith(
                    fontSize: (widget.style.fontSize ?? 16) * 0.8,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: widget.textAlign,
                  duration: widget.animationDuration,
                  slideDistance: widget.slideDistance * 0.3,
                ),
              ],
            ],
          ),

          // Suffix (if provided)
          if (widget.suffix != null) ...[
            const SizedBox(height: 2),
            SmoothTextTransition(
              text: widget.suffix!,
              style: widget.style.copyWith(
                fontSize: (widget.style.fontSize ?? 16) * 0.7,
                fontWeight: FontWeight.w400,
                color: widget.style.color?.withOpacity(0.7),
              ),
              textAlign: widget.textAlign,
              duration: widget.animationDuration,
              slideDistance: widget.slideDistance * 0.5,
            ),
          ],
        ],
      ),
    );
  }

  String _buildSemanticLabel() {
    final parts = <String>[];

    if (widget.label != null) {
      parts.add(widget.label!);
    }

    if (widget.prefix != null) {
      parts.add(widget.prefix!);
    }

    parts.add(widget.value);

    if (widget.unit != null) {
      parts.add(widget.unit!);
    }

    if (widget.suffix != null) {
      parts.add(widget.suffix!);
    }

    return parts.join(' ');
  }
}

/// Specialized widget for percentage displays with smooth animations
class PercentageDisplay extends StatelessWidget {
  const PercentageDisplay({
    required this.percentage,
    required this.style,
    super.key,
    this.label,
    this.showPercentSign = true,
    this.decimalPlaces = 0,
    this.textAlign = TextAlign.center,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  /// Percentage value (0.0 to 1.0)
  final double percentage;

  /// Text style
  final TextStyle style;

  /// Optional label
  final String? label;

  /// Whether to show the % sign
  final bool showPercentSign;

  /// Number of decimal places to show
  final int decimalPlaces;

  /// Text alignment
  final TextAlign textAlign;

  /// Animation duration
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final percentValue = (percentage * 100).toStringAsFixed(decimalPlaces);

    return CalculationTextDisplay(
      value: percentValue,
      style: style,
      label: label,
      unit: showPercentSign ? '%' : null,
      textAlign: textAlign,
      animationDuration: animationDuration,
      semanticLabel: '$percentValue percent${label != null ? ' $label' : ''}',
    );
  }
}

/// Specialized widget for volume displays (ml/L) with smooth animations
class VolumeDisplay extends StatelessWidget {
  const VolumeDisplay({
    required this.volumeInMl,
    required this.style,
    super.key,
    this.label,
    this.preferLiters = true,
    this.textAlign = TextAlign.center,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  /// Volume in milliliters
  final int volumeInMl;

  /// Text style
  final TextStyle style;

  /// Optional label
  final String? label;

  /// Whether to prefer liters over ml for display
  final bool preferLiters;

  /// Text alignment
  final TextAlign textAlign;

  /// Animation duration
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    String value;
    String unit;

    if (preferLiters && volumeInMl >= 1000) {
      value = (volumeInMl / 1000).toStringAsFixed(1);
      unit = 'L';
    } else {
      value = volumeInMl.toString();
      unit = 'ml';
    }

    return CalculationTextDisplay(
      value: value,
      style: style,
      label: label,
      unit: unit,
      textAlign: textAlign,
      animationDuration: animationDuration,
      semanticLabel: '$value $unit${label != null ? ' $label' : ''}',
    );
  }
}
