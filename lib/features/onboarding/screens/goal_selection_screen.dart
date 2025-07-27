import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/gender_selection_screen.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_progress_indicator.dart';

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
    await provider.nextStep();
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const GenderSelectionScreen(),
        ),
      );
    }
  }

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
                      const Text('Select Your Goals', style: AppTypography.headline),
                      const SizedBox(height: 8),
                      Text(
                        'Choose one or more goals to personalize your experience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSubtitle,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Expanded(
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
                                            color: AppColors.selectedBorder.withOpacity(0.1),
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
                                            style: TextStyle(
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
                      ),
                      
                      const SizedBox(height: 24),
                      
                      ContinueButton(
                        onPressed: _selectedGoals.isNotEmpty && !onboardingProvider.isSaving
                            ? () => _handleContinue(onboardingProvider)
                            : null,
                        isDisabled: _selectedGoals.isEmpty || onboardingProvider.isSaving,
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
