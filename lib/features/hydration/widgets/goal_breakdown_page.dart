import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/goal_factors.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

/// Page showing hydration goal breakdown and calculation factors
class GoalBreakdownPage extends StatefulWidget {
  const GoalBreakdownPage({super.key});

  @override
  State<GoalBreakdownPage> createState() => _GoalBreakdownPageState();
}

class _GoalBreakdownPageState extends State<GoalBreakdownPage> {
  late GoalFactors _goalFactors;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGoalFactors();
  }

  void _initializeGoalFactors() {
    final provider = context.read<HydrationProvider>();
    // Initialize with default factors based on current daily goal
    // Ensure base requirement is within slider range (1500-3000ml)
    final baseRequirement = (provider.dailyGoal * 0.7).round().clamp(
      1500,
      3000,
    );
    _goalFactors = GoalFactors(
      baseRequirement: baseRequirement,
    );
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<HydrationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGoalSummaryCard(),
                        const SizedBox(height: 16),
                        _buildBaseRequirementCard(),
                        const SizedBox(height: 16),
                        _buildActivityLevelCard(),
                        const SizedBox(height: 16),
                        _buildClimateCard(),
                        const SizedBox(height: 16),
                        _buildHealthAdjustmentCard(),
                        const SizedBox(height: 16),
                        _buildCustomAdjustmentCard(),
                        const SizedBox(height: 24),
                        _buildApplyButton(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Goal Breakdown',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textHeadline,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }

  Widget _buildGoalSummaryCard() {
    return AppCard(
      backgroundColor: AppColors.waterFull.withOpacity(0.1),
      borderColor: AppColors.waterFull,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Hydration Goal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeadline,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_goalFactors.totalGoal / 1000).toStringAsFixed(1)} L',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.waterFull,
                  fontFamily: 'Nunito',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.waterFull,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_goalFactors.totalGoal} ml',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Calculated based on your personal factors',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSubtitle,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseRequirementCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.goalBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Base Requirement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              Text(
                '${_goalFactors.baseRequirement} ml',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goalBlue,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your age, weight, and gender',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSubtitle,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _goalFactors.baseRequirement.toDouble(),
            min: 1500,
            max: 3000,
            divisions: 30,
            activeColor: AppColors.goalBlue,
            inactiveColor: AppColors.goalBlue.withOpacity(0.3),
            onChanged: (value) {
              setState(() {
                _goalFactors = _goalFactors.copyWith(
                  baseRequirement: value.round(),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goalGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.goalGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Activity Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              Text(
                '${_goalFactors.activityAdjustment >= 0 ? '+' : ''}${_goalFactors.activityAdjustment} ml',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      _goalFactors.activityAdjustment >= 0
                          ? AppColors.goalGreen
                          : Colors.red,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current: ${_goalFactors.activityLevel.displayName}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSubtitle,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ActivityLevel.values.map((level) {
                  final isSelected = _goalFactors.activityLevel == level;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _goalFactors = _goalFactors.copyWith(
                          activityLevel: level,
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.goalGreen
                                : AppColors.goalGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.goalGreen,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        level.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppColors.goalGreen,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goalYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wb_sunny,
                  color: AppColors.goalYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Climate Condition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              Text(
                '${_goalFactors.climateAdjustment >= 0 ? '+' : ''}${_goalFactors.climateAdjustment} ml',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      _goalFactors.climateAdjustment >= 0
                          ? AppColors.goalYellow
                          : Colors.blue,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current: ${_goalFactors.climateCondition.displayName}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSubtitle,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ClimateCondition.values.map((condition) {
                  final isSelected = _goalFactors.climateCondition == condition;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _goalFactors = _goalFactors.copyWith(
                          climateCondition: condition,
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.goalYellow
                                : AppColors.goalYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.goalYellow,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        condition.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppColors.goalYellow,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAdjustmentCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goalPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: AppColors.goalPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Health Adjustment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              Text(
                '${_goalFactors.healthAdjustment >= 0 ? '+' : ''}${_goalFactors.healthAdjustment} ml',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      _goalFactors.healthAdjustment >= 0
                          ? AppColors.goalPurple
                          : Colors.red,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Medical conditions, medications, or health factors',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSubtitle,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _goalFactors.healthAdjustment.toDouble(),
            min: -500,
            max: 500,
            divisions: 20,
            activeColor: AppColors.goalPurple,
            inactiveColor: AppColors.goalPurple.withOpacity(0.3),
            onChanged: (value) {
              setState(() {
                _goalFactors = _goalFactors.copyWith(
                  healthAdjustment: value.round(),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAdjustmentCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textHeadline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.textHeadline,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Custom Adjustment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              Text(
                '${_goalFactors.customAdjustment >= 0 ? '+' : ''}${_goalFactors.customAdjustment} ml',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      _goalFactors.customAdjustment >= 0
                          ? AppColors.textHeadline
                          : Colors.red,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Personal preference or other factors',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSubtitle,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _goalFactors.customAdjustment.toDouble(),
            min: -1000,
            max: 1000,
            divisions: 40,
            activeColor: AppColors.textHeadline,
            inactiveColor: AppColors.textHeadline.withOpacity(0.3),
            onChanged: (value) {
              setState(() {
                _goalFactors = _goalFactors.copyWith(
                  customAdjustment: value.round(),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(HydrationProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await provider.setDailyGoal(_goalFactors.totalGoal);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Goal updated successfully!'),
                  backgroundColor: AppColors.goalGreen,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update goal: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.waterFull,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Apply New Goal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }
}
