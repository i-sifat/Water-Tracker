import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class WaterAnimation extends StatefulWidget {
  const WaterAnimation({
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
  State<WaterAnimation> createState() => _WaterAnimationState();
}

class _WaterAnimationState extends State<WaterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Bubble> bubbles = [];
  final Random random = Random();
  Timer? _bubbleTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Initialize bubbles
    _generateBubbles();

    // Set up timer to continuously generate new bubbles
    _bubbleTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Add 1-3 new bubbles every half second
          _addNewBubbles(1 + random.nextInt(2));
        });
      }
    });
  }

  void _generateBubbles() {
    // Create initial set of bubbles
    int bubbleCount = 15 + random.nextInt(10);

    for (int i = 0; i < bubbleCount; i++) {
      bubbles.add(_createBubble());
    }
  }

  void _addNewBubbles(int count) {
    for (int i = 0; i < count; i++) {
      bubbles.add(_createBubble(forceBottom: true));
    }

    // Remove bubbles that have traveled beyond the water level
    bubbles.removeWhere(
      (bubble) =>
          bubble.currentY <
          widget.height * (1 - widget.progress) - bubble.radius * 2,
    );
  }

  Bubble _createBubble({bool forceBottom = false}) {
    // If forceBottom is true, create bubble at the bottom of the screen
    double startY =
        forceBottom
            ? widget.height +
                (random.nextDouble() * 20) // Start just below screen
            : widget.height * (1 - widget.progress) +
                (random.nextDouble() * widget.height * widget.progress);

    return Bubble(
      x: random.nextDouble() * widget.width,
      y: startY,
      currentY: startY,
      radius: 2 + random.nextDouble() * 6,
      speed: 40 + random.nextDouble() * 60, // Faster speed
      active: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _bubbleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update bubble positions
        _updateBubblePositions();

        return ClipRect(
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            painter: WaterLevelPainter(
              progress: widget.progress,
              waterColor: widget.waterColor.withOpacity(
                0.7,
              ), // Semi-transparent
              backgroundColor: widget.backgroundColor.withOpacity(0.05),
              animationValue: _controller.value,
              bubbles: bubbles,
            ),
          ),
        );
      },
    );
  }

  void _updateBubblePositions() {
    for (var bubble in bubbles) {
      if (bubble.active) {
        // Calculate new position based on animation frame
        bubble.currentY -=
            bubble.speed / 60; // Divide by frame rate for smoother movement
      }
    }
  }
}

class Bubble {
  double x;
  double y; // Original y position
  double currentY; // Current y position for animation
  double radius;
  double speed;
  bool active;

  Bubble({
    required this.x,
    required this.y,
    required this.currentY,
    required this.radius,
    required this.speed,
    required this.active,
  });
}

class WaterLevelPainter extends CustomPainter {
  final double progress;
  final Color waterColor;
  final Color backgroundColor;
  final double animationValue;
  final List<Bubble> bubbles;

  WaterLevelPainter({
    required this.progress,
    required this.waterColor,
    required this.backgroundColor,
    required this.animationValue,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate water level position
    final waterLevel = size.height * (1 - progress);

    // Paint for the water
    final waterPaint =
        Paint()
          ..color = waterColor
          ..style = PaintingStyle.fill;

    // Create a blur effect for the water
    final blurFilter = ImageFilter.blur(sigmaX: 5, sigmaY: 5);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Draw water waves
    final wavePath = Path();

    // Start at the bottom left
    wavePath.moveTo(0, size.height);

    // Create the left vertical line up to the water level
    wavePath.lineTo(0, waterLevel);

    // Create wavy pattern
    final waveHeight = 15.0;
    final waveWidth = size.width / 2;

    // First wave peak
    final wave1Offset = sin(animationValue * 2 * pi) * 5;

    // Second wave peak - slightly out of phase with the first
    final wave2Offset = sin((animationValue * 2 * pi) + pi / 2) * 5;

    // Draw first wave
    wavePath.cubicTo(
      waveWidth * 0.33,
      waterLevel - waveHeight + wave1Offset,
      waveWidth * 0.66,
      waterLevel + waveHeight + wave2Offset,
      waveWidth,
      waterLevel + wave1Offset,
    );

    // Draw second wave
    wavePath.cubicTo(
      waveWidth * 1.33,
      waterLevel - waveHeight + wave2Offset,
      waveWidth * 1.66,
      waterLevel + waveHeight + wave1Offset,
      size.width,
      waterLevel + wave2Offset,
    );

    // Connect to bottom right and close the path
    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    // Draw the water
    canvas.drawPath(wavePath, waterPaint);

    // Draw bubbles
    final bubblePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      // Only draw bubbles that are below the water level and within the screen
      if (bubble.active &&
          bubble.currentY >= waterLevel &&
          bubble.currentY <= size.height) {
        canvas.drawCircle(
          Offset(bubble.x, bubble.currentY),
          bubble.radius,
          bubblePaint,
        );
      }
    }

    // Apply blur effect
    canvas.restore();
  }

  @override
  bool shouldRepaint(WaterLevelPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue;
  }
}
