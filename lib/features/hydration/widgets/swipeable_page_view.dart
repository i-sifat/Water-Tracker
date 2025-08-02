import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';

/// Custom scroll physics for vertical swipe navigation with boundary handling
class SwipeableScrollPhysics extends ScrollPhysics {
  const SwipeableScrollPhysics({super.parent});

  @override
  SwipeableScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SwipeableScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Prevent over-scrolling beyond boundaries
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      return value - position.maxScrollExtent;
    }
    return 0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Custom ballistic simulation for smooth page snapping
    final tolerance = toleranceFor(position);

    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Snap to nearest page if velocity is low
    final pageSize = position.viewportDimension;
    final currentPage = (position.pixels / pageSize).round();
    final targetPixels = currentPage * pageSize;

    if ((position.pixels - targetPixels).abs() > tolerance.distance) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        targetPixels,
        velocity,
        tolerance: tolerance,
      );
    }

    return null;
  }
}

/// Swipeable page view component for vertical navigation between hydration pages
/// Supports swipe up to history, swipe down to goal breakdown, with smooth animations
class SwipeablePageView extends StatefulWidget {
  const SwipeablePageView({
    required this.pages,
    super.key,
    this.initialPage = 1,
    this.controller,
    this.onPageChanged,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeInOutCubic,
  });

  /// List of pages to display (typically 3: history, main, goal breakdown)
  final List<Widget> pages;

  /// Initial page index (default is 1 for main page)
  final int initialPage;

  /// Callback when page changes
  final ValueChanged<int>? onPageChanged;

  /// Optional external page controller
  final PageController? controller;

  /// Duration for page transition animations
  final Duration animationDuration;

  /// Curve for page transition animations
  final Curve animationCurve;

  @override
  State<SwipeablePageView> createState() => _SwipeablePageViewState();
}

class _SwipeablePageViewState extends State<SwipeablePageView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _gestureAnimationController;
  late Animation<double> _gestureAnimation;

  int _currentPage = 1;
  bool _isAnimating = false;
  double _gestureOffset = 0;

  // Performance optimization: Cache gesture detection thresholds
  static const double _swipeThreshold = 100;
  static const double _velocityThreshold = 500;
  static const double _hapticThreshold = 50;

  // Performance optimization: Debounce haptic feedback
  DateTime _lastHapticFeedback = DateTime.now();
  static const Duration _hapticDebounceTime = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();

    _currentPage = widget.initialPage;
    _pageController =
        widget.controller ?? PageController(initialPage: widget.initialPage);

    // Animation controller for gesture feedback
    _gestureAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _gestureAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _gestureAnimationController,
        curve: widget.animationCurve,
      ),
    );

    // Listen to page controller changes
    _pageController.addListener(_onPageControllerChanged);
  }

  @override
  void dispose() {
    // Performance optimization: Proper cleanup of all resources
    _pageController.removeListener(_onPageControllerChanged);
    if (widget.controller == null) {
      _pageController.dispose();
    }
    _gestureAnimationController.dispose();
    super.dispose();
  }

  void _onPageControllerChanged() {
    if (_pageController.hasClients) {
      final page = _pageController.page;
      if (page != null) {
        final newPage = page.round();
        if (newPage != _currentPage && !_isAnimating) {
          setState(() {
            _currentPage = newPage;
          });
          widget.onPageChanged?.call(newPage);

          // Announce page change to screen readers
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && newPage < AccessibilityUtils.pageNames.length) {
              AccessibilityUtils.announcePageChange(
                context,
                AccessibilityUtils.pageNames[newPage],
              );
            }
          });
        }
      }
    }
  }

  /// Navigate to specific page with animation
  Future<void> animateToPage(int page) async {
    if (_isAnimating || page == _currentPage) return;

    setState(() {
      _isAnimating = true;
    });

    // Provide haptic feedback
    await HapticFeedback.lightImpact();

    try {
      await _pageController.animateToPage(
        page,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    }
  }

  /// Handle vertical pan gestures for swipe navigation
  /// Performance optimization: Optimized gesture handling for 60fps
  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;

    final delta = details.delta.dy;
    setState(() {
      _gestureOffset += delta;
    });

    // Performance optimization: Debounced haptic feedback
    final now = DateTime.now();
    if (_gestureOffset.abs() > _hapticThreshold &&
        _gestureOffset.abs() < _hapticThreshold + 10 &&
        now.difference(_lastHapticFeedback) > _hapticDebounceTime) {
      HapticFeedback.selectionClick();
      _lastHapticFeedback = now;
    }
  }

  /// Handle end of pan gesture to determine page navigation
  /// Performance optimization: Use cached thresholds for better performance
  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final velocity = details.velocity.pixelsPerSecond.dy;
    int? targetPage;

    // Performance optimization: Use cached threshold constants
    if (_gestureOffset < -_swipeThreshold || velocity < -_velocityThreshold) {
      // Swipe up - go to previous page (history)
      if (_currentPage > 0) {
        targetPage = _currentPage - 1;
      }
    } else if (_gestureOffset > _swipeThreshold ||
        velocity > _velocityThreshold) {
      // Swipe down - go to next page (goal breakdown)
      if (_currentPage < widget.pages.length - 1) {
        targetPage = _currentPage + 1;
      }
    }

    // Reset gesture offset
    setState(() {
      _gestureOffset = 0;
    });

    // Navigate to target page if determined
    if (targetPage != null) {
      animateToPage(targetPage);
    } else {
      // Animate back to current page if gesture was insufficient
      _gestureAnimationController.forward().then((_) {
        if (mounted) {
          _gestureAnimationController.reverse();
        }
      });
    }
  }

  /// Build page indicator dots
  Widget _buildPageIndicator() {
    return Semantics(
      label: AccessibilityUtils.createPageIndicatorLabel(
        _currentPage,
        widget.pages.length,
        AccessibilityUtils.pageNames,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.pages.length, (index) {
          final isActive = index == _currentPage;
          return Semantics(
            excludeSemantics: true, // Parent handles semantics
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Swipeable page view',
      hint:
          'Swipe up or down to navigate between pages. Current page: ${AccessibilityUtils.pageNames[_currentPage]}',
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            // Performance optimization: RepaintBoundary around PageView
            RepaintBoundary(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const SwipeableScrollPhysics(),
                itemCount: widget.pages.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  widget.onPageChanged?.call(page);
                },
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _gestureAnimation,
                    builder: (context, child) {
                      // Apply gesture offset for visual feedback
                      var offset = 0.0;
                      if (index == _currentPage) {
                        offset = _gestureOffset * 0.1; // Subtle movement
                      }

                      // Performance optimization: RepaintBoundary around each page
                      return RepaintBoundary(
                        child: Transform.translate(
                          offset: Offset(0, offset),
                          child: widget.pages[index],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Performance optimization: RepaintBoundary around page indicator
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildPageIndicator(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension methods for SwipeablePageView controller
extension SwipeablePageViewExtension on PageController {
  /// Check if can swipe up (to previous page)
  bool get canSwipeUp => hasClients && (page?.round() ?? 0) > 0;

  /// Check if can swipe down (to next page)
  bool canSwipeDown(int totalPages) =>
      hasClients && (page?.round() ?? 0) < totalPages - 1;

  /// Get current page index safely
  int get currentPageIndex => hasClients ? (page?.round() ?? 0) : 0;
}
