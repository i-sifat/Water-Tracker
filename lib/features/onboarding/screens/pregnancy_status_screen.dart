import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/goal_selection_card.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  PregnancyStatus? _selectedStatus;

  final List<Map<String, dynamic>> _options = [
    {
      'title': 'Pregnancy',
      'subtitle': 'Few times a week',
      'value': PregnancyStatus.pregnant,
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.pregnancyIconColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.pregnant_woman,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      'iconBackgroundColor': AppColors.pregnancyIconBackground,
    },
    {
      'title': 'Breastfeeding',
      'subtitle': 'Several per day',
      'value': PregnancyStatus.breastfeeding,
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.breastfeedingIconColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.child_care,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      'iconBackgroundColor': AppColors.breastfeedingIconBackground,
    },
  ];

  Future<void> _handleContinue(OnboardingProvider provider) async {
    if (_selectedStatus != null) {
      provider.updatePregnancyStatus(_selectedStatus!);
    }
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: 'Pregnancy/Breastfeed',
          subtitle: 'Select which whats your habit.',
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: _selectedStatus != null 
              ? () => _handleContinue(onboardingProvider)
              : null,
          canContinue: _selectedStatus != null,
          showSkipButton: true,
          skipButtonText: 'Prefer not to answer',
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              // Pregnancy options
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    return GoalSelectionCard(
                      title: option['title'] as String,
                      isSelected: _selectedStatus == option['value'],
                      onTap: () {
                        setState(() {
                          _selectedStatus = option['value'] as PregnancyStatus;
                        });
                      },
                      icon: option['icon'] as Widget,
                      iconBackgroundColor: option['iconBackgroundColor'] as Color,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
