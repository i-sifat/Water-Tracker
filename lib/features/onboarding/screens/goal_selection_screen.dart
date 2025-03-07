import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/features/onboarding/screens/gender_selection_screen.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/primary_button.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final Set<int> _selectedGoals = {};

  final List<Map<String, dynamic>> _goals = [
    {
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame.svg',
      'text': 'Drink More Water',
      'backgroundColor': Color(0xFFE8FAE0),
      'iconColor': Color(0xFF7FB364),
    },
    {
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-1.svg',
      'text': 'Improve digestions',
      'backgroundColor': Color(0xFFE4F0FF),
      'iconColor': Color(0xFF4B7FD6),
    },
    {
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-2.svg',
      'text': 'Lead a Healty Lifestyle',
      'backgroundColor': Color(0xFFE9D9FF),
      'iconColor': Color(0xFF7D4FB2),
    },
    {
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-3.svg',
      'text': 'Lose weight',
      'backgroundColor': Color(0xFFF2F2F2),
      'iconColor': Color(0xFF6E7191),
    },
    {
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-4.svg',
      'text': 'Just trying out the app, mate!',
      'backgroundColor': Color(0xFFFFF8E5),
      'iconColor': Color(0xFFE3B622),
    },
  ];

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'selected_goals',
      _selectedGoals.map((index) => _goals[index]['text'] as String).toList(),
    );
  }

  void _handleContinue() {
    if (_selectedGoals.isNotEmpty) {
      _saveGoals().then((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GenderSelectionScreen(),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textHeadline),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Assessment',
          style: TextStyle(
            color: AppColors.textHeadline,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '1 of 17',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Select Your Goal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final isSelected = _selectedGoals.contains(index);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedGoals.remove(index);
                          } else {
                            _selectedGoals.add(index);
                          }
                        });
                      },
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.lightBlue.withOpacity(0.25)
                                    : Colors.grey.shade200,
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textHeadline,
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
                                          ? AppColors.lightBlue
                                          : Colors.grey.shade300,
                                  width: 2,
                                ),
                                color:
                                    isSelected
                                        ? AppColors.lightBlue
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
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Continue',
              onPressed: _selectedGoals.isNotEmpty ? _handleContinue : () {},
              isDisabled: _selectedGoals.isEmpty,
              rightIcon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
