import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:watertracker/core/utils/performance_utils.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  List<Bubble> bubbles = [];
  final Random random = Random();
  Timer? _bubbleTimer;
  Ticker? _bubbleTicker;
  double _lastProgress = 0;
  int _frameCount = 0;

  // Animation caching for better performance
  WaterLevelPainter? _cachedPainter;
  double _lastCachedProgress = -1;
  double _lastCachedAnimationValue = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _lastProgress = widget.progress;
    _progressController.forward();

    // Initialize bubbles with better performance
    _generateBubbles();

    // Use Ticker for better performance instead of Timer
    _bubbleTicker = createTicker(_updateBubbles);
    _bubbleTicker?.start();
  }

  void _updateBubbles(Duration elapsed) {
    if (!mounted) return;

    _frameCount++;

    // Frame rate limiting: Only update every other frame for better performance
    if (_frameCount % 2 != 0) return;

    // Only add new bubbles every 30 frames (approximately 0.5 seconds at 60fps)
    if (_frameCount % 30 == 0 && widget.progress > 0.1) {
      _addNewBubbles(1 + random.nextInt(2));
    }

    // Update bubble positions more efficiently
    _updateBubblePositions();
  }

  void _generateBubbles() {
    // Create initial set of bubbles
    final bubbleCount = 15 + random.nextInt(10);

    for (var i = 0; i < bubbleCount; i++) {
      bubbles.add(_createBubble());
    }
  }

  void _addNewBubbles(int count) {
    for (var i = 0; i < count; i++) {
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
    final startY =
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
  void didUpdateWidget(WaterAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate progress changes smoothly
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _lastProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeInOutCubic,
        ),
      );

      _lastProgress = widget.progress;
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    _bubbleTimer?.cancel();
    _bubbleTicker?.dispose();
    _cachedPainter = null; // Clear cached painter
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _progressAnimation]),
      builder: (context, child) {
        // Performance optimization: RepaintBoundary around expensive water animation
        return PerformanceUtils.optimizedRepaintBoundary(
          debugLabel: 'WaterAnimation',
          child: ClipRect(
            child: CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _getCachedPainter(
                _progressAnimation.value,
                _controller.value,
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateBubblePositions() {
    for (final bubble in bubbles) {
      if (bubble.active) {
        // Calculate new position based on animation frame
        bubble.currentY -=
            bubble.speed / 60; // Divide by frame rate for smoother movement
      }
    }
  }

  /// Performance optimization: Cache painter instance to avoid recreation
  WaterLevelPainter _getCachedPainter(double progress, double animationValue) {
    // Only recreate painter if values have changed significantly
    if (_cachedPainter == null ||
        (_lastCachedProgress - progress).abs() > 0.001 ||
        (_lastCachedAnimationValue - animationValue).abs() > 0.001) {
      _cachedPainter = WaterLevelPainter(
        progress: progress,
        waterColor: widget.waterColor.withAlpha(179), // Semi-transparent
        backgroundColor: widget.backgroundColor.withAlpha(150),
        animationValue: animationValue,
        bubbles: bubbles,
      );

      _lastCachedProgress = progress;
      _lastCachedAnimationValue = animationValue;
    }

    return _cachedPainter!;
  }
}

class Bubble {
  Bubble({
    required this.x,
    required this.y,
    required this.currentY,
    required this.radius,
    required this.speed,
    required this.active,
  });
  double x;
  double y; // Original y position
  double currentY; // Current y position for animation
  double radius;
  double speed;
  bool active;
}

class WaterLevelPainter extends CustomPainter {
  WaterLevelPainter({
    required this.progress,
    required this.waterColor,
    required this.backgroundColor,
    required this.animationValue,
    required this.bubbles,
  });
  final double progress;
  final Color waterColor;
  final Color backgroundColor;
  final double animationValue;
  final List<Bubble> bubbles;

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
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Draw water waves
    final wavePath =
        Path()
          // Start at the bottom left
          ..moveTo(0, size.height)
          // Create the left vertical line up to the water level
          ..lineTo(0, waterLevel);

    // Create wavy pattern
    const waveHeight = 15.0;
    final waveWidth = size.width / 2;

    // First wave peak
    final wave1Offset = sin(animationValue * 2 * pi) * 5;

    // Second wave peak - slightly out of phase with the first
    final wave2Offset = sin((animationValue * 2 * pi) + pi / 2) * 5;

    // Draw first wave
    wavePath
      ..cubicTo(
        waveWidth * 0.33,
        waterLevel - waveHeight + wave1Offset,
        waveWidth * 0.66,
        waterLevel + waveHeight + wave2Offset,
        waveWidth,
        waterLevel + wave1Offset,
      )
      // Draw second wave
      ..cubicTo(
        waveWidth * 1.33,
        waterLevel - waveHeight + wave2Offset,
        waveWidth * 1.66,
        waterLevel + waveHeight + wave1Offset,
        size.width,
        waterLevel + wave2Offset,
      )
      // Connect to bottom right and close the path
      ..lineTo(size.width, size.height)
      ..close();

    // Draw the water
    canvas.drawPath(wavePath, waterPaint);

    // Draw bubbles
    final bubblePaint =
        Paint()
          ..color = Colors.white.withAlpha(170)
          ..style = PaintingStyle.fill;

    for (final bubble in bubbles) {
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
