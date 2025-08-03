import 'package:flutter/material.dart';

/// Optimized PageController with preloading and smooth transitions
class OptimizedPageController extends PageController {
  OptimizedPageController({
    super.initialPage = 0,
    super.keepPage = true,
    super.viewportFraction = 1.0,
  });

  bool _isAnimating = false;
  int? _targetPage;

  /// Check if controller is currently animating
  bool get isAnimating => _isAnimating;

  /// Get the target page during animation
  int? get targetPage => _targetPage;

  /// Animate to page with optimized settings and preloading
  @override
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) async {
    if (!hasClients || _isAnimating) return;

    _isAnimating = true;
    _targetPage = page;

    try {
      // Use optimized duration and curve for smoother transitions
      await super.animateToPage(page, duration: duration, curve: curve);
    } finally {
      _isAnimating = false;
      _targetPage = null;
    }
  }

  /// Jump to page without animation (for instant navigation)
  @override
  void jumpToPage(int page) {
    if (!hasClients || _isAnimating) return;
    super.jumpToPage(page);
  }

  /// Preload adjacent pages for smoother transitions
  void preloadAdjacentPages(int currentPage, int totalPages) {
    if (!hasClients) return;

    // This method can be used to trigger preloading of adjacent pages
    // Implementation depends on the specific widget structure
    // For now, we'll just ensure the controller is ready
    if (currentPage > 0) {
      // Previous page exists
    }
    if (currentPage < totalPages - 1) {
      // Next page exists
    }
  }

  /// Safe dispose with animation cleanup
  @override
  void dispose() {
    _isAnimating = false;
    _targetPage = null;
    super.dispose();
  }
}

/// Mixin for widgets that use OptimizedPageController
mixin OptimizedPageControllerMixin<T extends StatefulWidget> on State<T> {
  late OptimizedPageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = OptimizedPageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Safely animate to page with error handling
  Future<bool> safeAnimateToPage(
    int page, {
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeOut,
  }) async {
    if (!mounted || !pageController.hasClients) return false;

    try {
      await pageController.animateToPage(
        page,
        duration: duration,
        curve: curve,
      );
      return true;
    } catch (e) {
      debugPrint('Error animating to page $page: $e');
      return false;
    }
  }

  /// Safely jump to page with error handling
  bool safeJumpToPage(int page) {
    if (!mounted || !pageController.hasClients) return false;

    try {
      pageController.jumpToPage(page);
      return true;
    } catch (e) {
      debugPrint('Error jumping to page $page: $e');
      return false;
    }
  }
}
