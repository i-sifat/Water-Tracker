import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/primary_button.dart';
import 'package:watertracker/features/onboarding/screens/data_summary_screen.dart';
import 'package:watertracker/core/services/notification_service.dart';

class NotificationSetupScreen extends StatefulWidget {
  const NotificationSetupScreen({super.key});

  @override
  State<NotificationSetupScreen> createState() =>
      _NotificationSetupScreenState();
}

class _NotificationSetupScreenState extends State<NotificationSetupScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isNotificationPermissionGranted = false;

  final Map<String, dynamic> _notifications = {
    'appointment': {
      'title': 'Water Reminder',
      'subtitle': 'Get reminders to drink water',
      'icon': '💧',
      'value': true,
    },
    'doctor': {
      'title': 'Health Tips',
      'subtitle': 'Receive daily health tips',
      'icon': '🏥',
      'value': false,
    },
    'chatbot': {
      'title': 'Smart Assistant',
      'subtitle': 'Get personalized recommendations',
      'icon': '🤖',
      'value': true,
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    final permissionGranted = await _notificationService.requestPermissions();
    setState(() {
      _isNotificationPermissionGranted = permissionGranted;
    });
  }

  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _notifications.entries) {
      await prefs.setBool(
        'notification_${entry.key}',
        entry.value['value'] as bool,
      );
    }

    if (_isNotificationPermissionGranted &&
        _notifications['appointment']?['value'] == true) {
      await _notificationService.scheduleWaterReminder();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  void _handleContinue() {
    _saveNotificationPreferences().then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CompileDataScreen()),
      );
    });
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(),
            const SizedBox(height: 32),
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
                  entry.value['title'] as String,
                  entry.key,
                  Colors.blue.shade50,
                  entry.value['icon'] as String,
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Continue',
              onPressed: _handleContinue,
              backgroundColor: AppColors.selectedBorder,
              rightIcon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(
    String title,
    String key,
    Color backgroundColor,
    String emoji,
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
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          Switch(
            value: _notifications[key]['value'] as bool,
            onChanged: (value) {
              setState(() {
                _notifications[key] = value;
              });
            },
            activeColor: AppColors.selectedBorder,
            activeTrackColor: AppColors.preferNotToAnswer,
          ),
        ],
      ),
    );
  }
}
