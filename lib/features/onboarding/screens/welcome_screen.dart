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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              // App Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.water_drop)),
              ),
              const SizedBox(height: 40),

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
                width: 240,
                height: 240,
              ),
              const Spacer(),

              // Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: PrimaryButton(
                  text: 'Start Calculating',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GoalSelectionScreen(),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF7671FF),
                  rightIcon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Skip Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSubtitle,
                ),
                child: const Text(
                  'skip?',
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    fontFamily: 'Nunito',
                    color: Color(0xFF7671FF),
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
