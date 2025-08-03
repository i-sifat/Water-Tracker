import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Enhanced page transition system with performance optimization and frame rate limiting
class SmoothPageTransitions {
  /// Default animation duration for smooth transitions
  static const Duration defaultDuration = Duration(milliseconds: 200);

  /// Default curve for smooth animations
  static const Curve defaultCurve = Curves.easeOut;

  /// Frame rate limiting for smooth animations
  static const int targetFPS = 60;
  static const Duration frameInterval = Duration(
    microseconds: 16667,
  ); // 1/60 second

  /// Create a route with smooth transitions
  static PageRouteBuilder<T> createRoute<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return slideTransition<T>(
      page: page,
      settings: settings,
      duration: duration,
      curve: curve,
    );
  }

  /// Slide transition with performance optimization
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = defaultDuration,
    Offset begin = const Offset(1, 0),
    Offset end = Offset.zero,
    Curve curve = defaultCurve,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: maintainState,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Use optimized tween with frame rate limiting
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return _FrameRateLimitedTransition(
          animation: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  /// Fade transition with performance optimization
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: maintainState,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _FrameRateLimitedTransition(
          animation: animation,
          child: FadeTransition(
            opacity: animation.drive(CurveTween(curve: curve)),
            child: child,
          ),
        );
      },
    );
  }

  /// Scale transition with performance optimization
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 250),
    double begin = 0.8,
    double end = 1.0,
    Curve curve = Curves.easeOutBack,
    Alignment alignment = Alignment.center,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: maintainState,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        final fadeTween = Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn));

        return _FrameRateLimitedTransition(
          animation: animation,
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            alignment: alignment,
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Combined slide and fade transition for smooth onboarding
  static PageRouteBuilder<T> onboardingTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = defaultDuration,
    Offset slideBegin = const Offset(0.3, 0),
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideTween = Tween(
          begin: slideBegin,
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));

        final fadeTween = Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: curve));

        return _FrameRateLimitedTransition(
          animation: animation,
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// No transition for instant navigation (best performance)
  static PageRouteBuilder<T> noTransition<T>({
    required Widget page,
    RouteSettings? settings,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      maintainState: maintainState,
    );
  }

  /// Custom transition builder with performance optimization
  static PageRouteBuilder<T> customTransition<T>({
    required Widget page,
    required Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    )
    transitionsBuilder,
    RouteSettings? settings,
    Duration duration = defaultDuration,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _FrameRateLimitedTransition(
          animation: animation,
          child: transitionsBuilder(
            context,
            animation,
            secondaryAnimation,
            child,
          ),
        );
      },
    );
  }
}

/// Frame rate limited transition wrapper for smooth animations
class _FrameRateLimitedTransition extends StatefulWidget {
  final Animation<double> animation;
  final Widget child;

  const _FrameRateLimitedTransition({
    required this.animation,
    required this.child,
  });

  @override
  State<_FrameRateLimitedTransition> createState() =>
      _FrameRateLimitedTransitionState();
}

