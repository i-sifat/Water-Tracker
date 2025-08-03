import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watertracker/core/design_system/design_system.dart';

/// Collection of micro-interaction animations for enhanced user experience
class MicroInteractions {
  MicroInteractions._();

  /// Standard animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  /// Standard animation curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  /// Creates a press animation that scales down on tap
  static Widget pressAnimation({
    required Widget child,
    required VoidCallback onPressed,
    double scaleDown = 0.95,
    Duration duration = fast,
    Curve curve = easeInOut,
    bool hapticFeedback = true,
  }) {
    return _PressAnimationWidget(
      onPressed: onPressed,
      scaleDown: scaleDown,
      duration: duration,
      curve: curve,
      hapticFeedback: hapticFeedback,
      child: child,
    );
  }

  /// Creates a hover animation that scales up on hover
  static Widget hoverAnimation({
    required Widget child,
    double scaleUp = 1.05,
    Duration duration = fast,
    Curve curve = easeOut,
  }) {
    return _HoverAnimationWidget(
      scaleUp: scaleUp,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// Creates a fade-in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = medium,
    Curve curve = easeOut,
    Duration delay = Duration.zero,
  }) {
    return _FadeInWidget(
      duration: duration,
      curve: curve,
      delay: delay,
      child: child,
    );
  }

  /// Creates a slide-in animation from the specified direction
  static Widget slideIn({
    required Widget child,
    SlideDirection direction = SlideDirection.bottom,
    Duration duration = medium,
    Curve curve = easeOut,
    Duration delay = Duration.zero,
    double distance = 50.0,
  }) {
    return _SlideInWidget(
      direction: direction,
      duration: duration,
      curve: curve,
      delay: delay,
      distance: distance,
      child: child,
    );
  }

  /// Creates a bounce animation
  static Widget bounce({
    required Widget child,
    Duration duration = slow,
    Curve curve = bounceOut,
    Duration delay = Duration.zero,
  }) {
    return _BounceWidget(
      duration: duration,
      curve: curve,
      delay: delay,
      child: child,
    );
  }

  /// Creates a shimmer loading animation
  static Widget shimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
  }) {
    return _ShimmerWidget(
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  /// Creates a pulse animation
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return _PulseWidget(
      duration: duration,
      minScale: minScale,
      maxScale: maxScale,
      child: child,
    );
  }

  /// Creates a ripple effect animation
  static Widget ripple({
    required Widget child,
    required VoidCallback onTap,
    Color rippleColor = AppColors.primary,
    Duration duration = medium,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        splashColor: rippleColor.withOpacity(0.3),
        highlightColor: rippleColor.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMD,
        child: child,
      ),
    );
  }
}

/// Slide direction for slide-in animations
enum SlideDirection { top, bottom, left, right }

/// Press animation widget
class _PressAnimationWidget extends StatefulWidget {
  const _PressAnimationWidget({
    required this.child,
    required this.onPressed,
    required this.scaleDown,
    required this.duration,
    required this.curve,
    required this.hapticFeedback,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double scaleDown;
  final Duration duration;
  final Curve curve;
  final bool hapticFeedback;

  @override
  State<_PressAnimationWidget> createState() => _PressAnimationWidgetState();
}

class _PressAnimationWidgetState extends State<_PressAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Hover animation widget
class _HoverAnimationWidget extends StatefulWidget {
  const _HoverAnimationWidget({
    required this.child,
    required this.scaleUp,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final double scaleUp;
  final Duration duration;
  final Curve curve;

  @override
  State<_HoverAnimationWidget> createState() => _HoverAnimationWidgetState();
}

class _HoverAnimationWidgetState extends State<_HoverAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleUp,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Fade-in animation widget
class _FadeInWidget extends StatefulWidget {
  const _FadeInWidget({
    required this.child,
    required this.duration,
    required this.curve,
    required this.delay,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration delay;

  @override
  State<_FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<_FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(opacity: _fadeAnimation.value, child: widget.child);
      },
    );
  }
}

/// Slide-in animation widget
class _SlideInWidget extends StatefulWidget {
  const _SlideInWidget({
    required this.child,
    required this.direction,
    required this.duration,
    required this.curve,
    required this.delay,
    required this.distance,
  });

  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;
  final Duration delay;
  final double distance;

  @override
  State<_SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<_SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.top:
        beginOffset = const Offset(0, -1);
        break;
      case SlideDirection.bottom:
        beginOffset = const Offset(0, 1);
        break;
      case SlideDirection.left:
        beginOffset = const Offset(-1, 0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(1, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(position: _slideAnimation, child: widget.child);
      },
    );
  }
}

/// Bounce animation widget
class _BounceWidget extends StatefulWidget {
  const _BounceWidget({
    required this.child,
    required this.duration,
    required this.curve,
    required this.delay,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration delay;

  @override
  State<_BounceWidget> createState() => _BounceWidgetState();
}

class _BounceWidgetState extends State<_BounceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer animation widget
class _ShimmerWidget extends StatefulWidget {
  const _ShimmerWidget({
    required this.child,
    required this.duration,
    required this.baseColor,
    required this.highlightColor,
  });

  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Pulse animation widget
class _PulseWidget extends StatefulWidget {
  const _PulseWidget({
    required this.child,
    required this.duration,
    required this.minScale,
    required this.maxScale,
  });

  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _pulseAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Gradient transform for shimmer effect
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
