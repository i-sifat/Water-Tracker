import 'package:flutter/material.dart';

/// Optimized page transitions for better performance and user experience
class PageTransitions {
  /// Fast slide transition with reduced animation duration
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 250),
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
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

  /// Fade transition with optimized performance
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        );
      },
    );
  }

  /// Scale transition for modal-like pages
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    double begin = 0.8,
    double end = 1.0,
    Curve curve = Curves.easeOutBack,
    Alignment alignment = Alignment.center,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        final fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        );
        
        return ScaleTransition(
          scale: animation.drive(scaleTween),
          alignment: alignment,
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// No transition for instant navigation (best performance)
  static PageRouteBuilder<T> noTransition<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  /// Custom transition with performance optimizations
  static PageRouteBuilder<T> customTransition<T>({
    required Widget page,
    required Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) transitionsBuilder,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
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
      transitionsBuilder: transitionsBuilder,
    );
  }

  /// Optimized bottom sheet transition
  static PageRouteBuilder<T> bottomSheetTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Hero transition for shared element animations
  static PageRouteBuilder<T> heroTransition<T>({
    required Widget page,
    required String heroTag,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

/// Extension methods for easier navigation with optimized transitions
extension NavigatorExtensions on NavigatorState {
  /// Push with slide transition
  Future<T?> pushSlide<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    Offset? begin,
  }) {
    return push<T>(PageTransitions.slideTransition<T>(
      page: page,
      settings: settings,
      duration: duration ?? const Duration(milliseconds: 250),
      begin: begin ?? const Offset(1.0, 0.0),
    ));
  }

  /// Push with fade transition
  Future<T?> pushFade<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
  }) {
    return push<T>(PageTransitions.fadeTransition<T>(
      page: page,
      settings: settings,
      duration: duration ?? const Duration(milliseconds: 200),
    ));
  }

  /// Push with scale transition
  Future<T?> pushScale<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Duration? duration,
    double? begin,
  }) {
    return push<T>(PageTransitions.scaleTransition<T>(
      page: page,
      settings: settings,
      duration: duration ?? const Duration(milliseconds: 300),
      begin: begin ?? 0.8,
    ));
  }

  /// Push with no transition (instant)
  Future<T?> pushInstant<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return push<T>(PageTransitions.noTransition<T>(
      page: page,
      settings: settings,
    ));
  }

  /// Push replacement with slide transition
  Future<T?> pushReplacementSlide<T extends Object?, TO extends Object?>(
    Widget page, {
    RouteSettings? settings,
    TO? result,
    Duration? duration,
  }) {
    return pushReplacement<T, TO>(PageTransitions.slideTransition<T>(
      page: page,
      settings: settings,
      duration: duration ?? const Duration(milliseconds: 250),
    ), result: result);
  }

  /// Push replacement with fade transition
  Future<T?> pushReplacementFade<T extends Object?, TO extends Object?>(
    Widget page, {
    RouteSettings? settings,
    TO? result,
    Duration? duration,
  }) {
    return pushReplacement<T, TO>(PageTransitions.fadeTransition<T>(
      page: page,
      settings: settings,
      duration: duration ?? const Duration(milliseconds: 200),
    ), result: result);
  }

  /// Push replacement with no transition (instant)
  Future<T?> pushReplacementInstant<T extends Object?, TO extends Object?>(
    Widget page, {
    RouteSettings? settings,
    TO? result,
  }) {
    return pushReplacement<T, TO>(PageTransitions.noTransition<T>(
      page: page,
      settings: settings,
    ), result: result);
  }
}

/// Mixin for widgets that need optimized navigation
mixin OptimizedNavigationMixin<T extends StatefulWidget> on State<T> {
  /// Navigate with performance monitoring
  Future<R?> navigateWithPerformance<R extends Object?>(
    Widget page, {
    String? operationName,
    bool useSlideTransition = true,
    Duration? duration,
  }) async {
    final operation = operationName ?? 'navigation_${page.runtimeType}';
    
    // Start performance monitoring
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = useSlideTransition
          ? await Navigator.of(context).pushSlide<R>(page, duration: duration)
          : await Navigator.of(context).pushFade<R>(page, duration: duration);
      
      return result;
    } finally {
      stopwatch.stop();
      
      // Log slow navigations
      if (stopwatch.elapsedMilliseconds > 500) {
        debugPrint('Slow navigation to ${page.runtimeType}: ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }

  /// Navigate and replace with performance monitoring
  Future<R?> navigateAndReplaceWithPerformance<R extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
    String? operationName,
    bool useSlideTransition = true,
    Duration? duration,
  }) async {
    final operation = operationName ?? 'navigation_replace_${page.runtimeType}';
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final navigationResult = useSlideTransition
          ? await Navigator.of(context).pushReplacementSlide<R, TO>(
              page,
              result: result,
              duration: duration,
            )
          : await Navigator.of(context).pushReplacementFade<R, TO>(
              page,
              result: result,
              duration: duration,
            );
      
      return navigationResult;
    } finally {
      stopwatch.stop();
      
      if (stopwatch.elapsedMilliseconds > 500) {
        debugPrint('Slow navigation replace to ${page.runtimeType}: ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }
}

/// Prebuilt route configurations for common navigation patterns
class AppRoutes {
  /// Route for onboarding flow (no transition for speed)
  static Route<T> onboardingRoute<T>(Widget page) {
    return PageTransitions.noTransition<T>(page: page);
  }

  /// Route for main app screens (slide transition)
  static Route<T> mainRoute<T>(Widget page) {
    return PageTransitions.slideTransition<T>(
      page: page,
      duration: const Duration(milliseconds: 200),
    );
  }

  /// Route for modal screens (scale transition)
  static Route<T> modalRoute<T>(Widget page) {
    return PageTransitions.scaleTransition<T>(
      page: page,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// Route for settings screens (fade transition)
  static Route<T> settingsRoute<T>(Widget page) {
    return PageTransitions.fadeTransition<T>(
      page: page,
      duration: const Duration(milliseconds: 150),
    );
  }
}