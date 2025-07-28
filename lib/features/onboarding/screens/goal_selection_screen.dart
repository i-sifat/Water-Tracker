import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
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
      'icon': '💧',
      'text': 'Drink More Water',
      'description': 'Stay hydrated throughout the day',
      'backgroundColor': const Color(0xFFF2F2F2),
    },
    {
      'goal': Goal.generalHealth,
      'icon': '🌿',
      'text': 'Improve Digestion',
      'description': 'Support digestive health',
      'backgroundColor': const Color(0xFFF2F2F2),
    },
    {
      'goal': Goal.generalHealth,
      'icon': '💪',
      'text': 'Lead a Healthy Lifestyle',
      'description': 'Maintain overall wellness',
      'backgroundColor': const Color(0xFFF2F2F2),
    },
    {
      'goal': Goal.weightLoss,
      'icon': '⚖️',
      'text': 'Lose Weight',
      'description': 'Support metabolism and weight goals',
      'backgroundColor': const Color(0xFFF2F2F2),
    },
    {
      'goal': Goal.athleticPerformance,
      'icon': '🏃',
      'text': 'Athletic Performance',
      'description': 'Optimize hydration for workouts',
      'backgroundColor': const Color(0xFFF2F2F2),
    },
    {
      'goal': Goal.skinHealth,
      'icon': '✨',
      'text': 'Skin Health',
      'description': 'Improve skin hydration',
      'backgroundColor': const Color(0xFFF2F2F2),
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
          title: 'Select Your Goals',
          subtitle: 'Choose one or more goals to personalize your experience',
          onContinue: _selectedGoals.isNotEmpty ? () => _handleContinue(onboardingProvider) : null,
          canContinue: _selectedGoals.isNotEmpty,
          isLoading: onboardingProvider.isSaving,
          child: ListView.separated(
            itemCount: _goalOptions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final goalOption = _goalOptions[index];
              final goal = goalOption['goal'] as Goal;
              final isSelected = _selectedGoals.contains(goal);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(goal);
                    } else {
                      _selectedGoals.add(goal);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.selectedBorder
                          : AppColors.unselectedBorder,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.selectedBorder.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: goalOption['backgroundColor'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            goalOption['icon'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goalOption['text'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.selectedBorder
                                    : AppColors.assessmentText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goalOption['description'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.selectedBorder
                                : AppColors.unselectedBorder,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.selectedBorder
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
