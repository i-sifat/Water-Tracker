import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class WeatherSelectionScreen extends StatefulWidget {
  const WeatherSelectionScreen({super.key});

  @override
  State<WeatherSelectionScreen> createState() => _WeatherSelectionScreenState();
}

class _WeatherSelectionScreenState extends State<WeatherSelectionScreen> {
  WeatherPreference _selectedWeather = WeatherPreference.moderate;

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
          subtitle: 'Please select your current mood.',
          backgroundColor: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: null, // We'll handle this manually
          canContinue: false, // We'll handle this manually
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              const SizedBox(height: 80),
              
              // Weather mood selector with emoji faces
              Expanded(
                child: Stack(
                  children: [
                    // Background faces (sad and happy)
                    Positioned(
                      left: -50,
                      top: 100,
                      child: _buildBackgroundFace(isSad: true),
                    ),
                    Positioned(
                      right: -50,
                      top: 100,
                      child: _buildBackgroundFace(isSad: false),
                    ),
                    
                    // Center selected face
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Cycle through weather preferences
                          setState(() {
                            switch (_selectedWeather) {
                              case WeatherPreference.cold:
                                _selectedWeather = WeatherPreference.moderate;
                                break;
                              case WeatherPreference.moderate:
                                _selectedWeather = WeatherPreference.hot;
                                break;
                              case WeatherPreference.hot:
                                _selectedWeather = WeatherPreference.cold;
                                break;
                            }
                          });
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.weatherSelectedCard,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _buildSelectedFace(),
                        ),
                      ),
                    ),
                    
                    // Top and bottom indicators
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.weatherSelectedCard,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 200,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.weatherSelectedCard,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Weather label
              Text(
                _getWeatherLabel(_selectedWeather),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.assessmentText,
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Continue button
              ContinueButton(
                onPressed: () => _handleContinue(onboardingProvider),
                isDisabled: onboardingProvider.isSaving,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedFace() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Eyes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.weatherFaceEyes,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 40),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.weatherFaceEyes,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Mouth based on weather preference
          Container(
            width: 60,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.weatherFaceMouth,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundFace({required bool isSad}) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.weatherUnselectedFace,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Eyes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 30),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Mouth
            Container(
              width: isSad ? 30 : 40,
              height: isSad ? 30 : 6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isSad ? 15 : 3),
              ),
              child: isSad 
                ? const Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.weatherUnselectedFace,
                      size: 20,
                    ),
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }

  String _getWeatherLabel(WeatherPreference preference) {
    switch (preference) {
      case WeatherPreference.cold:
        return 'Cold';
      case WeatherPreference.moderate:
        return 'Normal';
      case WeatherPreference.hot:
        return 'Hot';
    }
  }
}