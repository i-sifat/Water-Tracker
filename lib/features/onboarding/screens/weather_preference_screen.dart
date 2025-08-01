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

class _WeatherSelectionScreenState extends State<WeatherSelectionScreen>
    with TickerProviderStateMixin {
  WeatherPreference _selectedWeather = WeatherPreference.moderate;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    provider.updateWeatherPreference(_selectedWeather);
    await provider.navigateNext();
  }

  void _handleWeatherChange(WeatherPreference newWeather, {bool isSwipeRight = false}) {
    setState(() {
      _selectedWeather = newWeather;
    });
    
    // Trigger slide animation
    _slideController.reset();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: "What's the Weather?",
          subtitle: 'Please select your current mood.',
          backgroundColor: AppColors.onboardingBackground,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: Column(
            children: [
              const SizedBox(height: 80),
              
              // Weather mood selector with sliding cards
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // Determine swipe direction and change weather
                    if (details.primaryVelocity! > 0) {
                      // Swipe right - go to previous weather
                      switch (_selectedWeather) {
                        case WeatherPreference.cold:
                          _handleWeatherChange(WeatherPreference.hot, isSwipeRight: true);
                          break;
                        case WeatherPreference.moderate:
                          _handleWeatherChange(WeatherPreference.cold, isSwipeRight: true);
                          break;
                        case WeatherPreference.hot:
                          _handleWeatherChange(WeatherPreference.moderate, isSwipeRight: true);
                          break;
                      }
                    } else if (details.primaryVelocity! < 0) {
                      // Swipe left - go to next weather
                      switch (_selectedWeather) {
                        case WeatherPreference.cold:
                          _handleWeatherChange(WeatherPreference.moderate, isSwipeRight: false);
                          break;
                        case WeatherPreference.moderate:
                          _handleWeatherChange(WeatherPreference.hot, isSwipeRight: false);
                          break;
                        case WeatherPreference.hot:
                          _handleWeatherChange(WeatherPreference.cold, isSwipeRight: false);
                          break;
                      }
                    }
                  },
                  child: Stack(
                    children: [
                      // Left card (previous weather)
                      Positioned(
                        left: -100,
                        top: 100,
                        child: AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                _slideAnimation.value * 150,
                                0,
                              ),
                              child: Transform.scale(
                                scale: 1.0 - (_slideAnimation.value * 0.2),
                                child: Opacity(
                                  opacity: 0.3 + (_slideAnimation.value * 0.2),
                                  child: _buildWeatherCard(_getPreviousWeather()),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Right card (next weather)
                      Positioned(
                        right: -100,
                        top: 100,
                        child: AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                -_slideAnimation.value * 150,
                                0,
                              ),
                              child: Transform.scale(
                                scale: 1.0 - (_slideAnimation.value * 0.2),
                                child: Opacity(
                                  opacity: 0.3 + (_slideAnimation.value * 0.2),
                                  child: _buildWeatherCard(_getNextWeather()),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Center selected card
                      Center(
                        child: AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: _buildWeatherCard(_selectedWeather),
                              ),
                            );
                          },
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
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      
                      Positioned(
                        bottom: 50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.weatherSelectedCard,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Weather label with animation
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_slideAnimation.value * 0.2),
                    child: Text(
                      _getWeatherLabel(_selectedWeather),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.assessmentText,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  WeatherPreference _getPreviousWeather() {
    switch (_selectedWeather) {
      case WeatherPreference.cold:
        return WeatherPreference.hot;
      case WeatherPreference.moderate:
        return WeatherPreference.cold;
      case WeatherPreference.hot:
        return WeatherPreference.moderate;
    }
  }

  WeatherPreference _getNextWeather() {
    switch (_selectedWeather) {
      case WeatherPreference.cold:
        return WeatherPreference.moderate;
      case WeatherPreference.moderate:
        return WeatherPreference.hot;
      case WeatherPreference.hot:
        return WeatherPreference.cold;
    }
  }

  Widget _buildWeatherCard(WeatherPreference weather) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: weather == _selectedWeather 
            ? AppColors.weatherSelectedCard 
            : AppColors.weatherUnselectedFace,
        borderRadius: BorderRadius.circular(50),
        boxShadow: weather == _selectedWeather ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: _buildWeatherFace(weather),
    );
  }

  Widget _buildWeatherFace(WeatherPreference weather) {
    final isSelected = weather == _selectedWeather;
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
          
          // Mouth based on weather preference
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
        return 'Normal';
      case WeatherPreference.hot:
        return 'Hot';
    }
  }
}