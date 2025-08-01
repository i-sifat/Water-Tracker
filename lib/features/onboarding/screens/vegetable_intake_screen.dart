import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/goal_selection_card.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class VegetablesFruitsScreen extends StatefulWidget {
  const VegetablesFruitsScreen({super.key});

  @override
  State<VegetablesFruitsScreen> createState() => _VegetablesFruitsScreenState();
}

class _VegetablesFruitsScreenState extends State<VegetablesFruitsScreen> {
  int _selectedIntake = 2; // Default to "Often" to match image

  final List<Map<String, dynamic>> _intakeOptions = [
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.vegetableIconColor,
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
      'value': 1,
      'iconBackgroundColor': AppColors.vegetableIconBackground,
    },
    {
      'title': 'Often',
      'subtitle': 'Several per day',
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.vegetableIconColor,
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
      'value': 2,
      'iconBackgroundColor': AppColors.vegetableIconBackgroundSelected,
    },
    {
      'title': 'Regularly',
      'subtitle': 'Every day',
      'icon': Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.vegetableIconColor,
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
      'value': 3,
      'iconBackgroundColor': AppColors.vegetableIconBackground,
    },
  ];

  Future<void> _handleContinue(OnboardingProvider provider) async {
    provider.updateVegetableIntake(_selectedIntake);
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: 'Vegetables',
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              // Vegetable intake options
              Expanded(
                child: ListView.separated(
                  itemCount: _intakeOptions.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = _intakeOptions[index];
                    final isSelected = _selectedIntake == option['value'];
                    return GoalSelectionCard(
                      title: option['title'] as String,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedIntake = option['value'] as int;
                        });
                      },
                      icon: option['icon'] as Widget,
                      iconBackgroundColor: isSelected 
                          ? AppColors.vegetableIconBackgroundSelected 
                          : option['iconBackgroundColor'] as Color,
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
