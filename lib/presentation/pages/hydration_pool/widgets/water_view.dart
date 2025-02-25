import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_symbols.dart';

class WaterView extends StatelessWidget {
  final Animation<double> animation;
  final double progress;

  const WaterView({
    super.key,
    required this.animation,
    required this.progress,
  });

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
      child: Stack(
        children: [
          Icon(
            AppSymbols.water,
            size: 300,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: progress.clamp(0.0, 1.0),
              child: Icon(
                AppSymbols.water,
                size: 300,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}