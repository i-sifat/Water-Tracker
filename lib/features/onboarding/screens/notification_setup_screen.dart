import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/services/notification_service.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/features/onboarding/screens/data_summary_screen.dart';

class NotificationSetupScreen extends StatefulWidget {
  const NotificationSetupScreen({super.key});

  @override
  State<NotificationSetupScreen> createState() =>
      _NotificationSetupScreenState();
}

class _NotificationSetupScreenState extends State<NotificationSetupScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isNotificationPermissionGranted = false;

  final Map<String, NotificationSetting> _notifications = {
    'water_reminder': NotificationSetting(
      title: 'Water Reminder',
      subtitle: 'Get reminders to drink water',
      iconPath: 'assets/images/icons/onboarding_elements/water_reminder.svg',
      isEnabled: true,
    ),
    'health_tips': NotificationSetting(
      title: 'Health Tips',
      subtitle: 'Receive daily health tips',
      iconPath: 'assets/images/icons/onboarding_elements/health_tips.svg',
      isEnabled: false,
    ),
    'smart_assistant': NotificationSetting(
      title: 'Smart Assistant',
      subtitle: 'Get personalized recommendations',
      iconPath: 'assets/images/icons/onboarding_elements/smart_assistant.svg',
      isEnabled: false,
    ),
  };

  @override
  void initState() {
    super.initState();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    await _notificationService.initialize();
  }

  Future<void> _requestNotificationPermission() async {
    final permissionGranted = await _notificationService.requestPermissions();
    setState(() {
      _isNotificationPermissionGranted = permissionGranted;
    });
  }

  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _notifications.entries) {
      await prefs.setBool('notification_${entry.key}', entry.value.isEnabled);
    }

    if (_isNotificationPermissionGranted &&
        _notifications['water_reminder']?.isEnabled == true) {
      try {
        await _notificationService.scheduleWaterReminder();
      } catch (e) {
        debugPrint('Error scheduling notifications: $e');
        // Continue even if notification scheduling fails
      }
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  void _handleContinue() async {
    await _requestNotificationPermission();
    await _saveNotificationPreferences();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CompileDataScreen()),
      );
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
            icon: const Icon(Icons.arrow_back, color: AppColors.assessmentText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Notification Setup',
          style: TextStyle(
            color: AppColors.assessmentText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Setup',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.assessmentText,
                height: 1.2,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose which notification you'd like to setup.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            if (!_isNotificationPermissionGranted)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please enable notifications to receive water reminders',
                        style: TextStyle(color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ..._notifications.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildNotificationOption(
                  entry.value.title,
                  entry.value.subtitle,
                  entry.value.iconPath,
                  entry.value.isEnabled,
                  (value) {
                    setState(() {
                      entry.value.isEnabled = value;
                    });
                  },
                ),
              ),
            ),
            const Spacer(),
            ContinueButton(
              onPressed: () async {
                await _requestNotificationPermission();
                await _saveNotificationPreferences();
                if (mounted) {
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const CompileDataScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(
    String title,
    String subtitle,
    String iconPath,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.darkBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: AppColors.selectedBorder,
            activeTrackColor: AppColors.preferNotToAnswer,
          ),
        ],
      ),
    );
  }
}

class NotificationSetting {
  NotificationSetting({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.isEnabled,
  });

  final String title;
  final String subtitle;
  final String iconPath;
  bool isEnabled;
}
