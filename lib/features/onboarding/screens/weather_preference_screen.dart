import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/utils/app_animations.dart';
import 'package:watertracker/core/widgets/cards/selectable_card.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class WeatherSelectionScreen extends StatefulWidget {
  const WeatherSelectionScreen({super.key});

  @override
  State<WeatherSelectionScreen> createState() => _WeatherSelectionScreenState();
}

class _WeatherSelectionScreenState extends State<WeatherSelectionScreen> {
  WeatherPreference _selectedWeather = WeatherPreference.moderate;

  final List<Map<String, dynamic>> _weatherOptions = [
    {
      'title': 'Cold',
      'icon': Icons.ac_unit,
      'value': WeatherPreference.cold,
      'description': 'Below 20°C',
    },
    {
      'title': 'Normal',
      'icon': Icons.thermostat,
      'value': WeatherPreference.moderate,
      'description': '20-25°C',
    },
    {
      'title': 'Hot',
      'icon': Icons.wb_sunny,
      'value': WeatherPreference.hot,
      'description': 'Above 25°C',
    },
  ];

  Future<void> _handleContinue(OnboardingProvider provider) async {
    provider.updateWeatherPreference(_selectedWeather);
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: "What's the Weather?",
          subtitle: 'Select your current weather condition.',
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: AppAnimations.fadeIn(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: _weatherOptions.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final weather = _weatherOptions[index];
                      return SelectableCardWithIcon(
                        title: weather['title'] as String,
                        subtitle: weather['description'] as String,
                        icon: weather['icon'] as IconData,
                        isSelected: _selectedWeather == weather['value'],
                        onTap: () {
                          setState(() {
                            _selectedWeather = weather['value'] as WeatherPreference;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
