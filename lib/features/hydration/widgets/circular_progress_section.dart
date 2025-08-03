import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/design_system.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
import 'package:watertracker/core/widgets/performance/performance_monitor.dart';
import 'package:watertracker/features/hydration/widgets/interactive_circular_progress.dart';
import 'package:watertracker/core/design_system/accessibility/accessibility_helper.dart';

/// Widget that displays circular progress indicator with hydration information
/// and page indicator dots at the bottom
class CircularProgressSection extends StatefulWidget {
  const CircularProgressSection({
    required this.progress,
    super.key,
    this.currentPage = 1,
    this.totalPages = 3,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  /// Hydration progress data to display
  final HydrationProgress progress;

  /// Current page index for page indicator (0-based)
  final int currentPage;

  /// Total number of pages for page indicator
  final int totalPages;

  /// Duration for progress animation
  final Duration animationDuration;

  @override
  State<CircularProgressSection> createState() =>
      _CircularProgressSectionState();
}

class _CircularProgressSectionState extends State<CircularProgressSection> {
  final GlobalKey<_InteractiveCircularProgressState> _progressKey =
      GlobalKey<_InteractiveCircularProgressState>();

  /// Trigger water addition animation on the circular progress
  void triggerWaterAddedAnimation() {
    _progressKey.currentState?.triggerWaterAddedAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return OptimizedWidget(
      debugLabel: 'CircularProgressSection',
      enablePerformanceMonitoring: true,
      child: Column(
        children: [
          // Interactive circular progress with flip animation
          InteractiveCircularProgress(
            key: _progressKey,
            progress: widget.progress,
            animationDuration: widget.animationDuration,
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 32)),
          // Page indicator dots
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Semantics(
      label: 'Page ${widget.currentPage + 1} of ${widget.totalPages}',
      hint: 'Page indicator dots. Swipe up or down to navigate between pages.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.totalPages,
          (index) => Semantics(
            excludeSemantics: true, // Exclude individual dots from semantics
            child: Container(
              margin: ResponsiveHelper.getResponsiveMargin(
                context,
                horizontal: 4,
              ),
              width: ResponsiveHelper.getResponsiveWidth(context, 8),
              height: ResponsiveHelper.getResponsiveHeight(context, 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    index == widget.currentPage
                        ? AppColors.pageIndicatorActive
                        : AppColors.pageIndicatorInactive,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
