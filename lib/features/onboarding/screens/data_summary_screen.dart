import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/onboarding_completion_screen.dart';

// Helper function for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally ignore the future
}

class CompileDataScreen extends StatefulWidget {
  const CompileDataScreen({super.key});

  @override
  State<CompileDataScreen> createState() => _CompileDataScreenState();
}

class _CompileDataScreenState extends State<CompileDataScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _textController;
  late Animation<double> _progressAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  double _progress = 0;

  final List<String> _calculationSteps = [
    'Calculating basic intake for your profile...',
    'Adjusting goal based on your weight...',
    'Analyzing your activity level...',
    'Setting up smart reminder schedule...',
    'Finalizing your personalized plan...',
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // Start from right
      end: Offset.zero, // End at center
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _startCalculations();
  }

  void _startCalculations() {
    _progressController.forward();

    // Update progress and text every 600ms
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted) {
        setState(() {
          _progress = _progressAnimation.value * 100;

          // Update current step based on progress
          if (_progress < 20) {
            _currentStep = 0;
          } else if (_progress < 40) {
            _currentStep = 1;
          } else if (_progress < 60) {
            _currentStep = 2;
          } else if (_progress < 80) {
            _currentStep = 3;
          } else {
            _currentStep = 4;
          }
        });

        // Animate text change
        _textController
          ..reset()
          ..forward();

        // Complete when progress reaches 100%
        if (_progress >= 100) {
          timer.cancel();
          unawaited(_navigateToCompletion());
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _navigateToCompletion() async {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    final hydrationProvider = Provider.of<HydrationProvider>(
      context,
      listen: false,
    );

    try {
      // Complete onboarding process
      await onboardingProvider.completeOnboarding();

      // Update hydration provider with calculated goal
      final dailyGoal = onboardingProvider.userProfile.effectiveDailyGoal;
      await hydrationProvider.setDailyGoal(dailyGoal);

      if (!mounted) return;

      // Navigate to completion screen
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder:
              (context) => OnboardingCompletionScreen(dailyGoal: dailyGoal),
        ),
      ));
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing setup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'Generating your daily schedule...',
                style: AppTypography.headline.copyWith(
                  color: AppColors.textHeadline,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Circular Progress Indicator
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle with shadow
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.checkBoxCircle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                      ),

                      // Progress circle
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: _progressAnimation.value,
                              strokeWidth: 12,
                              backgroundColor: AppColors.textSubtitle
                                  .withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF7671FF),
                              ),
                            ),
                          );
                        },
                      ),

                      // Percentage text
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Text(
                            '${_progress.toInt()}%',
                            style: AppTypography.headline.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHeadline,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Animated calculation steps
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _textAnimation,
                      child: Column(
                        children: [
                          // Completed steps
                          ...List.generate(_currentStep, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: AppColors.goalGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _calculationSteps[index],
                                      style: AppTypography.subtitle.copyWith(
                                        color: AppColors.textSubtitle,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // Current step
                          if (_currentStep < _calculationSteps.length)
                            Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF7671FF),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _calculationSteps[_currentStep],
                                    style: AppTypography.subtitle.copyWith(
                                      color: AppColors.textHeadline,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
