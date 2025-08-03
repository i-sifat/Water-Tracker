import 'package:flutter/material.dart';

/// Widget that provides smooth text transitions with slide-in and fade-out animations
/// Eliminates text disappearing/reappearing during updates
class SmoothTextTransition extends StatefulWidget {
  const SmoothTextTransition({
    required this.text,
    required this.style,
    super.key,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
    this.duration = const Duration(milliseconds: 300),
    this.slideDistance = 20.0,
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

  /// Distance for slide animation
  final double slideDistance;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  State<SmoothTextTransition> createState() => _SmoothTextTransitionState();
}

class _SmoothTextTransitionState extends State<SmoothTextTransition>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.slideDistance / 100, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start with text visible
    _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(SmoothTextTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if text has changed
    if (oldWidget.text != widget.text && !_isAnimating) {
      _animateTextChange(oldWidget.text, widget.text);
    }

    // Update animation duration if changed
    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
    }
  }

  void _animateTextChange(String oldText, String newText) {
    if (oldText == newText) return;

    setState(() {
      _isAnimating = true;
      _previousText = oldText;
      _currentText = newText;
    });

    // Start animation sequence: fade out old text while sliding up,
    // then fade in new text while sliding in from right
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _previousText = '';
        });
        _animationController.forward().then((_) {
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
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
                  offset: Offset(
                    0,
                    -widget.slideDistance * (1 - _fadeAnimation.value),
                  ),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Text(
                      _previousText,
                      key: ValueKey('previous_$_previousText'),
                      style: widget.style,
                      textAlign: widget.textAlign,
                      maxLines: widget.maxLines,
                      overflow: widget.overflow,
                    ),
                  ),
                ),

              // Current text (sliding in from right and fading in)
              Transform.translate(
                offset: Offset(
                  widget.slideDistance *
                      (1 - _fadeAnimation.value), // Slide in from right
                  0,
                ),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    _currentText,
                    key: ValueKey(
                      'current_$_currentText',
                    ), // Prevent unnecessary rebuilds
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

/// Extension to easily convert regular Text widgets to smooth transitions
extension TextToSmoothTransition on Text {
  SmoothTextTransition toSmoothTransition({
    Duration duration = const Duration(milliseconds: 300),
    double slideDistance = 20.0,
    String? semanticLabel,
  }) {
    return SmoothTextTransition(
      text: data ?? '',
      style: style ?? const TextStyle(),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
      duration: duration,
      slideDistance: slideDistance,
      semanticLabel: semanticLabel ?? semanticsLabel,
    );
  }
}
