import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/features/onboarding/screens/notification_setup_screen.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/primary_button.dart';

class WeatherSelectionScreen extends StatefulWidget {
  const WeatherSelectionScreen({super.key});

  @override
  State<WeatherSelectionScreen> createState() => _WeatherSelectionScreenState();
}

class _WeatherSelectionScreenState extends State<WeatherSelectionScreen> {
  String? _selectedWeather;
  final PageController _pageController = PageController(
    viewportFraction: 0.7,
    initialPage: 1,
  );

  final List<Map<String, dynamic>> _weatherOptions = [
    {'title': 'Cold', 'icon': Icons.ac_unit, 'value': 'cold'},
    {'title': 'Normal', 'icon': Icons.thermostat, 'value': 'normal'},
    {'title': 'Hot', 'icon': Icons.wb_sunny, 'value': 'hot'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveWeather() async {
    if (_selectedWeather != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_preference', _selectedWeather!);
    }
  }

  void _handleContinue() {
    _saveWeather().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NotificationSetupScreen(),
        ),
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
            icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Assessment',
          style: TextStyle(
            color: AppColors.darkBlue,
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
              '16 of 17',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's the Weather?",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlue,
                height: 1.2,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please select your current mood.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _weatherOptions.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedWeather =
                        _weatherOptions[index]['value'] as String?;
                  });
                },
                itemBuilder: (context, index) {
                  final weather = _weatherOptions[index];
                  final isSelected =
                      _selectedWeather == weather['value'] as String?;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.darkBlue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          weather['icon'] as IconData?,
                          size: 80,
                          color: isSelected ? Colors.white : Colors.grey[500],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          weather['title'] as String,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Continue',
              onPressed: _selectedWeather != null ? _handleContinue : () {},
              isDisabled: _selectedWeather == null,
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
}
