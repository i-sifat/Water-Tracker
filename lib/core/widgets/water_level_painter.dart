// lib/widgets/water_level_painter.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaterLevelAnimation extends StatefulWidget {
  const WaterLevelAnimation({
    required this.progress,
    required this.waterColor,
    required this.backgroundColor,
    required this.width,
    required this.height,
    super.key,
  });
  final double progress;
  final Color waterColor;
  final Color backgroundColor;
  final double width;

  final double height;

  @override
  State<WaterLevelAnimation> createState() => _WaterLevelAnimationState();
}

class WaterLevelPainter extends CustomPainter {
  WaterLevelPainter({
    required this.progress,
    required this.waterColor,
    required this.backgroundColor,
    required this.animationValue,
  });
  final double progress;
  final Color waterColor;
  final Color backgroundColor;

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    // Background color - entire container
    final backgroundPaint =
        Paint()
          ..color = backgroundColor.withAlpha(26)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Water level
    final waterLevel = size.height * (1 - progress);

    // Create wave pattern
    final waterPath =
        Path()
          // Start from bottom left
          ..moveTo(0, size.height);

    // Go to water level with wave pattern
    const waveHeight = 10.0;
    final waveCount = size.width ~/ 40; // Number of waves

    // Create wave pattern from left to right
    for (var i = 0; i <= waveCount; i++) {
      final x = i * (size.width / waveCount);
      final y =
          waterLevel +
          math.sin((animationValue * 2 * math.pi) + (i * math.pi / 4)) *
              waveHeight;

      if (i == 0) {
        waterPath.lineTo(0, y);
      } else {
        final prevX = (i - 1) * (size.width / waveCount);
        final ctrlX = (prevX + x) / 2;
        waterPath.quadraticBezierTo(
          ctrlX,
          waterLevel +
              math.cos(
                    (animationValue * 2 * math.pi) + ((i - 0.5) * math.pi / 4),
                  ) *
                  waveHeight,
          x,
          y,
        );
      }
    }

    // Complete the path
    waterPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Draw water
    final waterPaint =
        Paint()
          ..color = waterColor
          ..style = PaintingStyle.fill;

    canvas.drawPath(waterPath, waterPaint);

    // Draw small bubbles if progress is significant
    if (progress > 0.1) {
      final bubblePaint =
          Paint()
            ..color = Colors.white.withAlpha(100)
            ..style = PaintingStyle.fill;

      // Create random positions for bubbles
      final random = math.Random(42); // Fixed seed for consistent bubbles
      for (var i = 0; i < 8; i++) {
        final bubbleX = random.nextDouble() * size.width;
        final bubbleY =
            waterLevel + random.nextDouble() * (size.height - waterLevel);
        final bubbleSize = 3.0 + random.nextDouble() * 4.0;

        canvas.drawCircle(
          Offset(
            bubbleX,
            bubbleY + (math.sin(animationValue * 2 * math.pi + i) * 5),
          ),
          bubbleSize,
          bubblePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaterLevelPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.waterColor != waterColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _WaterLevelAnimationState extends State<WaterLevelAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: WaterLevelPainter(
            progress: widget.progress,
            waterColor: widget.waterColor,
            backgroundColor: widget.backgroundColor,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
}
