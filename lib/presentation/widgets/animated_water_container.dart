import 'dart:math';

import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_colors.dart';

class AnimatedWaterContainer extends StatelessWidget {
  const AnimatedWaterContainer({
    required this.progress,
    super.key,
    this.isLoading = false,
    this.color,
  });

  final double progress;
  final bool isLoading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLoading ? 0.5 : 1.0,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background water container (empty)
          Container(
            width: screenWidth,
            height: screenHeight * 0.5,
            color: AppColors.waterLow,
          ),

          // Animated water level
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            tween: Tween<double>(
              begin: 0,
              end: progress.clamp(0.0, 1.0),
            ),
            builder: (context, value, child) {
              return ClipPath(
                clipper: _WaveClipper(value),
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.5,
                  color: color ?? AppColors.getWaterColor(progress),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  _WaveClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;

    // Calculate the wave height based on progress
    final waveHeight = 10.0 + (1.0 - progress) * 10.0;

    // Calculate the water level height
    final waterHeight = height * progress;

    // Start at bottom left
    path.moveTo(0, height);

    // Draw bottom line
    path.lineTo(0, height - waterHeight);

    // Draw wavy top line
    for (var i = 0.0; i <= width; i += width / 10) {
      path.lineTo(
        i,
        height - waterHeight + sin(i / width * 6 * 3.14159) * waveHeight,
      );
    }

    // Complete the path
    path.lineTo(width, height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => true;
}
