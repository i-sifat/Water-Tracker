import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';

/// Custom progress indicator for onboarding flow
class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 4.0,
    this.backgroundColor,
    this.progressColor,
    this.showStepNumbers = true,
  });

  final int currentStep;
  final int totalSteps;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showStepNumbers;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;
    
    return Column(
      children: [
        if (showStepNumbers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${currentStep + 1} of $totalSteps',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSubtitle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.waterFull,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.unselectedBorder,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor ?? AppColors.waterFull,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated progress indicator with smooth transitions
class AnimatedOnboardingProgressIndicator extends StatefulWidget {
  const AnimatedOnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 4.0,
    this.backgroundColor,
    this.progressColor,
    this.showStepNumbers = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  final int currentStep;
  final int totalSteps;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showStepNumbers;
  final Duration animationDuration;

  @override
  State<AnimatedOnboardingProgressIndicator> createState() =>
      _AnimatedOnboardingProgressIndicatorState();
}

class _AnimatedOnboardingProgressIndicatorState
    extends State<AnimatedOnboardingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _previousStep = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _updateAnimation();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedOnboardingProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _previousStep = oldWidget.currentStep;
      _updateAnimation();
      _animationController.forward(from: 0);
    }
  }

  void _updateAnimation() {
    final previousProgress = (_previousStep + 1) / widget.totalSteps;
    final currentProgress = (widget.currentStep + 1) / widget.totalSteps;
    
    _progressAnimation = Tween<double>(
      begin: previousProgress,
      end: currentProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            if (widget.showStepNumbers)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${widget.currentStep + 1} of ${widget.totalSteps}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSubtitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(_progressAnimation.value * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.waterFull,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.unselectedBorder,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.progressColor ?? AppColors.waterFull,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Step-by-step progress indicator with individual step markers
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.completedSteps = const {},
    this.stepSize = 24.0,
    this.lineHeight = 2.0,
    this.completedColor,
    this.activeColor,
    this.inactiveColor,
    this.showLabels = false,
    this.labels = const [],
  });

  final int currentStep;
  final int totalSteps;
  final Set<int> completedSteps;
  final double stepSize;
  final double lineHeight;
  final Color? completedColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showLabels;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCol = completedColor ?? AppColors.waterFull;
    final activeCol = activeColor ?? AppColors.waterFull;
    final inactiveCol = inactiveColor ?? AppColors.unselectedBorder;

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = completedSteps.contains(index);
            final isActive = index == currentStep;
            final isPast = index < currentStep;
            
            Color stepColor;
            if (isCompleted || isPast) {
              stepColor = completedCol;
            } else if (isActive) {
              stepColor = activeCol;
            } else {
              stepColor = inactiveCol;
            }

            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: stepSize,
                    height: stepSize,
                    decoration: BoxDecoration(
                      color: stepColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: stepColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted || isPast
                          ? Icon(
                              Icons.check,
                              size: stepSize * 0.6,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isActive ? Colors.white : stepColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: lineHeight,
                        color: isPast ? completedCol : inactiveCol,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        if (showLabels && labels.length >= totalSteps)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: List.generate(totalSteps, (index) {
                return Expanded(
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: index <= currentStep
                          ? AppColors.assessmentText
                          : AppColors.textSubtitle,
                      fontWeight: index == currentStep
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}