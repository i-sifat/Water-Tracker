import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/age_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/data_summary_screen.dart';
import 'package:watertracker/features/onboarding/screens/exercise_frequency_screen.dart';
import 'package:watertracker/features/onboarding/screens/gender_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/goal_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/notification_setup_screen.dart';
import 'package:watertracker/features/onboarding/screens/pregnancy_status_screen.dart';
import 'package:watertracker/features/onboarding/screens/sugary_drinks_screen.dart';
import 'package:watertracker/features/onboarding/screens/vegetable_intake_screen.dart';
import 'package:watertracker/features/onboarding/screens/weather_preference_screen.dart';
import 'package:watertracker/features/onboarding/screens/weight_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/welcome_screen.dart';

/// Main onboarding flow screen that manages navigation between steps
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, onboardingProvider, child) {
          // Listen to step changes and animate to the correct page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients &&
                _pageController.page?.round() !=
                    onboardingProvider.currentStep) {
              _pageController.animateToPage(
                onboardingProvider.currentStep,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });

          if (onboardingProvider.isLoading) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.waterFull),
                    SizedBox(height: 16),
                    Text(
                      'Loading your data...',
                      style: TextStyle(
                        color: AppColors.textSubtitle,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (onboardingProvider.error != null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.red[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        onboardingProvider.error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSubtitle,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              onboardingProvider.clearError();
                            },
                            child: const Text('Dismiss'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              onboardingProvider.resetOnboarding();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.waterFull,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Use PageView for smooth navigation between steps
          return Scaffold(
            backgroundColor: AppColors.background,
            body: PageView.builder(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable swipe navigation
              itemCount: OnboardingProvider.totalSteps,
              itemBuilder: (context, index) {
                return _getScreenForStep(index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _getScreenForStep(int step) {
    switch (step) {
      case 0:
        return const WelcomeScreen();
      case 1:
        return const GoalSelectionScreen();
      case 2:
        return const GenderSelectionScreen();
      case 3:
        return const SugaryBeveragesScreen();
      case 4:
        return const AgeSelectionScreen();
      case 5:
        return const WeightSelectionScreen();
      case 6:
        return const PregnancyScreen();
      case 7:
        return const FitnessLevelScreen();
      case 8:
        return const VegetablesFruitsScreen();
      case 9:
        return const WeatherSelectionScreen();
      case 10:
        return const NotificationSetupScreen();
      case 11:
        return const CompileDataScreen();
      default:
        return const WelcomeScreen();
    }
  }
}

/// Onboarding entry point that checks if onboarding is needed
class OnboardingEntryScreen extends StatelessWidget {
  const OnboardingEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingProvider.isOnboardingCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isCompleted = snapshot.data ?? false;

        if (isCompleted) {
          // Navigate to home screen if onboarding is already completed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show onboarding flow
        return const OnboardingFlowScreen();
      },
    );
  }
}
