import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/goal_selection_card.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final Set<Goal> _selectedGoals = {};

  final List<Map<String, dynamic>> _goalOptions = [
    {
      'goal': Goal.generalHealth,
      'icon': Icon(
        Icons.add,
        color: Colors.white,
        size: 24,
      ),
      'text': 'Drink More Water',
      'iconBackgroundColor': AppColors.goalGreen, // Green
    },
    {
      'goal': Goal.athleticPerformance,
      'icon': Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'U',
            style: TextStyle(
              color: AppColors.goalBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      'text': 'Improve digestions',
      'iconBackgroundColor': AppColors.goalBlue, // Blue
    },
    {
      'goal': Goal.skinHealth,
      'icon': Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.person,
            color: Colors.white,
            size: 24,
          ),
          Icon(
            Icons.favorite,
            color: Colors.white,
            size: 12,
          ),
        ],
      ),
      'text': 'Lead a Healty Lifestyle',
      'iconBackgroundColor': AppColors.goalPurple, // Purple
    },
    {
      'goal': Goal.weightLoss,
      'icon': Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.close,
            color: AppColors.textSubtitle,
            size: 16,
          ),
        ),
      ),
      'text': 'Lose weight',
      'iconBackgroundColor': AppColors.goalGrey, // Light grey
    },
    {
      'goal': Goal.muscleGain, // Changed from generalHealth to muscleGain
      'icon': Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Container(
            width: 2,
            height: 16,
            color: AppColors.goalYellow,
          ),
        ),
      ),
      'text': 'Just trying out the app, mate!',
      'iconBackgroundColor': AppColors.goalYellow, // Yellow
    },
  ];

  Future<void> _handleContinue(OnboardingProvider provider) async {
    if (_selectedGoals.isEmpty) return;

    provider.updateGoals(_selectedGoals.toList());
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: 'Select Your Goal',
          subtitle: null,
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue:
              _selectedGoals.isNotEmpty
                  ? () => _handleContinue(onboardingProvider)
                  : null,
          canContinue: _selectedGoals.isNotEmpty,
          isLoading: onboardingProvider.isSaving,
          child: ListView.separated(
            itemCount: _goalOptions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final goalOption = _goalOptions[index];
              final goal = goalOption['goal'] as Goal;
              final isSelected = _selectedGoals.contains(goal);

              return GoalSelectionCard(
                title: goalOption['text'] as String,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(goal);
                    } else {
                      _selectedGoals.add(goal);
                    }
                  });
                },
                icon: goalOption['icon'] as Widget,
                iconBackgroundColor: goalOption['iconBackgroundColor'] as Color,
              );
            },
          ),
        );
      },
    );
  }
}
