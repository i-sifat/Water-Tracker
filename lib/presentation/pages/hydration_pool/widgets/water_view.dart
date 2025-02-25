import 'package:flutter/material.dart';
import 'package:watertracker/presentation/widgets/animated_water_container.dart';

class WaterView extends StatelessWidget {
  const WaterView({
    required this.animation,
    required this.progress,
    super.key,
    this.isLoading = false,
  });
  final Animation<double> animation;
  final double progress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 2 * animation.value),
          child: child,
        );
      },
      child: AnimatedWaterContainer(
        progress: progress,
        isLoading: isLoading,
      ),
    );
  }
}
