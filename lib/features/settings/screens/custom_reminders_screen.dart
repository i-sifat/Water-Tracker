import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/settings/providers/settings_provider.dart';

class CustomRemindersScreen extends StatelessWidget {
  const CustomRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Custom Reminders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PremiumGate(
        feature: PremiumFeature.customReminders,
        lockedChild: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 64, color: AppColors.textSubtitle),
                SizedBox(height: 16),
                Text(
                  'Premium Feature',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Custom reminders are available with premium unlock. Support the app development to access this feature.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSubtitle),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            final reminders =
                settingsProvider.notificationSettings.customReminders;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Reminders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create personalized reminder schedules',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSubtitle,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (reminders.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.alarm_add,
                              size: 64,
                              color: AppColors.textSubtitle.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No custom reminders yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSubtitle,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap the + button to create your first reminder',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSubtitle,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = reminders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              child: ListTile(
                                leading: Icon(
                                  reminder.enabled
                                      ? Icons.alarm_on
                                      : Icons.alarm_off,
                                  color:
                                      reminder.enabled
                                          ? AppColors.waterFull
                                          : AppColors.textSubtitle,
                                ),
                                title: Text(
                                  reminder.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${reminder.timeString} • ${reminder.daysString}',
                                  style: const TextStyle(
                                    color: AppColors.textSubtitle,
                                  ),
                                ),
                                trailing: Switch(
                                  value: reminder.enabled,
                                  onChanged: (value) {
                                    final updatedReminder = reminder.copyWith(
                                      enabled: value,
                                    );
                                    settingsProvider.updateCustomReminder(
                                      updatedReminder,
                                    );
                                  },
                                  activeColor: AppColors.waterFull,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: PremiumGate(
        feature: PremiumFeature.customReminders,
        lockedChild: const SizedBox.shrink(),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Implement add reminder dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add reminder feature coming soon')),
            );
          },
          backgroundColor: AppColors.waterFull,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
