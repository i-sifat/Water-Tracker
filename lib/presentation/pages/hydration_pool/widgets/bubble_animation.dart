import 'dart:math';
import 'package:flutter/material.dart';

class BubbleAnimation extends StatelessWidget {
  const BubbleAnimation({
    required this.controller,
    super.key,
    this.bubbleCount = 8,
  });
  
  final AnimationController controller;
  final int bubbleCount;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: List.generate(
            bubbleCount,
            (index) => _Bubble(
              controller: controller,
              index: index,
              bubbleCount: bubbleCount,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatefulWidget {
  const _Bubble({
    required this.controller,
    required this.index,
    required this.bubbleCount,
  });
  
  final AnimationController controller;
  final int index;
  final int bubbleCount;

  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> {
  late Animation<double> _animation;
  late double _startX;
  late double _endX;
  late double _size;
  late double _speed;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    final random = Random();
    
    // Random horizontal position
    _startX = -0.5 + random.nextDouble();
    _endX = _startX + (-0.3 + random.nextDouble() * 0.6);
    
    // Random bubble size
    _size = 4 + random.nextDouble() * 8;
    
    // Random speed (duration)
    _speed = 0.5 + random.nextDouble() * 0.5;
    
    // Create staggered animation
    final startTime = widget.index / widget.bubbleCount;
    final endTime = startTime + _speed;
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(startTime, endTime, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate current position
        final progress = _animation.value;
        final x = lerpDouble(_startX, _endX, progress) ?? 0;
        final y = 1 - progress; // Move from bottom to top
        
        return Positioned(
          left: MediaQuery.of(context).size.width * (0.5 + x),
          bottom: MediaQuery.of(context).size.height * y,
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
  
  // Helper function to linearly interpolate between two values
  double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}