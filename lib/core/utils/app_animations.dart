import 'package:flutter/material.dart';

class AppAnimations {
  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeInOutQuart;

  // Page transition animations
  static Route<T> slideTransition<T extends Object?>(
    Widget page, {
    Duration duration = normal,
    Offset begin = const Offset(1, 0),
    Offset end = Offset.zero,
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<T> fadeTransition<T extends Object?>(
    Widget page, {
    Duration duration = normal,
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        );
      },
    );
  }

  static Route<T> scaleTransition<T extends Object?>(
    Widget page, {
    Duration duration = normal,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = bounceCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Micro-interaction animations
  static Widget buttonPressAnimation({
    required Widget child,
    required VoidCallback onPressed,
    double scale = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _ButtonPressAnimation(
      onPressed: onPressed,
      scale: scale,
      duration: duration,
      child: child,
    );
  }

  // Staggered list animation
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = normal,
    Offset slideOffset = const Offset(0, 50),
  }) {
    return _StaggeredListItem(
      index: index,
      delay: delay,
      duration: duration,
      slideOffset: slideOffset,
      child: child,
    );
  }

  // Shimmer loading animation
  static Widget shimmerLoading({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _ShimmerLoading(
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      child: child,
    );
  }
}

class _ButtonPressAnimation extends StatefulWidget {
  const _ButtonPressAnimation({
    required this.child,
    required this.onPressed,
    required this.scale,
    required this.duration,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double scale;
  final Duration duration;

  @override
  State<_ButtonPressAnimation> createState() => _ButtonPressAnimationState();
}

class _ButtonPressAnimationState extends State<_ButtonPressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
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

class _StaggeredListItem extends StatefulWidget {
  const _StaggeredListItem({
    required this.child,
    required this.index,
    required this.delay,
    required this.duration,
    required this.slideOffset,
  });

  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  @override
  State<_StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<_StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animation with delay
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading({
    required this.child,
    required this.duration, this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surface;
    final highlightColor = widget.highlightColor ?? 
        theme.colorScheme.onSurface.withOpacity(0.1);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}