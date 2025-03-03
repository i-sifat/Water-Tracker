import 'dart:math';
import 'package:flutter/material.dart';

class WaterLevelPainter extends CustomPainter {
  WaterLevelPainter({
    required this.progress,
    required this.waterColor,
    required this.backgroundColor,
  });
  final double progress; // Normalized progress (0.0 to 1.0)
  final Color waterColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint =
        Paint()
          ..color = waterColor
          ..style = PaintingStyle.fill;

    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Calculate wave height based on progress
    final waveHeight = size.height * (1 - progress);

    // Create a wave path
    final wavePath = Path();
    wavePath.moveTo(0, waveHeight);

    // More complex wave with multiple curves
    wavePath.quadraticBezierTo(
      size.width * 0.25,
      waveHeight - 40,
      size.width * 0.5,
      waveHeight,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.75,
      waveHeight + 40,
      size.width,
      waveHeight,
    );
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);

    // Add bubbles
    final random = Random();
    final bubblePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.5) // Semi-transparent white
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      // Draw 10 bubbles
      final x = random.nextDouble() * size.width;
      final y =
          waveHeight +
          random.nextDouble() *
              (size.height - waveHeight); // Only within the water
      final radius =
          random.nextDouble() * 3 +
          1; // Bubbles between 1 and 4 pixels in radius

      canvas.drawCircle(Offset(x, y), radius, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaterLevelPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waterColor != waterColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class WaterLevelAnimation extends StatefulWidget {
  const WaterLevelAnimation({
    super.key,
    required this.progress,
    required this.waterColor,
    required this.backgroundColor,
    required this.width,
    required this.height,
  });
  final double progress;
  final Color waterColor;
  final Color backgroundColor;
  final double width;
  final double height;

  @override
  State<WaterLevelAnimation> createState() => _WaterLevelAnimationState();
}

class _WaterLevelAnimationState extends State<WaterLevelAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Adjust duration as needed
    )..repeat(
      reverse: true,
    ); // Make the wave oscillate (removed, as bubbles will be animated separately)
  }

  @override
  void didUpdateWidget(covariant WaterLevelAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.animateTo(widget.progress, curve: Curves.easeInOut);
  }

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
}
