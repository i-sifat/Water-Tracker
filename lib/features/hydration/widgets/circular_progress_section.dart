import 'package:flutter/material.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/core/utils/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
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
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom painted circular progress
                CustomPaint(
                  size: const Size(280, 280),
                  painter: CircularProgressPainter(
                    progress: _progressAnimation.value,
                  ),
                ),
                // Center text content
                _buildCenterText(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main progress text (e.g., "1.75 L drank so far")
        Text(
          widget.progress.progressText,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textHeadline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Goal text (e.g., "from a total of 3 L")
        Text(
          widget.progress.goalText,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSubtitle,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Remaining text with reminder time
        Text(
          widget.progress.remainingText,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSubtitle,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.totalPages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index == widget.currentPage
                    ? AppColors.waterFull
                    : AppColors.genderUnselected,
          ),
        ),
      ),
    );
  }
}
