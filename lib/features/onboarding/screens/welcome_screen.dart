import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
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
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 56),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 40),
              ),
              // Welcome Text
              Padding(
                padding: ResponsiveHelper.getResponsivePadding(
                  context,
                  horizontal: 32,
                ),
                child: Text(
                  'Welcome to the\nHydration Tracker App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      32,
                    ),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
              // Subtitle
              Padding(
                padding: ResponsiveHelper.getResponsivePadding(
                  context,
                  horizontal: 32,
                ),
                child: Text(
                  'Your intelligent hydration solutions. 🩺',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      18,
                    ),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSubtitle,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 32),
              ),
              // Illustration
              Center(
                child: SvgPicture.asset(
                  'assets/images/icons/onboarding_elements/onboarding_bee_icon.svg',
                  width: ResponsiveHelper.getResponsiveWidth(context, 280),
                  height: ResponsiveHelper.getResponsiveHeight(context, 280),
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
