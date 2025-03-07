import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:watertracker/widgets/primary_button.dart';

class NotificationSetupScreen extends StatefulWidget {
  const NotificationSetupScreen({super.key});

  @override
  State<NotificationSetupScreen> createState() =>
      _NotificationSetupScreenState();
}

class _NotificationSetupScreenState extends State<NotificationSetupScreen> {
  final Map<String, bool> _notifications = {
    'appointment': true,
    'doctor': false,
    'chatbot': true,
  };

  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in _notifications.entries) {
      await prefs.setBool('notification_${entry.key}', entry.value);
    }
  }

  void _handleContinue() {
    _saveNotificationPreferences().then((_) {
      // Navigate to the next screen
      // Navigator.of(context).push(
      //   MaterialPageRoute(builder: (context) => const NextScreen()),
      // );
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
            icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Notification Setup',
          style: TextStyle(
            color: AppColors.darkBlue,
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
            Center(
              child: Image.asset(
                'assets/notification_setup.png',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Notification Setup',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlue,
                height: 1.2,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose which notification you\'d like to setup.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            _buildNotificationOption(
              'Appointment Notification',
              'appointment',
              const Color(0xFFFFE8E8),
              '📅',
            ),
            const SizedBox(height: 16),
            _buildNotificationOption(
              'Doctor Notification',
              'doctor',
              const Color(0xFFFFF8BB),
              '👨‍⚕️',
            ),
            const SizedBox(height: 16),
            _buildNotificationOption(
              'AI Chatbot Notification',
              'chatbot',
              const Color(0xFFDAFFC7),
              '🤖',
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Continue',
              onPressed: _handleContinue,
              backgroundColor: const Color(0xFF7FB364),
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
            value: _notifications[key]!,
            onChanged: (value) {
              setState(() {
                _notifications[key] = value;
              });
            },
            activeColor: const Color(0xFF7FB364),
            activeTrackColor: const Color(0xFFDAFFC7),
          ),
        ],
      ),
    );
  }
}
