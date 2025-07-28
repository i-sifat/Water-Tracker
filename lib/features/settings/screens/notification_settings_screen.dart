import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/features/settings/providers/settings_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late int _startHour;
  late int _endHour;
  late int _interval;

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final settings = settingsProvider.notificationSettings;

    _startHour = settings.startHour;
    _endHour = settings.endHour;
    _interval = settings.interval;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notification Schedule',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set when you want to receive water reminders',
              style: TextStyle(fontSize: 14, color: AppColors.textSubtitle),
            ),
            const SizedBox(height: 24),

            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _startHour.toDouble(),
                      min: 5,
                      max: 12,
                      divisions: 7,
                      label: '${_startHour.toString().padLeft(2, '0')}:00',
                      onChanged: (value) {
                        setState(() {
                          _startHour = value.round();
                          if (_startHour >= _endHour) {
                            _endHour = _startHour + 1;
                          }
                        });
                      },
                      activeColor: AppColors.waterFull,
                    ),
                    Text(
                      'Start reminders at ${_startHour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _endHour.toDouble(),
                      min: (_startHour + 1).toDouble(),
                      max: 23,
                      divisions: 23 - _startHour - 1,
                      label: '${_endHour.toString().padLeft(2, '0')}:00',
                      onChanged: (value) {
                        setState(() {
                          _endHour = value.round();
                        });
                      },
                      activeColor: AppColors.waterFull,
                    ),
                    Text(
                      'Stop reminders at ${_endHour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminder Interval',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _interval.toDouble(),
                      min: 1,
                      max: 4,
                      divisions: 3,
                      label: '$_interval hour${_interval > 1 ? 's' : ''}',
                      onChanged: (value) {
                        setState(() {
                          _interval = value.round();
                        });
                      },
                      activeColor: AppColors.waterFull,
                    ),
                    Text(
                      'Remind me every $_interval hour${_interval > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPreviewText(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return PrimaryButton(
                  text: 'Save Settings',
                  onPressed: () => _saveSettings(settingsProvider),
                  isLoading: settingsProvider.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getPreviewText() {
    final reminderTimes = <String>[];
    for (var hour = _startHour; hour <= _endHour; hour += _interval) {
      if (hour > _endHour) break;
      reminderTimes.add('${hour.toString().padLeft(2, '0')}:00');
    }

    if (reminderTimes.isEmpty) {
      return 'No reminders with current settings';
    }

    return 'You will receive ${reminderTimes.length} reminders at: ${reminderTimes.join(', ')}';
  }

  Future<void> _saveSettings(SettingsProvider settingsProvider) async {
    final currentSettings = settingsProvider.notificationSettings;
    final updatedSettings = currentSettings.copyWith(
      startHour: _startHour,
      endHour: _endHour,
      interval: _interval,
    );

    final success = await settingsProvider.updateNotificationSettings(
      updatedSettings,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings updated'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
