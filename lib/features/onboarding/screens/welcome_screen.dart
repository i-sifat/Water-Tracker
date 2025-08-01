import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          showBackButton: false,
          continueButtonText: 'Get Started',
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 56),
              // Top Lottie Animation (App Icon)
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF313A34), // dark icon bg
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/lottie/check_animation.json',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Welcome Text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Welcome to the\nHydration Tracker App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF313A34),
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Your intelligent hydration solutions. 🩺',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF647067),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Illustration
              Center(
                child: SvgPicture.asset(
                  'assets/images/icons/onboarding_elements/onboarding_bee_icon.svg',
                  width: 280,
                  height: 280,
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
