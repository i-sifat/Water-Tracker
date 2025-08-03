import 'package:flutter/material.dart';

/// Advanced text transition widget with customizable animation curves and timing
/// Provides smooth slide-in from right and fade-out upward animations
class AdvancedTextTransition extends StatefulWidget {
  const AdvancedTextTransition({
    required this.text,
    required this.style,
    super.key,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
    this.duration = const Duration(milliseconds: 400),
    this.slideInDistance = 30.0,
    this.slideOutDistance = 20.0,
    this.slideInCurve = Curves.easeOutCubic,
    this.slideOutCurve = Curves.easeInCubic,
    this.fadeInCurve = Curves.easeIn,
    this.fadeOutCurve = Curves.easeOut,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.semanticLabel,
  });

  /// The text to display
  final String text;

  /// Text style to apply
  final TextStyle style;

  /// Text alignment
  final TextAlign textAlign;

  /// Maximum number of lines
  final int? maxLines;

  /// Text overflow behavior
  final TextOverflow? overflow;

  /// Animation duration
  final Duration duration;

  /// Distance for slide-in animation (from right)
  final double slideInDistance;

  /// Distance for slide-out animation (upward)
  final double slideOutDistance;

  /// Curve for slide-in animation
  final Curve slideInCurve;

  /// Curve for slide-out animation
  final Curve slideOutCurve;

  /// Curve for fade-in animation
  final Curve fadeInCurve;

  /// Curve for fade-out animation
  final Curve fadeOutCurve;

  /// Delay between fade-out and fade-in animations
  final Duration staggerDelay;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  State<AdvancedTextTransition> createState() => _AdvancedTextTransitionState();
}

class _AdvancedTextTransitionState extends State<AdvancedTextTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeOutAnimation;
  late Animation<double> _slideOutAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideInAnimation;

  String _currentText = '';
  String _previousText = '';
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentText = widget.text;
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Calculate timing intervals
    const fadeOutEnd = 0.4;
    final staggerRatio =
        widget.staggerDelay.inMilliseconds / widget.duration.inMilliseconds;
    final fadeInStart = (fadeOutEnd + staggerRatio).clamp(0.0, 1.0);

    // Fade-out animations (old text) - first 40% of animation
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, fadeOutEnd, curve: widget.fadeOutCurve),
      ),
    );

    _slideOutAnimation = Tween<double>(
      begin: 0.0,
      end: -widget.slideOutDistance,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, fadeOutEnd, curve: widget.slideOutCurve),
      ),
    );

    // Fade-in animations (new text) - after stagger delay
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(fadeInStart, 1.0, curve: widget.fadeInCurve),
      ),
    );

    _slideInAnimation = Tween<double>(
      begin: widget.slideInDistance,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(fadeInStart, 1.0, curve: widget.slideInCurve),
      ),
    );

    // Start with text visible
    _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(AdvancedTextTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if text has changed
    if (oldWidget.text != widget.text && !_isAnimating) {
      _animateTextChange(oldWidget.text, widget.text);
    }

    // Update animation duration if changed
    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
      _setupAnimations();
    }
  }

  void _animateTextChange(String oldText, String newText) {
    if (oldText == newText) return;

    setState(() {
      _isAnimating = true;
      _previousText = oldText;
      _currentText = newText;
    });

    // Reset and start animation
    _animationController.reset();
    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _previousText = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? _currentText,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Previous text (fading out and moving up)
              if (_previousText.isNotEmpty && _isAnimating)
                Transform.translate(
                  offset: Offset(0, _slideOutAnimation.value),
                  child: Opacity(
                    opacity: _fadeOutAnimation.value,
                    child: Text(
                      _previousText,
                      key: ValueKey('fadeOut_$_previousText'),
                      style: widget.style,
                      textAlign: widget.textAlign,
                      maxLines: widget.maxLines,
                      overflow: widget.overflow,
                    ),
                  ),
                ),

              // Current text (sliding in from right and fading in)
              Transform.translate(
                offset: Offset(_slideInAnimation.value, 0),
                child: Opacity(
                  opacity: _fadeInAnimation.value,
                  child: Text(
                    _currentText,
                    key: ValueKey('fadeIn_$_currentText'),
                    style: widget.style,
                    textAlign: widget.textAlign,
                    maxLines: widget.maxLines,
                    overflow: widget.overflow,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Specialized widget for calculation values with enhanced animations
class CalculationValueTransition extends StatelessWidget {
  const CalculationValueTransition({
    required this.value,
    required this.style,
    super.key,
    this.unit,
    this.prefix,
    this.textAlign = TextAlign.center,
    this.animationDuration = const Duration(milliseconds: 500),
    this.emphasizeChange = true,
  });

  /// The value to display
  final String value;

  /// Text style
  final TextStyle style;

  /// Optional unit (e.g., "ml", "L", "%")
  final String? unit;

  /// Optional prefix (e.g., "+", "-")
  final String? prefix;

  /// Text alignment
  final TextAlign textAlign;

  /// Animation duration
  final Duration animationDuration;

  /// Whether to emphasize value changes with enhanced animations
  final bool emphasizeChange;

  @override
  Widget build(BuildContext context) {
    final displayText = '${prefix ?? ''}$value${unit ?? ''}';

    return AdvancedTextTransition(
      text: displayText,
      style: style,
      textAlign: textAlign,
      duration: animationDuration,
      slideInDistance: emphasizeChange ? 40.0 : 25.0,
      slideOutDistance: emphasizeChange ? 30.0 : 20.0,
      slideInCurve: emphasizeChange ? Curves.elasticOut : Curves.easeOutCubic,
      fadeInCurve: emphasizeChange ? Curves.easeInOut : Curves.easeIn,
      staggerDelay: Duration(milliseconds: emphasizeChange ? 100 : 50),
    );
  }
}

/// Widget for smooth percentage transitions with visual emphasis
class AnimatedPercentageText extends StatelessWidget {
  const AnimatedPercentageText({
    required this.percentage,
    required this.style,
    super.key,
    this.decimalPlaces = 0,
    this.showPercentSign = true,
    this.textAlign = TextAlign.center,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  /// Percentage value (0.0 to 1.0)
  final double percentage;

  /// Text style
  final TextStyle style;

  /// Number of decimal places
  final int decimalPlaces;

  /// Whether to show % sign
  final bool showPercentSign;

  /// Text alignment
  final TextAlign textAlign;

  /// Animation duration
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final percentValue = (percentage * 100).toStringAsFixed(decimalPlaces);
    final displayText = '$percentValue${showPercentSign ? '%' : ''}';

    return CalculationValueTransition(
      value: percentValue,
      unit: showPercentSign ? '%' : null,
      style: style,
      textAlign: textAlign,
      animationDuration: animationDuration,
      emphasizeChange: true, // Emphasize percentage changes
    );
  }
}
