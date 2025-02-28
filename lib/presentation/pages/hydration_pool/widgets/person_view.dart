import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/assets.dart';

class PersonView extends StatelessWidget {
  const PersonView({
    required this.animation,
    required this.isMale,
    required this.progress,
    super.key,
  });
  
  final Animation<double> animation;
  final bool isMale;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // Calculate the vertical position based on water level
    // When progress is 0, the person is at the bottom
    // When progress is 1, the person is partially submerged
    final verticalOffset = lerpDouble(50, -20, progress) ?? 0;
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, verticalOffset + 4 * animation.value),
          child: child,
        );
      },
      child: Image.asset(
        Assets.person,
        height: 300,
      ),
    );
  }
}

// Helper function to linearly interpolate between two values
double? lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}