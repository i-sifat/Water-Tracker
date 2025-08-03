import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/navigation/optimized_page_controller.dart';
import 'package:watertracker/core/navigation/navigation_error_handler.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';

/// Optimized onboarding navigator with preloading and smooth transitions
class OnboardingNavigator extends StatefulWidget {
  final List<Widget> pages;
  final int totalSteps;

  const OnboardingNavigator({
    required this.pages,
    required this.totalSteps,
    super.key,
  });

  @override
  State<OnboardingNavigator> createState() => _OnboardingNavigatorState();

  /// Navigate to a specific step (for external access)
  static void navigateToStep(BuildContext context, int step) {
    final navigatorState =
        context.findAncestorStateOfType<_OnboardingNavigatorState>();
    navigatorState?._handleStepChange(step);
  }
}

class _OnboardingNavigatorState extends State<OnboardingNavigator>
    with OptimizedPageControllerMixin {
  int _lastStep = -1;
  bool _isTransitioning = false;
  final Map<int, Widget> _preloadedPages = {};

  @override
  void initState() {
    super.initState();
    // Preload the first few pages
    _preloadInitialPages();
  }

  /// Preload initial pages for faster startup
  void _preloadInitialPages() {
    for (int i = 0; i < 3 && i < widget.pages.length; i++) {
      _preloadedPages[i] = widget.pages[i];
    }
  }

  /// Preload adjacent pages for smoother transitions
  void _preloadAdjacentPages(int currentPage) {
    // Preload previous page
    if (currentPage > 0 && !_preloadedPages.containsKey(currentPage - 1)) {
      _preloadedPages[currentPage - 1] = widget.pages[currentPage - 1];
    }

    // Preload next page
    if (currentPage < widget.pages.length - 1 &&
        !_preloadedPages.containsKey(currentPage + 1)) {
      _preloadedPages[currentPage + 1] = widget.pages[currentPage + 1];
    }

    // Clean up pages that are too far away to save memory
    _cleanupDistantPages(currentPage);
  }

  /// Clean up preloaded pages that are far from current page
  void _cleanupDistantPages(int currentPage) {
    final keysToRemove = <int>[];
    for (final key in _preloadedPages.keys) {
      if ((key - currentPage).abs() > 2) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _preloadedPages.remove(key);
    }
  }

  /// Handle step changes with optimized transitions and error handling
  Future<void> _handleStepChange(int newStep) async {
    if (_isTransitioning || newStep == _lastStep) return;

    _isTransitioning = true;

    try {
      // Preload adjacent pages before transition
      _preloadAdjacentPages(newStep);

      // Set timeout for navigation
      final navigationFuture = safeAnimateToPage(
        newStep,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );

      final success = await navigationFuture.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Handle navigation timeout
          if (mounted) {
            final provider = Provider.of<OnboardingProvider>(
              context,
              listen: false,
            );
            provider.handleNavigationTimeout();
          }
          return false;
        },
      );

      if (success) {
        _lastStep = newStep;
      } else {
        // Handle navigation failure
        await _handleNavigationFailure(newStep);
      }
    } catch (e, stackTrace) {
      // Handle navigation error
      await _handleNavigationError(e, stackTrace, newStep);
    } finally {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    }
  }

  /// Handle navigation failure
  Future<void> _handleNavigationFailure(int targetStep) async {
    if (!mounted) return;

    final error = NavigationErrorDetails(
      type: NavigationError.pageLoadFailed,
      message: 'Failed to navigate to step $targetStep',
      context: {'currentStep': _lastStep, 'targetStep': targetStep},
    );

    await NavigationErrorHandler.handleError(
      error,
      context: context,
      onRetry: () => _handleStepChange(targetStep),
      onFallback: () {
        // Go back to previous step
        if (_lastStep > 0) {
          safeJumpToPage(_lastStep - 1);
        }
      },
    );
  }

  /// Handle navigation error
  Future<void> _handleNavigationError(
    dynamic error,
    StackTrace stackTrace,
    int targetStep,
  ) async {
    if (!mounted) return;

    final errorDetails = NavigationErrorDetails(
      type: NavigationError.pageLoadFailed,
      message: 'Navigation error: $error',
      stackTrace: stackTrace,
      context: {'currentStep': _lastStep, 'targetStep': targetStep},
    );

    await NavigationErrorHandler.handleError(
      errorDetails,
      context: context,
      onRetry: () => _handleStepChange(targetStep),
      onFallback: () {
        final provider = Provider.of<OnboardingProvider>(
          context,
          listen: false,
        );
        provider.recoverFromNavigationError();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        // Handle step changes
        if (provider.currentStep != _lastStep && !_isTransitioning) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStepChange(provider.currentStep);
          });
        }

        return PageView.builder(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.totalSteps,
          itemBuilder: (context, index) {
            // Return preloaded page if available, otherwise build on demand
            if (_preloadedPages.containsKey(index)) {
              return _preloadedPages[index]!;
            }

            // Build page on demand and cache it
            if (index < widget.pages.length) {
              final page = widget.pages[index];
              _preloadedPages[index] = page;
              return page;
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _preloadedPages.clear();
    super.dispose();
  }
}

/// Enhanced PageView with better performance characteristics
class OptimizedPageView extends StatefulWidget {
  final PageController controller;
  final List<Widget> children;
  final ValueChanged<int>? onPageChanged;
  final ScrollPhysics? physics;
  final bool allowImplicitScrolling;

  const OptimizedPageView({
    required this.controller,
    required this.children,
    this.onPageChanged,
    this.physics,
    this.allowImplicitScrolling = false,
    super.key,
  });

  @override
  State<OptimizedPageView> createState() => _OptimizedPageViewState();
}

class _OptimizedPageViewState extends State<OptimizedPageView> {
  final Map<int, Widget> _cachedPages = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.controller.initialPage;
    _preloadVisiblePages();
  }

  void _preloadVisiblePages() {
    // Preload current and adjacent pages
    for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
      if (i >= 0 && i < widget.children.length) {
        _cachedPages[i] = widget.children[i];
      }
    }
  }

  void _onPageChanged(int page) {
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });

      // Preload new adjacent pages
      _preloadVisiblePages();

      // Clean up distant pages
      _cleanupDistantPages(page);

      widget.onPageChanged?.call(page);
    }
  }

  void _cleanupDistantPages(int currentPage) {
    final keysToRemove = <int>[];
    for (final key in _cachedPages.keys) {
      if ((key - currentPage).abs() > 2) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _cachedPages.remove(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      physics: widget.physics,
      allowImplicitScrolling: widget.allowImplicitScrolling,
      onPageChanged: _onPageChanged,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        // Return cached page if available
        if (_cachedPages.containsKey(index)) {
          return _cachedPages[index]!;
        }

        // Build and cache page
        if (index < widget.children.length) {
          final page = widget.children[index];
          _cachedPages[index] = page;
          return page;
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _cachedPages.clear();
    super.dispose();
  }
}
