import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/features/onboarding/screens/gender_selection_screen.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final Set<int> _selectedGoals = {};
  bool _isSaving = false;

  final List<Map<String, dynamic>> _goals = [
    {
      'icon': '💧',
      'text': 'Drink More Water',
      'backgroundColor': const Color(0xFFF2F2F2),
      'iconColor': const Color(0xFF7FB364),
    },
    {
      'icon': '🌿',
      'text': 'Improve digestions',
      'backgroundColor': const Color(0xFFF2F2F2),
      'iconColor': const Color(0xFF4B7FD6),
    },
    {
      'icon': '💪',
      'text': 'Lead a Healty Lifestyle',
      'backgroundColor': const Color(0xFFF2F2F2),
      'iconColor': const Color(0xFF7D4FB2),
    },
    {
      'icon': '⚖️',
      'text': 'Lose weight',
      'backgroundColor': const Color(0xFFF2F2F2),
      'iconColor': const Color(0xFF6E7191),
    },
    {
      'icon': '🎯',
      'text': 'Just trying out the app, mate!',
      'backgroundColor': const Color(0xFFF2F2F2),
      'iconColor': const Color(0xFFE3B622),
    },
  ];

  // In the _handleContinue method
  Future<void> _handleContinue() async {
    if (_isSaving || _selectedGoals.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Map selected goals to their text values
      final selectedGoalTexts =
          _selectedGoals
              .map((index) => _goals[index]['text'] as String)
              .toList();

      // Save the selected goals as a string list
      await prefs.setStringList('selected_goals', selectedGoalTexts);

      // Navigate to the next screen
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => const GenderSelectionScreen(),
        ),
      );
    } catch (e) {
      // Log detailed error for debugging
      debugPrint('Error saving goals: $e');

      // Show error message to the user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save goals: $e')));
      }
    } finally {
      // Reset the saving state
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '2 of 10',
              style: TextStyle(
                color: AppColors.pageCounter,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Your Goal', style: AppTypography.headline),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.separated(
                itemCount: _goals.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
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
                              child: Text(
                                goal['icon'] as String,
                                style: const TextStyle(fontSize: 24),
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
            const SizedBox(height: 24),
            ContinueButton(
              onPressed: () {
                if (_selectedGoals.isNotEmpty) {
                  _handleContinue();
                }
              },
              isDisabled: _selectedGoals.isEmpty || _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
