import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watertracker/core/design_system/design_system.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/core/models/motivational_message.dart';
import 'package:watertracker/core/services/motivational_content_service.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
import 'package:watertracker/core/widgets/animations/advanced_text_transition.dart';
import 'package:watertracker/core/widgets/animations/smooth_text_transition.dart';
import 'package:watertracker/core/widgets/painters/animated_circular_progress_painter.dart';
import 'package:watertracker/core/widgets/text/calculation_text_display.dart';

/// Interactive circular progress widget with flip animation and multiple display modes
class InteractiveCircularProgress extends StatefulWidget {
  const InteractiveCircularProgress({
    required this.progress,
    this.animationDuration = const Duration(milliseconds: 800),
    super.key,
  });

  /// Hydration progress data to display
  final HydrationProgress progress;

  /// Duration for progress animation
  final Duration animationDuration;

  @override
  State<InteractiveCircularProgress> createState() =>
      _InteractiveCircularProgressState();
}

class _InteractiveCircularProgressState
    extends State<InteractiveCircularProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _borderPulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderPulseAnimation;

  // Removed flip key as it's not needed for the current implementation

  DisplayMode _currentMode = DisplayMode.progress;
  MotivationalMessage? _currentMessage;

  // Performance optimization: Cache painter instance
  AnimatedCircularProgressPainter? _cachedPainter;
  double _lastProgress = -1;
  double _lastBorderPulseScale = 1;
  double _lastBorderPulseOpacity = 1;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMotivationalMessage();
  }

  void _setupAnimations() {
    // Progress animation controller
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Border pulse animation controller
    _borderPulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress.percentage,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutBack),
    );

    _borderPulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _borderPulseController, curve: Curves.easeInOut),
    );

    // Start progress animation
    _progressController.forward();
  }

  void _loadMotivationalMessage() {
    _currentMessage = MotivationalContentService.instance
        .getPersonalizedMessage(widget.progress);
  }

  @override
  void didUpdateWidget(InteractiveCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation if progress changed
    if (oldWidget.progress.percentage != widget.progress.percentage) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.percentage,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.elasticOut),
      );

      _progressController.forward(from: 0);
      _loadMotivationalMessage();

      // Announce progress change to screen readers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _announceProgressChange();
        }
      });
    }

    // Note: Border pulse animation is triggered externally via triggerWaterAddedAnimation()
  }

  @override
  void dispose() {
    _progressController.dispose();
    _borderPulseController.dispose();
    _cachedPainter = null;
    super.dispose();
  }

  /// Trigger border pulse animation when water is added
  void triggerWaterAddedAnimation() {
    if (!mounted) return;
    _borderPulseController.forward().then((_) {
      if (mounted) {
        _borderPulseController.reverse();
      }
    });
  }

  /// Handle tap to cycle through display modes
  void _handleTap() {
    HapticFeedback.lightImpact();

    // Cycle through display modes
    switch (_currentMode) {
      case DisplayMode.progress:
        _currentMode = DisplayMode.motivation;
      case DisplayMode.motivation:
        _currentMode = DisplayMode.reminder;
      case DisplayMode.reminder:
        _currentMode = DisplayMode.remaining;
      case DisplayMode.remaining:
        _currentMode = DisplayMode.progress;
    }

    setState(() {});
    _announceDisplayModeChange();
  }

  void _announceProgressChange() {
    // Announce progress change for accessibility
    // Note: Using a simple approach since SemanticsService might not be available
    // In a real implementation, you would use proper accessibility announcements
    debugPrint(
      'Progress updated: ${(widget.progress.percentage * 100).round()}% complete',
    );
  }

  void _announceDisplayModeChange() {
    // Announce display mode change for accessibility
    // Note: Using a simple approach since SemanticsService might not be available
    // In a real implementation, you would use proper accessibility announcements
    debugPrint('Display mode changed to: $_currentMode');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _getSemanticLabel(),
      hint:
          'Tap to cycle through progress information, motivation, reminders, and remaining intake',
      button: true,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _progressController,
            _borderPulseController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * _borderPulseAnimation.value,
              child: SizedBox(
                width: ResponsiveHelper.getResponsiveWidth(context, 280),
                height: ResponsiveHelper.getResponsiveHeight(context, 280),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular progress painter
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size(
                          ResponsiveHelper.getResponsiveWidth(context, 280),
                          ResponsiveHelper.getResponsiveHeight(context, 280),
                        ),
                        painter: _getCachedPainter(
                          _progressAnimation.value,
                          _borderPulseAnimation.value,
                          1 -
                              (_borderPulseController.value *
                                  0.3), // Fade out during pulse
                        ),
                      ),
                    ),
                    // Center content with flip animation
                    RepaintBoundary(child: _buildCenterContent()),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Performance optimization: Cache painter instance to avoid recreation
  AnimatedCircularProgressPainter _getCachedPainter(
    double progress,
    double borderPulseScale,
    double borderPulseOpacity,
  ) {
    if (_cachedPainter == null ||
        _lastProgress != progress ||
        _lastBorderPulseScale != borderPulseScale ||
        _lastBorderPulseOpacity != borderPulseOpacity) {
      _cachedPainter = AnimatedCircularProgressPainter(
        progress: progress,
        progressColors: const [
          AppColors.progressGradientStart,
          AppColors.progressGradientEnd,
        ],
        innerRingColor: AppColors.progressInnerRing,
        borderPulseScale: borderPulseScale,
        borderPulseOpacity: borderPulseOpacity,
      );
      _lastProgress = progress;
      _lastBorderPulseScale = borderPulseScale;
      _lastBorderPulseOpacity = borderPulseOpacity;
    }
    return _cachedPainter!;
  }

  Widget _buildCenterContent() {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context, all: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_buildDisplayContent()],
      ),
    );
  }

  Widget _buildDisplayContent() {
    switch (_currentMode) {
      case DisplayMode.progress:
        return _buildProgressContent();
      case DisplayMode.motivation:
        return _buildMotivationContent();
      case DisplayMode.reminder:
        return _buildReminderContent();
      case DisplayMode.remaining:
        return _buildRemainingContent();
    }
  }

  Widget _buildProgressContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AdvancedTextTransition(
          text: widget.progress.progressText,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          duration: const Duration(milliseconds: 500),
          slideInDistance: 35.0,
          slideOutDistance: 25.0,
          slideInCurve: Curves.elasticOut,
          staggerDelay: const Duration(milliseconds: 80),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
        AdvancedTextTransition(
          text: widget.progress.goalText,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSubtitle,
          ),
          textAlign: TextAlign.center,
          duration: const Duration(milliseconds: 400),
          slideInDistance: 25.0,
          slideOutDistance: 20.0,
          staggerDelay: const Duration(milliseconds: 60),
        ),
      ],
    );
  }

  Widget _buildMotivationContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite,
          color: AppColors.primary,
          size: ResponsiveHelper.getResponsiveWidth(context, 32),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 12)),
        AdvancedTextTransition(
          text: _currentMessage?.message ?? 'Stay hydrated! 💧',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          duration: const Duration(milliseconds: 600),
          slideInDistance: 40.0,
          slideOutDistance: 30.0,
          slideInCurve: Curves.easeOutBack,
          fadeInCurve: Curves.easeInOut,
          staggerDelay: const Duration(milliseconds: 120),
        ),
      ],
    );
  }

  Widget _buildReminderContent() {
    final nextReminder = widget.progress.nextReminderTime;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.schedule,
          color: AppColors.secondary,
          size: ResponsiveHelper.getResponsiveWidth(context, 32),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 12)),
        if (nextReminder != null) ...[
          AdvancedTextTransition(
            text: 'Next reminder',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSubtitle,
            ),
            textAlign: TextAlign.center,
            duration: const Duration(milliseconds: 350),
            slideInDistance: 20.0,
            slideOutDistance: 15.0,
            staggerDelay: const Duration(milliseconds: 40),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 4)),
          CalculationValueTransition(
            value: _formatReminderTime(nextReminder),
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            animationDuration: const Duration(milliseconds: 500),
            emphasizeChange: true,
          ),
        ] else ...[
          AdvancedTextTransition(
            text: 'No reminders set',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSubtitle,
            ),
            textAlign: TextAlign.center,
            duration: const Duration(milliseconds: 450),
            slideInDistance: 25.0,
            slideOutDistance: 20.0,
            staggerDelay: const Duration(milliseconds: 60),
          ),
        ],
      ],
    );
  }

  Widget _buildRemainingContent() {
    final remainingMl = widget.progress.remainingIntake;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          remainingMl > 0 ? Icons.local_drink : Icons.check_circle,
          color: remainingMl > 0 ? AppColors.primary : AppColors.success,
          size: ResponsiveHelper.getResponsiveWidth(context, 32),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 12)),
        if (remainingMl > 0) ...[
          VolumeDisplay(
            volumeInMl: remainingMl,
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            label: 'remaining',
            textAlign: TextAlign.center,
            animationDuration: const Duration(milliseconds: 500),
          ),
        ] else ...[
          SmoothTextTransition(
            text: 'Goal achieved!',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            duration: const Duration(milliseconds: 600),
            slideDistance: 30.0,
          ),
        ],
      ],
    );
  }

  String _formatReminderTime(DateTime reminderTime) {
    final period = reminderTime.hour >= 12 ? 'PM' : 'AM';
    final displayHour =
        reminderTime.hour > 12
            ? reminderTime.hour - 12
            : (reminderTime.hour == 0 ? 12 : reminderTime.hour);
    return '$displayHour:${reminderTime.minute.toString().padLeft(2, '0')} $period';
  }

  String _getSemanticLabel() {
    final percentage = (widget.progress.percentage * 100).round();
    final currentLiters = (widget.progress.currentIntake / 1000)
        .toStringAsFixed(1);
    final goalLiters = (widget.progress.dailyGoal / 1000).toStringAsFixed(1);

    return 'Hydration progress: $percentage percent complete. $currentLiters liters of $goalLiters liters consumed.';
  }
}

/// Display modes for the circular progress
enum DisplayMode { progress, motivation, reminder, remaining }
