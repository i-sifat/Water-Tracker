import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/core/widgets/buttons/prefer_not_to_answer_button.dart';
import 'package:watertracker/core/widgets/cards/large_selection_box.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/sugary_drinks_screen.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_progress_indicator.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  Gender? _selectedGender;

  final List<Map<String, dynamic>> _genderOptions = [
    {
      'value': Gender.male,
      'title': 'I am Male',
      'subtitle': 'Select if you identify as male',
      'icon': 'assets/images/icons/onboarding_elements/onboarding_maleavater_icon.svg',
    },
    {
      'value': Gender.female,
      'title': 'I am Female',
      'subtitle': 'Select if you identify as female',
      'icon': 'assets/images/icons/onboarding_elements/onboarding_femaleavater_icon.svg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.appBar,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.assessmentText),
                onPressed: () {
                  onboardingProvider.previousStep();
                  Navigator.of(context).pop();
                },
              ),
            ),
            title: const Text('Assessment', style: AppTypography.subtitle),
            actions: [
              if (onboardingProvider.canSkipCurrent)
                TextButton(
                  onPressed: () => _handleSkip(onboardingProvider),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.waterFull,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${onboardingProvider.currentStep + 1} of ${onboardingProvider.totalStepsCount}',
                  style: const TextStyle(
                    color: AppColors.pageCounter,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: AnimatedOnboardingProgressIndicator(
                  currentStep: onboardingProvider.currentStep,
                  totalSteps: onboardingProvider.totalStepsCount,
                  showStepNumbers: false,
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select your Gender', style: AppTypography.headline),
                      const SizedBox(height: 8),
                      Text(
                        'This helps us personalize your hydration needs (optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSubtitle,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Expanded(
                        child: ListView.separated(
                          itemCount: _genderOptions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final option = _genderOptions[index];
                            return LargeSelectionBox(
                              title: option['title'] as String,
                              subtitle: option['subtitle'] as String,
                              icon: SvgPicture.asset(
                                option['icon'] as String,
                                width: 32,
                                height: 32,
                              ),
                              isSelected: _selectedGender == option['value'],
                              onTap: () {
                                setState(() {
                                  _selectedGender = option['value'] as Gender;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      PreferNotToAnswerButton(
                        onPressed: () => _handlePreferNotToAnswer(onboardingProvider),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ContinueButton(
                        onPressed: _selectedGender != null && !onboardingProvider.isSaving
                            ? () => _handleContinue(onboardingProvider)
                            : null,
                        isDisabled: _selectedGender == null || onboardingProvider.isSaving,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    if (_selectedGender != null) {
      provider.updateGender(_selectedGender!);
      await provider.nextStep();
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const SugaryBeveragesScreen(),
          ),
        );
      }
    }
  }

  Future<void> _handlePreferNotToAnswer(OnboardingProvider provider) async {
    provider.updateGender(Gender.notSpecified);
    await provider.nextStep();
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const SugaryBeveragesScreen(),
        ),
      );
    }
  }

  Future<void> _handleSkip(OnboardingProvider provider) async {
    await provider.skipStep();
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const SugaryBeveragesScreen(),
        ),
      );
    }
  }
}
