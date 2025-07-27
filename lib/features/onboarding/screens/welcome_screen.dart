import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/goal_selection_screen.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_progress_indicator.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Progress indicator
                  AnimatedOnboardingProgressIndicator(
                    currentStep: onboardingProvider.currentStep,
                    totalSteps: onboardingProvider.totalStepsCount,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // App Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.water_drop,
                        color: AppColors.waterFull,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Welcome Text
                  Text(
                    'Welcome to the\nHydration Tracker App',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      height: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Your intelligent hydration solutions.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSubtitle,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Illustration
                  Expanded(
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/icons/onboarding_elements/onboarding_bee_icon.svg',
                        width: 280,
                        height: 280,
                        placeholderBuilder: (BuildContext context) => Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.waterFull,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // Get Started Button
                  ContinueButton(
                    onPressed: () async {
                      await onboardingProvider.nextStep();
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const GoalSelectionScreen(),
                          ),
                        );
                      }
                    },
                    isDisabled: onboardingProvider.isSaving,
                  ),
                  
                  const SizedBox(height: 16),

                  // Skip Button
                  TextButton(
                    onPressed: () {
                      _showSkipDialog(context, onboardingProvider);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.waterFull,
                    ),
                    child: Text(
                      'Skip onboarding',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.waterFull,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSkipDialog(BuildContext context, OnboardingProvider provider) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Skip Onboarding?'),
          content: const Text(
            'Skipping onboarding means we won\'t be able to personalize your hydration goal. You can always set this up later in settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );
  }
}
