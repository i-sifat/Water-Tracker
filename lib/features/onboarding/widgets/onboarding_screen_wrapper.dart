import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/core/widgets/common/assessment_counter.dart';
import 'package:watertracker/core/widgets/common/exit_confirmation_modal.dart';
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
    this.padding,
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
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, _) {
        final bgColor = backgroundColor ?? AppColors.onboardingBackground;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: _buildAppBar(context, onboardingProvider, bgColor),
          body: Column(
            children: [
              // Progress indicator - start from second page (step 1)
              if (showProgress && onboardingProvider.currentStep > 0)
                Padding(
                  padding: ResponsiveHelper.getResponsivePadding(
                    context,
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: AnimatedOnboardingProgressIndicator(
                    currentStep:
                        onboardingProvider.currentStep -
                        1, // Adjust to start from 0 for progress
                    totalSteps: 15, // Total onboarding steps (0-14)
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
                  padding: ResponsiveHelper.getResponsivePadding(
                    context,
                    horizontal: 24,
                    vertical: 20,
                  ).copyWith(bottom: 0),
                  child: Column(
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              32,
                            ),
                            fontWeight: FontWeight.w900,
                            color: AppColors.textHeadline,
                            height: 1.2,
                          ),
                        ),
                      if (subtitle != null) ...[
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveHeight(
                            context,
                            8,
                          ),
                        ),
                        Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              16,
                            ),
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
              Expanded(
                child: Padding(
                  padding:
                      padding ??
                      ResponsiveHelper.getResponsivePadding(context, all: 24),
                  child: child,
                ),
              ),

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
    Color bgColor,
  ) {
    // Hide app bar for drink goal selection screen (step 1)
    if (!showBackButton && provider.currentStep == 0) return null;
    if (provider.currentStep == 1)
      return null; // Hide app bar for drink goal screen

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      leading:
          showBackButton && provider.currentStep > 0
              ? Container(
                margin: EdgeInsets.only(
                  left: ResponsiveHelper.getResponsiveWidth(context, 16),
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(context, 12),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.assessmentText,
                  ),
                  onPressed: () {
                    // Only show exit modal on step 2 (age selection)
                    if (provider.currentStep == 2) {
                      _showExitConfirmation(context);
                    } else {
                      // Normal back navigation for other pages
                      provider.navigatePrevious();
                    }
                  },
                ),
              )
              : null,
      title: Text(
        'Assessment',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: AppColors.textHeadline,
        ),
      ),
      actions: [
        AssessmentCounter(
          currentStep: provider.currentStep,
          totalSteps: provider.totalStepsCount,
        ),
      ],
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ExitConfirmationModal(
          onConfirm: SystemNavigator.pop,
          onCancel: () {
            // Stay on current page
          },
        );
      },
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    OnboardingProvider provider,
  ) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context, all: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Skip button (if enabled and step is optional)
          if (showSkipButton && provider.canSkipCurrent)
            Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed:
                      isLoading ? null : (onSkip ?? () => provider.skipStep()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSubtitle,
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    skipButtonText,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        16,
                      ),
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
              onPressed:
                  (canContinue && !isLoading)
                      ? (onContinue ?? () => provider.navigateNext())
                      : () {},
              isDisabled: !(canContinue && !isLoading),
            ),
          ),
        ],
      ),
    );
  }
}
