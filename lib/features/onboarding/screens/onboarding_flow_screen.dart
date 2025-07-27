import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
class OnboardingFlowScreen extends StatelessWidget {
  const OnboardingFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, onboardingProvider, child) {
          if (onboardingProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (onboardingProvider.error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        onboardingProvider.error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        onboardingProvider.resetOnboarding();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Return the appropriate screen based on current step
          return _getScreenForStep(onboardingProvider.currentStep);
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isCompleted = snapshot.data ?? false;
        
        if (isCompleted) {
          // Navigate to home screen if onboarding is already completed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show onboarding flow
        return const OnboardingFlowScreen();
      },
    );
  }
}