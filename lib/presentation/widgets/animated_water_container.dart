import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_symbols.dart';

class AnimatedWaterContainer extends StatelessWidget {
  final double progress;
  final bool isLoading;

  const AnimatedWaterContainer({
    super.key,
    required this.progress,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLoading ? 0.5 : 1.0,
      child: Stack(
        children: [
          Icon(
            AppSymbols.water,
            size: 300,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            tween: Tween<double>(
              begin: 0,
              end: progress.clamp(0.0, 1.0),
            ),
            builder: (context, value, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: value,
                  child: Icon(
                    AppSymbols.water,
                    size: 300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}