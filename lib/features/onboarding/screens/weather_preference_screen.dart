import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class WeatherSelectionScreen extends StatefulWidget {
  const WeatherSelectionScreen({super.key});

  @override
  State<WeatherSelectionScreen> createState() => _WeatherSelectionScreenState();
}

class _WeatherSelectionScreenState extends State<WeatherSelectionScreen> {
  late final PageController _pageController;
  int _selectedIndex = 1; // Start with the middle card selected

  final List<WeatherPreference> _weatherOptions = [
    WeatherPreference.cold,
    WeatherPreference.moderate,
    WeatherPreference.hot,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.7,
      initialPage: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.read<OnboardingProvider>().updateWeatherPreference(_weatherOptions[index]);
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    provider.updateWeatherPreference(_weatherOptions[_selectedIndex]);
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: "What's the Weather?",
          subtitle: 'Please select current weather.',
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                child: SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _weatherOptions.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedIndex;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          transform: isSelected
                              ? (Matrix4.identity()..scale(1.1))
                              : (Matrix4.identity()..scale(0.9)),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.weatherSelectedCard
                                : AppColors.weatherUnselectedFace,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ]
                                : null,
                          ),
                          child: _buildWeatherFace(_weatherOptions[index], isSelected),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getWeatherLabel(_weatherOptions[_selectedIndex]),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.assessmentText,
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherFace(WeatherPreference weather, bool isSelected) {
    final eyeColor = isSelected ? AppColors.weatherFaceEyes : Colors.white;
    final mouthColor = isSelected ? AppColors.weatherFaceMouth : Colors.white;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Eyes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isSelected ? 20 : 15,
                height: isSelected ? 20 : 15,
                decoration: BoxDecoration(
                  color: eyeColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: isSelected ? 40 : 30),
              Container(
                width: isSelected ? 20 : 15,
                height: isSelected ? 20 : 15,
                decoration: BoxDecoration(
                  color: eyeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: isSelected ? 30 : 20),
          // Mouth based on weather preference - different expressions
          if (weather == WeatherPreference.hot)
            // Sad face for hot weather
            Container(
              width: isSelected ? 60 : 40,
              height: isSelected ? 8 : 6,
              decoration: BoxDecoration(
                color: mouthColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isSelected ? 4 : 3),
                  topRight: Radius.circular(isSelected ? 4 : 3),
                ),
              ),
            )
          else if (weather == WeatherPreference.cold)
            // Happy face for cold weather
            Container(
              width: isSelected ? 60 : 40,
              height: isSelected ? 8 : 6,
              decoration: BoxDecoration(
                color: mouthColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isSelected ? 4 : 3),
                  bottomRight: Radius.circular(isSelected ? 4 : 3),
                ),
              ),
            )
          else
            // Normal face for moderate weather
            Container(
              width: isSelected ? 60 : 40,
              height: isSelected ? 8 : 6,
              decoration: BoxDecoration(
                color: mouthColor,
                borderRadius: BorderRadius.circular(isSelected ? 4 : 3),
              ),
            ),
        ],
      ),
    );
  }

  String _getWeatherLabel(WeatherPreference preference) {
    switch (preference) {
      case WeatherPreference.cold:
        return 'Cold';
      case WeatherPreference.moderate:
        return 'Normal Weather';
      case WeatherPreference.hot:
        return 'Hot';
    }
  }
}