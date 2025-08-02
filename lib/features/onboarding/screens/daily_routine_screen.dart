import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 21, minute: 0);

  Future<void> _selectWakeUpTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.waterFull,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _wakeUpTime) {
      setState(() {
        _wakeUpTime = picked;
      });
    }
  }

  Future<void> _selectSleepTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _sleepTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.waterFull,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _sleepTime) {
      setState(() {
        _sleepTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    // Save the routine times to the provider
    // You can extend the UserProfile model to include these times
    // For now, we'll just navigate to the next step
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: "What's your daily routine?",
          subtitle: 'Please, specify details about your daily routine for a\nmore accurate personal daily intake plan',
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              const SizedBox(height: 32),
              
              // Wake-up time card
              _buildTimeCard(
                icon: Icons.wb_sunny,
                title: 'Wake-up',
                time: _formatTime(_wakeUpTime),
                onTap: _selectWakeUpTime,
              ),
              
              const SizedBox(height: 16),
              
              // Sleep time card
              _buildTimeCard(
                icon: Icons.nightlight_round,
                title: 'Sleep',
                time: _formatTime(_sleepTime),
                onTap: _selectSleepTime,
              ),
              
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String title,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.genderUnselected,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.boxIconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.textHeadline,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: AppTypography.subtitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeadline,
                ),
              ),
            ),
            
            // Time display
            Text(
              time,
              style: AppTypography.subtitle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.waterFull,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: AppColors.textSubtitle,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}