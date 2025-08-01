import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/custom_ruler_picker.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({super.key});

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  int _selectedLevel = 2; // 0: Frequent, 1: Medium, 2: 2-3x Weekly (default to rightmost)

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: "Fitness Level",
          subtitle: "How frequent do you take exercise?",
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Exercise illustration
              SizedBox(
                height: 200,
                width: double.infinity,
                child: SvgPicture.asset(
                  'assets/images/icons/onboarding_elements/trainning_icon.svg',
                ),
              ),

              const Spacer(),

              // Custom ruler picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final width = MediaQuery.of(context).size.width - 48;
                    final segmentWidth = width / 2; // 3 positions, 2 segments
                    final dx = details.globalPosition.dx - 24;
                    final newLevel = (dx / segmentWidth).round().clamp(0, 2);
                    if (newLevel != _selectedLevel) {
                      setState(() {
                        _selectedLevel = newLevel;
                        HapticFeedback.selectionClick();
                      });
                    }
                  },
                  child: CustomRulerPicker(
                    value: _selectedLevel,
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    },
                    min: 0,
                    max: 2,
                    leftLabel: 'Frequent',
                    rightLabel: '2-3x Weekly',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    // Save the fitness level as an integer
    final fitnessLevel = 2 - _selectedLevel; // 2 for Frequent, 1 for Medium, 0 for 2-3x Weekly
    await provider.navigateNext();
  }
}
