import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/utils/performance_utils.dart';
import 'package:watertracker/core/widgets/painters/circular_progress_painter.dart';

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

class _CircularProgressSectionState extends State<CircularProgressSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  // Performance optimization: Cache painter instance
  CircularProgressPainter? _cachedPainter;
  double _lastProgress = -1;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Performance optimization: Use monitored animation controller
    _animationController = PerformanceUtils.createMonitoredAnimationController(
      duration: widget.animationDuration,
      vsync: this,
      debugLabel: 'CircularProgressAnimation',
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress.percentage,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CircularProgressSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation if progress changed
    if (oldWidget.progress.percentage != widget.progress.percentage) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.percentage,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      );

      _animationController.forward(from: 0);

      // Announce progress change to screen readers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AccessibilityUtils.announceProgressChange(
            context,
            widget.progress.currentIntake,
            widget.progress.dailyGoal,
            widget.progress.percentage,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // Performance optimization: Proper animation controller disposal
    _animationController.dispose();
    _cachedPainter = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular progress with center text
        _buildCircularProgress(),
        const SizedBox(height: 32),
        // Page indicator dots
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildCircularProgress() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Semantics(
          label: AccessibilityUtils.createProgressLabel(
            widget.progress.percentage,
            widget.progress.currentIntake,
            widget.progress.dailyGoal,
          ),
          value: '${(widget.progress.percentage * 100).round()}%',
          hint: 'Circular progress indicator showing daily hydration progress',
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Performance optimization: RepaintBoundary around frequently updating painter
                  PerformanceUtils.optimizedRepaintBoundary(
                    debugLabel: 'CircularProgressPainter',
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: _getCachedPainter(_progressAnimation.value),
                    ),
                  ),
                  // Performance optimization: RepaintBoundary around center text
                  PerformanceUtils.optimizedRepaintBoundary(
                    debugLabel: 'CircularProgressCenterText',
                    child: _buildCenterText(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Performance optimization: Cache painter instance to avoid recreation
  CircularProgressPainter _getCachedPainter(double progress) {
    if (_cachedPainter == null || _lastProgress != progress) {
      _cachedPainter = CircularProgressPainter(progress: progress);
      _lastProgress = progress;
    }
    return _cachedPainter!;
  }

  Widget _buildCenterText() {
    return Semantics(
      excludeSemantics: true, // Exclude from semantics as parent handles it
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main progress text (e.g., "1.75 L drank so far")
          AccessibilityUtils.createAccessibleText(
            text: widget.progress.progressText,
            style: AppTypography.progressMainText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Goal text (e.g., "from a total of 3 L")
          AccessibilityUtils.createAccessibleText(
            text: widget.progress.goalText,
            style: AppTypography.progressSubText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Remaining text with reminder time
          AccessibilityUtils.createAccessibleText(
            text: widget.progress.remainingText,
            style: AppTypography.progressSmallText,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Semantics(
      label: AccessibilityUtils.createPageIndicatorLabel(
        widget.currentPage,
        widget.totalPages,
        AccessibilityUtils.pageNames,
      ),
      hint: 'Page indicator dots. Swipe up or down to navigate between pages.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.totalPages,
          (index) => Semantics(
            excludeSemantics: true, // Exclude individual dots from semantics
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
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
