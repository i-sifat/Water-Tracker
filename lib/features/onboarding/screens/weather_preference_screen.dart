import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/features/onboarding/screens/notification_setup_screen.dart';

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
    {
      'title': 'Cold',
      'icon': Icons.ac_unit,
      'value': 'cold',
      'description': 'Below 20°C',
    },
    {
      'title': 'Normal',
      'icon': Icons.thermostat,
      'value': 'normal',
      'description': '20-25°C',
    },
    {
      'title': 'Hot',
      'icon': Icons.wb_sunny,
      'value': 'hot',
      'description': 'Above 25°C',
    },
  ];

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
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '9 of 10',
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What's the Weather?", style: AppTypography.headline),
            const SizedBox(height: 16),
            Text(
              'Select your current weather condition.',
              style: AppTypography.subtitle,
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
                        _weatherOptions[index]['value'] as String;
                  });
                },
                itemBuilder: (context, index) {
                  final weather = _weatherOptions[index];
                  final isSelected = _selectedWeather == weather['value'];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.selectedBorder
                              : AppColors.boxIconBackground,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          weather['icon'] as IconData,
                          size: 80,
                          color:
                              isSelected
                                  ? Colors.white
                                  : AppColors.assessmentText,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          weather['title'] as String,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.assessmentText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weather['description'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isSelected
                                    ? Colors.white70
                                    : AppColors.textSubtitle,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            ContinueButton(
              onPressed: _selectedWeather != null ? _handleContinue : () {},
              isDisabled: _selectedWeather == null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    _saveWeather().then((_) {
      // context.read<OnboardingProvider>().nextPage();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NotificationSetupScreen(),
        ),
      );
    });
  }

  Future<void> _saveWeather() async {
    if (_selectedWeather != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_preference', _selectedWeather!);
    }
  }
}
