import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/goal_selection_card.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class SugaryBeveragesScreen extends StatefulWidget {
  const SugaryBeveragesScreen({super.key});

  @override
  State<SugaryBeveragesScreen> createState() => _SugaryBeveragesScreenState();
}

class _SugaryBeveragesScreenState extends State<SugaryBeveragesScreen> {
  String _selectedFrequency = '';

  final List<Map<String, dynamic>> _frequencies = [
    {
      'title': 'Almost never',
      'subtitle': 'Never / several times a month',
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.sugaryIconColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.mail,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      'value': 'almost_never',
      'iconBackgroundColor': AppColors.sugaryIconBackground,
    },
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.sugaryIconColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.battery_charging_full,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      'value': 'rarely',
      'iconBackgroundColor': AppColors.sugaryIconBackgroundSelected,
    },
    {
      'title': 'Regularly',
      'subtitle': 'Every day',
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.sugaryIconColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.lock,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      'value': 'regularly',
      'iconBackgroundColor': AppColors.sugaryIconBackground,
    },
    {
      'title': 'Often',
      'subtitle': 'Several per day',
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.sugaryIconColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.lock,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      'value': 'often',
      'iconBackgroundColor': AppColors.sugaryIconBackground,
    },
  ];

  Future<void> _handleContinue(OnboardingProvider provider) async {
    // Convert string value to integer for storage
    int sugarIntake;
    switch (_selectedFrequency) {
      case 'almost_never':
        sugarIntake = 0;
      case 'rarely':
        sugarIntake = 1;
      case 'regularly':
        sugarIntake = 2;
      case 'often':
        sugarIntake = 3;
      default:
        sugarIntake = 1;
    }
    
    provider.updateSugarDrinkIntake(sugarIntake);
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: 'Sugary Beverages',
          subtitle: 'Select which whats your habit.',
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: _selectedFrequency.isNotEmpty 
              ? () => _handleContinue(onboardingProvider)
              : null,
          canContinue: _selectedFrequency.isNotEmpty,
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Frequency options
              Expanded(
                child: ListView.separated(
                  itemCount: _frequencies.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final frequency = _frequencies[index];
                    final isSelected = _selectedFrequency == frequency['value'];
                    return GoalSelectionCard(
                      title: frequency['title'] as String,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedFrequency = frequency['value'] as String;
                        });
                      },
                      icon: frequency['icon'] as Widget,
                      iconBackgroundColor: isSelected 
                          ? AppColors.sugaryIconBackgroundSelected 
                          : frequency['iconBackgroundColor'] as Color,
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
