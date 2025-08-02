import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for drawing circular progress indicator with gradient and inner ring
/// Performance optimized with cached paint objects and gradient calculations
@immutable
class CircularProgressPainter extends CustomPainter {
  /// Creates a circular progress painter
  const CircularProgressPainter({
    required this.progress,
    this.strokeWidth = 12.0,
    this.backgroundColor = const Color(0xFFE5E5E5),
    this.progressColors = const [Color(0xFF2196F3), Color(0xFF1976D2)],
    this.innerRingColor = const Color(0xFF4CAF50),
    this.innerRingWidth = 3.0,
    this.startAngle = -math.pi / 2, // Start from top
  });

  // Performance optimization: Static cache for paint objects
  static final Map<String, Paint> _paintCache = <String, Paint>{};
  static final Map<String, SweepGradient> _gradientCache =
      <String, SweepGradient>{};

  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Width of the progress stroke
  final double strokeWidth;

  /// Background circle color
  final Color backgroundColor;

  /// Gradient colors for progress arc
  final List<Color> progressColors;

  /// Color of the inner ring
  final Color innerRingColor;

  /// Width of the inner ring
  final double innerRingWidth;

  /// Starting angle for progress arc (in radians)
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final innerRadius = radius - strokeWidth / 2 - innerRingWidth / 2 - 4;

    // Draw background circle
    _drawBackgroundCircle(canvas, center, radius);

    // Draw progress arc with gradient
    _drawProgressArc(canvas, center, radius, size);

    // Draw inner ring
    _drawInnerRing(canvas, center, innerRadius);
  }

  /// Draws the background circle
  /// Performance optimization: Cache paint objects
  void _drawBackgroundCircle(Canvas canvas, Offset center, double radius) {
    final cacheKey = 'bg_${backgroundColor.value}_$strokeWidth';
    final backgroundPaint = _paintCache.putIfAbsent(
      cacheKey,
      () =>
          Paint()
            ..color = backgroundColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(center, radius, backgroundPaint);
  }

  /// Draws the progress arc with gradient
  /// Performance optimization: Cache gradient and paint objects
  void _drawProgressArc(
    Canvas canvas,
    Offset center,
    double radius,
    Size size,
  ) {
    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    // Performance optimization: Cache gradient object
    final gradientKey =
        '${progressColors.map((c) => c.value).join('_')}_${startAngle}_$sweepAngle';
    final gradient = _gradientCache.putIfAbsent(
      gradientKey,
      () => SweepGradient(
        colors: progressColors,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ),
    );

    // Performance optimization: Cache paint object (but recreate shader for current rect)
    final paintKey = 'progress_$strokeWidth';
    final progressPaint = _paintCache.putIfAbsent(
      paintKey,
      () =>
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
    );

    // Update shader for current rect (this needs to be done each time)
    progressPaint.shader = gradient.createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  /// Draws the inner ring
  /// Performance optimization: Cache paint object
  void _drawInnerRing(Canvas canvas, Offset center, double radius) {
    final cacheKey = 'inner_${innerRingColor.value}_$innerRingWidth';
    final innerRingPaint = _paintCache.putIfAbsent(
      cacheKey,
      () =>
          Paint()
            ..color = innerRingColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = innerRingWidth,
    );

    canvas.drawCircle(center, radius, innerRingPaint);
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth ||
        backgroundColor != oldDelegate.backgroundColor ||
        progressColors != oldDelegate.progressColors ||
        innerRingColor != oldDelegate.innerRingColor ||
        innerRingWidth != oldDelegate.innerRingWidth ||
        startAngle != oldDelegate.startAngle;
  }

  /// Creates a copy with updated properties
  CircularProgressPainter copyWith({
    double? progress,
    double? strokeWidth,
    Color? backgroundColor,
    List<Color>? progressColors,
    Color? innerRingColor,
    double? innerRingWidth,
    double? startAngle,
  }) {
    return CircularProgressPainter(
      progress: progress ?? this.progress,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      progressColors: progressColors ?? this.progressColors,
      innerRingColor: innerRingColor ?? this.innerRingColor,
      innerRingWidth: innerRingWidth ?? this.innerRingWidth,
      startAngle: startAngle ?? this.startAngle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CircularProgressPainter) return false;

    return progress == other.progress &&
        strokeWidth == other.strokeWidth &&
        backgroundColor == other.backgroundColor &&
        _listEquals(progressColors, other.progressColors) &&
        innerRingColor == other.innerRingColor &&
        innerRingWidth == other.innerRingWidth &&
        startAngle == other.startAngle;
  }

  @override
  int get hashCode {
    return Object.hash(
      progress,
      strokeWidth,
      backgroundColor,
      Object.hashAll(progressColors),
      innerRingColor,
      innerRingWidth,
      startAngle,
    );
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (var index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
