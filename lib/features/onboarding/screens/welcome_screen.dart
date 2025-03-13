// lib/features/onboarding/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/primary_button.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/onboarding/screens/goal_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onBoardingpagebackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // App Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.water_drop)),
              ),
              const SizedBox(height: 30),

              // Welcome Text
              const Text(
                'Welcome to the\nHydration Tracker App',
                textAlign: TextAlign.center,
                style: AppTypography.welcomeHeadline,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your intelligent hydration solutions.',
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.textSubtitle,
                ),
              ),
              const SizedBox(height: 40),

              // Illustration
              SvgPicture.asset(
                'assets/images/icons/onboarding_elements/onboarding_bee_icon.svg',
                width: 320,
                height: 320,
                placeholderBuilder:
                    (BuildContext context) => const SizedBox(
                      width: 320,
                      height: 320,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              ),
              const SizedBox(height: 30),

              // Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: PrimaryButton(
                  text: 'Start Calculating',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const GoalSelectionScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.waterFull,
                  rightIcon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Skip Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSubtitle,
                ),
                child: const Text(
                  'skip?',
                  style: TextStyle(
                    fontSize: 16,

                    fontFamily: 'Nunito',
                    color: AppColors.waterFull,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
