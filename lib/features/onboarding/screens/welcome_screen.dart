import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/onboarding/screens/goal_selection_screen.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/primary_button.dart';

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
                child: Center(
                  child: SvgPicture.asset(
                    'assets/onboarding_elements/onboarding_bee_icon.svg',
                    width: 40,
                    height: 40,
                    colorFilter: const ColorFilter.mode(
                      AppColors.lightBlue,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Welcome Text
              const Text(
                'Welcome to the\nHydration Tracker App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeadline,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your intelligent hydration solutions.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSubtitle,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 40),

              // Illustration
              SvgPicture.asset(
                'assets/onboarding_elements/onboarding_bee_icon.svg',
                width: 240,
                height: 240,
              ),
              const Spacer(),

              // Get Started Button
              PrimaryButton(
                text: 'Get Started',
                rightIcon: const Icon(Icons.arrow_forward, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GoalSelectionScreen(),
                    ),
                  );
                },
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
                    fontFamily: 'Poppins',
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
