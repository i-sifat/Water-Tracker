import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/large_selection_box.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

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

  Future<void> _handleContinue(OnboardingProvider provider) async {
    if (_selectedGender != null) {
      provider.updateGender(_selectedGender!);
    }
    await provider.navigateNext();
  }

  Future<void> _handlePreferNotToAnswer(OnboardingProvider provider) async {
    provider.updateGender(Gender.notSpecified);
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: 'Select your Gender',
          subtitle: 'This helps us personalize your hydration needs (optional)',
          showSkipButton: true,
          onContinue: _selectedGender != null ? () => _handleContinue(onboardingProvider) : null,
          canContinue: _selectedGender != null,
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
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
              
              // Prefer not to answer button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _handlePreferNotToAnswer(onboardingProvider),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSubtitle,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Prefer not to answer',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
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
