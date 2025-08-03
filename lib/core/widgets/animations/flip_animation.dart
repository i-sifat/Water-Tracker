import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget that provides a 3D flip animation effect
class FlipAnimation extends StatefulWidget {
  const FlipAnimation({
    required this.frontChild,
    required this.backChild,
    this.duration = const Duration(milliseconds: 600),
    this.flipAxis = FlipAxis.vertical,
    super.key,
  });

  /// Widget to show on the front side
  final Widget frontChild;

  /// Widget to show on the back side
  final Widget backChild;

  /// Duration of the flip animation
  final Duration duration;

  /// Axis around which to flip
  final FlipAxis flipAxis;

  @override
  State<FlipAnimation> createState() => _FlipAnimationState();
}

class _FlipAnimationState extends State<FlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger the flip animation
  void flip() {
    if (_controller.isAnimating) return;

    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFront = _animation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: _getTransform(),
            child: isShowingFront ? widget.frontChild : widget.backChild,
          );
        },
      ),
    );
  }

  Matrix4 _getTransform() {
    final rotationValue = _animation.value * math.pi;

    switch (widget.flipAxis) {
      case FlipAxis.vertical:
        return Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Add perspective
          ..rotateX(rotationValue);
      case FlipAxis.horizontal:
        return Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Add perspective
          ..rotateY(rotationValue);
    }
  }
}

/// Axis around which the flip animation occurs
enum FlipAxis { vertical, horizontal }