class _FrameRateLimitedTransitionState
    extends State<_FrameRateLimitedTransition>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.animation.addListener(_onAnimationChanged);

    if (widget.animation.isAnimating) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onAnimationChanged);
    _ticker.dispose();
    super.dispose();
  }

  void _onAnimationChanged() {
    if (widget.animation.isAnimating && !_ticker.isActive) {
      _ticker.start();
    } else if (!widget.animation.isAnimating && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final now = DateTime.now();
    final timeSinceLastFrame = now.difference(_lastFrameTime);

    // Limit frame rate to target FPS
    if (timeSinceLastFrame >= SmoothPageTransitions.frameInterval) {
      _lastFrameTime = now;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Transition type enumeration
enum TransitionType { slide, fade, scale, onboarding, none, custom }

/// Transition configuration class
class TransitionConfig {
  final TransitionType type;
  final Duration duration;
  final Curve curve;
  final Offset? slideBegin;
  final double? scaleBegin;
  final Alignment? scaleAlignment;
  final bool maintainState;

  const TransitionConfig({
    this.type = TransitionType.slide,
    this.duration = SmoothPageTransitions.defaultDuration,
    this.curve = SmoothPageTransitions.defaultCurve,
    this.slideBegin,
    this.scaleBegin,
    this.scaleAlignment,
    this.maintainState = true,
  });

  /// Default configuration for onboarding screens
  static const TransitionConfig onboarding = TransitionConfig(
    type: TransitionType.onboarding,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
    slideBegin: Offset(0.3, 0),
  );

  /// Default configuration for main app screens
  static const TransitionConfig main = TransitionConfig(
    type: TransitionType.slide,
    duration: Duration(milliseconds: 250),
    curve: Curves.easeOut,
    slideBegin: Offset(1, 0),
  );

  /// Default configuration for modal screens
  static const TransitionConfig modal = TransitionConfig(
    type: TransitionType.scale,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOutBack,
    scaleBegin: 0.8,
    scaleAlignment: Alignment.center,
  );

  /// Default configuration for settings screens
  static const TransitionConfig settings = TransitionConfig(
    type: TransitionType.fade,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOut,
  );

  /// No transition configuration
  static const TransitionConfig none = TransitionConfig(
    type: TransitionType.none,
    duration: Duration.zero,
  );
}

/// Enhanced navigator extensions with smooth transitions
extension SmoothNavigatorExtensions on NavigatorState {
  /// Push with smooth transition using configuration
  Future<T?> pushSmooth<T extends Object?>(
    Widget page, {
    TransitionConfig config = TransitionConfig.main,
    RouteSettings? settings,
  }) {
    return push<T>(_buildRoute<T>(page, config, settings));
  }

  /// Push replacement with smooth transition
  Future<T?> pushReplacementSmooth<T extends Object?, TO extends Object?>(
    Widget page, {
    TransitionConfig config = TransitionConfig.main,
    RouteSettings? settings,
    TO? result,
  }) {
    return pushReplacement<T, TO>(
      _buildRoute<T>(page, config, settings),
      result: result,
    );
  }

  /// Push and remove until with smooth transition
  Future<T?> pushAndRemoveUntilSmooth<T extends Object?>(
    Widget page,
    RoutePredicate predicate, {
    TransitionConfig config = TransitionConfig.main,
    RouteSettings? settings,
  }) {
    return pushAndRemoveUntil<T>(
      _buildRoute<T>(page, config, settings),
      predicate,
    );
  }

  /// Build route based on configuration
  PageRouteBuilder<T> _buildRoute<T extends Object?>(
    Widget page,
    TransitionConfig config,
    RouteSettings? settings,
  ) {
    switch (config.type) {
      case TransitionType.slide:
        return SmoothPageTransitions.slideTransition<T>(
          page: page,
          settings: settings,
          duration: config.duration,
          curve: config.curve,
          begin: config.slideBegin ?? const Offset(1, 0),
          maintainState: config.maintainState,
        );
      case TransitionType.fade:
        return SmoothPageTransitions.fadeTransition<T>(
          page: page,
          settings: settings,
          duration: config.duration,
          curve: config.curve,
          maintainState: config.maintainState,
        );
      case TransitionType.scale:
        return SmoothPageTransitions.scaleTransition<T>(
          page: page,
          settings: settings,
          duration: config.duration,
          curve: config.curve,
          begin: config.scaleBegin ?? 0.8,
          alignment: config.scaleAlignment ?? Alignment.center,
          maintainState: config.maintainState,
        );
      case TransitionType.onboarding:
        return SmoothPageTransitions.onboardingTransition<T>(
          page: page,
          settings: settings,
          duration: config.duration,
          curve: config.curve,
          slideBegin: config.slideBegin ?? const Offset(0.3, 0),
        );
      case TransitionType.none:
        return SmoothPageTransitions.noTransition<T>(
          page: page,
          settings: settings,
          maintainState: config.maintainState,
        );
      case TransitionType.custom:
        // For custom transitions, fall back to slide
        return SmoothPageTransitions.slideTransition<T>(
          page: page,
          settings: settings,
          duration: config.duration,
          curve: config.curve,
          maintainState: config.maintainState,
        );
    }
  }
}
