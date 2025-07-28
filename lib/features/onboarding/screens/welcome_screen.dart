import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          showBackButton: false,
          continueButtonText: 'Get Started',
          child: Column(
            children: [
              const SizedBox(height: 30),

              // App Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.1),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSubtitle),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Illustration
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/icons/onboarding_elements/onboarding_bee_icon.svg',
                    width: 280,
                    height: 280,
                    placeholderBuilder:
                        (BuildContext context) => Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withValues(alpha: 0.1),
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
            ],
          ),
        );
      },
    );
  }
}
