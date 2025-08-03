import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
import 'package:watertracker/core/widgets/cards/gender_selection_card.dart';
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
    {'value': Gender.male, 'title': '♂ I am Male', 'gender': 'male'},
    {'value': Gender.female, 'title': '♀ I am Female', 'gender': 'female'},
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
          onContinue:
              _selectedGender != null
                  ? () => _handleContinue(onboardingProvider)
                  : null,
          canContinue: _selectedGender != null,
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              // Gender selection cards
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GenderSelectionCard(
                        title: _genderOptions[0]['title'] as String,
                        gender: _genderOptions[0]['gender'] as String,
                        isSelected:
                            _selectedGender == _genderOptions[0]['value'],
                        onTap: () {
                          setState(() {
                            _selectedGender =
                                _genderOptions[0]['value'] as Gender;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(context, 16),
                    ),
                    Expanded(
                      child: GenderSelectionCard(
                        title: _genderOptions[1]['title'] as String,
                        gender: _genderOptions[1]['gender'] as String,
                        isSelected:
                            _selectedGender == _genderOptions[1]['value'],
                        onTap: () {
                          setState(() {
                            _selectedGender =
                                _genderOptions[1]['value'] as Gender;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),

              // Prefer not to answer button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handlePreferNotToAnswer(onboardingProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPurple,
                    foregroundColor: Colors.white,
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveBorderRadius(context, 12),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Prefer not to answer',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            16,
                          ),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveHelper.getResponsiveWidth(context, 8),
                      ),
                      Icon(
                        Icons.close,
                        size: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          20,
                        ),
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
}
