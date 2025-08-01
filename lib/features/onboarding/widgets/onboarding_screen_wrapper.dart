import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_progress_indicator.dart';

/// Wrapper widget that provides consistent layout and navigation for onboarding screens
class OnboardingScreenWrapper extends StatelessWidget {
  const OnboardingScreenWrapper({
    required this.child,
    super.key,
    this.title,
    this.subtitle,
    this.showProgress = true,
    this.showBackButton = true,
    this.showSkipButton = false,
    this.onContinue,
    this.onSkip,
    this.continueButtonText = 'Continue',
    this.skipButtonText = 'Skip',
    this.canContinue = true,
    this.isLoading = false,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showProgress;
  final bool showBackButton;
  final bool showSkipButton;
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;
  final String continueButtonText;
  final String skipButtonText;
  final bool canContinue;
  final bool isLoading;
  final Color? backgroundColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, _) {
        return Scaffold(
          backgroundColor: backgroundColor ?? Colors.white,
          appBar: _buildAppBar(context, onboardingProvider),
          body: Column(
            children: [
              // Progress indicator
              if (showProgress)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: AnimatedOnboardingProgressIndicator(
                    currentStep: onboardingProvider.currentStep,
                    totalSteps: onboardingProvider.totalStepsCount,
                    showStepNumbers: false,
                  ),
                ),

              // Error message
              if (onboardingProvider.error != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          onboardingProvider.error!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onboardingProvider.clearError,
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.red[700],
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

              // Header
              if (title != null || subtitle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textHeadline,
                            height: 1.2,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSubtitle,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Main content
              Expanded(child: Padding(padding: padding, child: child)),

              // Bottom navigation
              _buildBottomNavigation(context, onboardingProvider),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    OnboardingProvider provider,
  ) {
    if (!showBackButton && provider.currentStep == 0) return null;

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      leading:
          showBackButton && provider.currentStep > 0
              ? Container(
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.assessmentText,
                  ),
                  onPressed: () {
                    provider.navigatePrevious();
                  },
                ),
              )
              : null,
      title: const Text(
        'Assessment',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeadline,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${provider.currentStep + 1} of ${provider.totalStepsCount}',
            style: const TextStyle(
              color: AppColors.pageCounter,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    OnboardingProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Skip button (if enabled and step is optional)
          if (showSkipButton && provider.canSkipCurrent)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed:
                      isLoading ? null : (onSkip ?? () => provider.skipStep()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSubtitle,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    skipButtonText,
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ContinueButton(
              onPressed: (canContinue && !isLoading)
                  ? (onContinue ?? () => provider.navigateNext())
                  : () {},
              isDisabled: !(canContinue && !isLoading),
            ),
          ),

          // Skip onboarding option (only on first screen)
          if (provider.currentStep == 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed:
                    isLoading ? null : () => _showSkipOnboardingDialog(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.waterFull,
                ),
                child: const Text(
                  'Skip onboarding',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.waterFull,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSkipOnboardingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Skip Onboarding?'),
          content: const Text(
            "Skipping onboarding means we won't be able to personalize your hydration goal. You can always set this up later in settings.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
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
