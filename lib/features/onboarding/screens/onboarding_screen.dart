import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/age_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/exercise_frequency_screen.dart';
import 'package:watertracker/features/onboarding/screens/gender_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/goal_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/notification_setup_screen.dart';
import 'package:watertracker/features/onboarding/screens/pregnancy_status_screen.dart';
import 'package:watertracker/features/onboarding/screens/sugary_drinks_screen.dart';
import 'package:watertracker/features/onboarding/screens/vegetable_intake_screen.dart';
import 'package:watertracker/features/onboarding/screens/weather_preference_screen.dart';
import 'package:watertracker/features/onboarding/screens/weight_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = [
      const GoalSelectionScreenContent(),
      const GenderSelectionScreenContent(),
      const AgeSelectionScreenContent(),
      const WeightSelectionScreenContent(),
      const FitnessLevelScreenContent(),
      const VegetablesFruitsScreenContent(),
      const SugaryBeveragesScreenContent(),
      const PregnancyScreenContent(),
      const WeatherSelectionScreenContent(),
      const NotificationSetupScreenContent(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_pageController.page! < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.of(context).pop(),
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
            child: Consumer<OnboardingProvider>(
              builder: (context, provider, _) {
                return Text(
                  provider.pageCounter,
                  style: AppTypography.subtitle,
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                context.read<OnboardingProvider>().setPage(index + 1);
              },
              children: _pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: ContinueButton(onPressed: _handleContinue),
          ),
        ],
      ),
    );
  }
}

class GoalSelectionScreenContent extends StatefulWidget {
  const GoalSelectionScreenContent({super.key});

  @override
  State<GoalSelectionScreenContent> createState() =>
      _GoalSelectionScreenContentState();
}

class _GoalSelectionScreenContentState
    extends State<GoalSelectionScreenContent> {
  final Set<int> _selectedGoals = {};

  final List<Map<String, dynamic>> _goals = [
    {
      'icon':
          'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame.svg',
      'text': 'Drink More Water',
      'backgroundColor': const Color(0xFFE8FAE0),
      'iconColor': const Color(0xFF7FB364),
    },
    {
      'icon':
          'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame-1.svg',
      'text': 'Improve digestions',
      'backgroundColor': const Color(0xFFE4F0FF),
      'iconColor': const Color(0xFF4B7FD6),
    },
    {
      'icon':
          'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame-2.svg',
      'text': 'Lead a Healty Lifestyle',
      'backgroundColor': const Color(0xFFE9D9FF),
      'iconColor': const Color(0xFF7D4FB2),
    },
    {
      'icon':
          'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame-3.svg',
      'text': 'Lose weight',
      'backgroundColor': const Color(0xFFF2F2F2),
      'iconColor': const Color(0xFF6E7191),
    },
    {
      'icon':
          'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame-4.svg',
      'text': 'Just trying out the app, mate!',
      'backgroundColor': const Color(0xFFFFF8E5),
      'iconColor': const Color(0xFFE3B622),
    },
  ];

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedGoalTexts =
        _selectedGoals.map((index) => _goals[index]['text'] as String).toList();
    await prefs.setStringList('selected_goals', selectedGoalTexts);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Your Goal', style: AppTypography.headline),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              itemCount: _goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selectedGoals.contains(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGoals.remove(index);
                      } else {
                        _selectedGoals.add(index);
                      }
                    });
                    _saveGoals();
                  },
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.selectedBorder
                                : AppColors.unselectedBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: goal['backgroundColor'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              goal['icon'] as String,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                goal['iconColor'] as Color,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            goal['text'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? AppColors.selectedBorder
                                      : AppColors.assessmentText,
                            ),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.selectedBorder
                                      : AppColors.unselectedBorder,
                              width: 2,
                            ),
                            color:
                                isSelected
                                    ? AppColors.selectedBorder
                                    : Colors.transparent,
                          ),
                          child:
                              isSelected
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
        ],
      ),
    );
  }
}

// Add similar content classes for other screens...
