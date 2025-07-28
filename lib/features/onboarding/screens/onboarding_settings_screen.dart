import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';

/// Screen to allow users to modify their onboarding data after completion
class OnboardingSettingsScreen extends StatefulWidget {
  const OnboardingSettingsScreen({super.key});

  @override
  State<OnboardingSettingsScreen> createState() => _OnboardingSettingsScreenState();
}

class _OnboardingSettingsScreenState extends State<OnboardingSettingsScreen> {
  late UserProfile _profile;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Load current profile from provider or create default
    _profile = UserProfile.create();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final isCompleted = await OnboardingProvider.isOnboardingCompleted();
      if (isCompleted) {
        // Load from storage - simplified for now
        // In a real app, you'd load from the storage service
        setState(() {
          // Use default profile for now
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.assessmentText,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.waterFull,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.assessmentText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Update your profile to get more accurate hydration recommendations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSubtitle,
              ),
            ),
            const SizedBox(height: 32),

            // Age setting
            _buildSettingCard(
              title: 'Age',
              value: _profile.age?.toString() ?? 'Not set',
              onTap: _showAgeDialog,
            ),

            const SizedBox(height: 16),

            // Weight setting
            _buildSettingCard(
              title: 'Weight',
              value: _profile.weight != null ? '${_profile.weight!.toStringAsFixed(1)} kg' : 'Not set',
              onTap: _showWeightDialog,
            ),

            const SizedBox(height: 16),

            // Gender setting
            _buildSettingCard(
              title: 'Gender',
              value: _profile.gender.displayName,
              onTap: _showGenderDialog,
            ),

            const SizedBox(height: 16),

            // Activity level setting
            _buildSettingCard(
              title: 'Activity Level',
              value: _profile.activityLevel.displayName,
              onTap: _showActivityLevelDialog,
            ),

            const SizedBox(height: 32),

            Text(
              'Goals & Preferences',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.assessmentText,
              ),
            ),
            const SizedBox(height: 16),

            // Goals setting
            _buildSettingCard(
              title: 'Goals',
              value: _profile.goals.isEmpty 
                  ? 'None selected' 
                  : _profile.goals.map((g) => g.displayName).join(', '),
              onTap: _showGoalsDialog,
            ),

            const SizedBox(height: 16),

            // Daily goal setting
            _buildSettingCard(
              title: 'Daily Water Goal',
              value: '${_profile.effectiveDailyGoal} ml',
              onTap: _showDailyGoalDialog,
            ),

            const SizedBox(height: 32),

            // Reset onboarding button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showResetDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Reset All Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.unselectedBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.assessmentText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  void _showAgeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Age'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _profile.age?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                suffixText: 'years',
              ),
              onChanged: (value) {
                final age = int.tryParse(value);
                if (age != null && age > 0 && age < 120) {
                  setState(() {
                    _profile = _profile.copyWith(age: age);
                    _hasChanges = true;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _profile.weight?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight',
                suffixText: 'kg',
              ),
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null && weight > 0 && weight < 300) {
                  setState(() {
                    _profile = _profile.copyWith(weight: weight);
                    _hasChanges = true;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showGenderDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Gender.values.map((gender) {
            return RadioListTile<Gender>(
              title: Text(gender.displayName),
              value: gender,
              groupValue: _profile.gender,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _profile = _profile.copyWith(gender: value);
                    _hasChanges = true;
                  });
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showActivityLevelDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Activity Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ActivityLevel.values.map((level) {
            return RadioListTile<ActivityLevel>(
              title: Text(level.displayName),
              subtitle: Text(level.description),
              value: level,
              groupValue: _profile.activityLevel,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _profile = _profile.copyWith(activityLevel: value);
                    _hasChanges = true;
                  });
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showGoalsDialog() {
    final selectedGoals = Set<Goal>.from(_profile.goals);
    
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Goals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: Goal.values.map((goal) {
              return CheckboxListTile(
                title: Text(goal.displayName),
                subtitle: Text(goal.description),
                value: selectedGoals.contains(goal),
                onChanged: (value) {
                  setDialogState(() {
                    if (value == true) {
                      selectedGoals.add(goal);
                    } else {
                      selectedGoals.remove(goal);
                    }
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _profile = _profile.copyWith(goals: selectedGoals.toList());
                  _hasChanges = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Daily Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _profile.customDailyGoal?.toString() ?? _profile.dailyGoal?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Goal',
                suffixText: 'ml',
                helperText: 'Leave empty to use calculated goal',
              ),
              onChanged: (value) {
                final goal = int.tryParse(value);
                setState(() {
                  _profile = _profile.copyWith(customDailyGoal: goal);
                  _hasChanges = true;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
          "This will reset all your profile settings and you'll need to go through onboarding again. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetOnboarding();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetOnboarding() async {
    try {
      final provider = OnboardingProvider();
      await provider.resetOnboarding();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges) return;

    try {
      // Recalculate daily goal if profile changed
      final newGoal = _profile.calculateWaterIntake();
      _profile = _profile.copyWith(dailyGoal: newGoal);

      // Save to storage (simplified)
      // In a real app, you'd use the storage service
      
      // Update hydration provider with new goal
      if (mounted) {
        final hydrationProvider = Provider.of<HydrationProvider>(context, listen: false);
        await hydrationProvider.setDailyGoal(_profile.effectiveDailyGoal);
      }

      setState(() {
        _hasChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}