import 'package:flutter/material.dart';

/// Cache for commonly used animations to improve performance
class AnimationCache {
  static final Map<String, AnimationController> _controllerCache = {};
  static final Map<String, Animation<double>> _animationCache = {};
  static final Map<String, Tween<double>> _tweenCache = {};

  /// Get or create a cached animation controller
  static AnimationController getCachedController({
    required String key,
    required Duration duration,
    required TickerProvider vsync,
    double? value,
    Duration? reverseDuration,
    AnimationBehavior? animationBehavior,
  }) {
    if (_controllerCache.containsKey(key)) {
      final controller = _controllerCache[key]!;
      // Update duration if different
      if (controller.duration != duration) {
        controller.duration = duration;
      }
      return controller;
    }

    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
      value: value,
      reverseDuration: reverseDuration,
      animationBehavior: animationBehavior ?? AnimationBehavior.normal,
    );

    _controllerCache[key] = controller;
    return controller;
  }

  /// Get or create a cached tween
  static Tween<double> getCachedTween({
    required String key,
    required double begin,
    required double end,
  }) {
    final cacheKey = '${key}_${begin}_$end';

    if (_tweenCache.containsKey(cacheKey)) {
      return _tweenCache[cacheKey]!;
    }

    final tween = Tween<double>(begin: begin, end: end);
    _tweenCache[cacheKey] = tween;
    return tween;
  }

  /// Get or create a cached animation
  static Animation<double> getCachedAnimation({
    required String key,
    required AnimationController controller,
    required Tween<double> tween,
    Curve curve = Curves.linear,
  }) {
    final cacheKey = '${key}_${curve.runtimeType}';

    if (_animationCache.containsKey(cacheKey)) {
      final animation = _animationCache[cacheKey]!;
      // Return cached animation (we'll assume it's still valid)
      return animation;
    }

    final animation = tween.animate(
      CurvedAnimation(parent: controller, curve: curve),
    );

    _animationCache[cacheKey] = animation;
    return animation;
  }

  /// Clear specific cached items
  static void clearCache({String? key}) {
    if (key != null) {
      _controllerCache.remove(key);
      _animationCache.remove(key);
      _tweenCache.remove(key);
    } else {
      // Clear all caches
      _controllerCache.clear();
      _animationCache.clear();
      _tweenCache.clear();
    }
  }

  /// Dispose all cached controllers (call this when the app is closing)
  static void disposeAll() {
    for (final controller in _controllerCache.values) {
      controller.dispose();
    }
    clearCache();
  }

  /// Get cache statistics for debugging
  static Map<String, int> getCacheStats() {
    return {
      'controllers': _controllerCache.length,
      'animations': _animationCache.length,
      'tweens': _tweenCache.length,
    };
  }
}

/// Common animation presets for reuse
class CommonAnimations {
  /// Standard scale animation for tap effects
  static Animation<double> getTapScaleAnimation({
    required AnimationController controller,
    double scale = 0.95,
  }) {
    return AnimationCache.getCachedAnimation(
      key: 'tap_scale_$scale',
      controller: controller,
      tween: AnimationCache.getCachedTween(
        key: 'scale',
        begin: 1.0,
        end: scale,
      ),
      curve: Curves.easeInOut,
    );
  }

  /// Standard fade animation
  static Animation<double> getFadeAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return AnimationCache.getCachedAnimation(
      key: 'fade_${begin}_$end',
      controller: controller,
      tween: AnimationCache.getCachedTween(key: 'fade', begin: begin, end: end),
      curve: Curves.easeIn,
    );
  }

  /// Standard slide animation
  static Animation<Offset> getSlideAnimation({
    required AnimationController controller,
    required Offset begin,
    required Offset end,
    Curve curve = Curves.easeOutCubic,
  }) {
    // For slide animations, we need a different cache since it's Animation<Offset>
    final tween = Tween<Offset>(begin: begin, end: end);
    return tween.animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// Standard rotation animation
  static Animation<double> getRotationAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return AnimationCache.getCachedAnimation(
      key: 'rotation_${begin}_$end',
      controller: controller,
      tween: AnimationCache.getCachedTween(
        key: 'rotation',
        begin: begin,
        end: end,
      ),
      curve: Curves.easeInOut,
    );
  }
}

/// Mixin for widgets that want to use cached animations
mixin CachedAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  final List<String> _cacheKeys = [];

  /// Get a cached animation controller with automatic cleanup
  AnimationController getCachedController({
    required String key,
    required Duration duration,
    double? value,
    Duration? reverseDuration,
    AnimationBehavior? animationBehavior,
  }) {
    _cacheKeys.add(key);
    return AnimationCache.getCachedController(
      key: key,
      duration: duration,
      vsync: this,
      value: value,
      reverseDuration: reverseDuration,
      animationBehavior: animationBehavior,
    );
  }

  @override
  void dispose() {
    // Clean up cached items for this widget
    for (final key in _cacheKeys) {
      AnimationCache.clearCache(key: key);
    }
    super.dispose();
  }
}

/// Performance-optimized animation builder that reuses common patterns
class OptimizedAnimationBuilder extends StatelessWidget {
  const OptimizedAnimationBuilder({
    required this.animation,
    required this.builder,
    super.key,
    this.child,
  });

  final Animation<double> animation;
  final Widget Function(BuildContext context, double value, Widget? child)
  builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => builder(context, animation.value, child),
      child: child,
    );
  }
}
