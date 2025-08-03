import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/navigation/onboarding_navigator.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/age_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/daily_routine_screen.dart';
import 'package:watertracker/features/onboarding/screens/data_summary_screen.dart';
import 'package:watertracker/features/onboarding/screens/drink_goal_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/exercise_frequency_screen.dart';
import 'package:watertracker/features/onboarding/screens/gender_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/goal_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/notification_setup_screen.dart';
import 'package:watertracker/features/onboarding/screens/pregnancy_status_screen.dart';
import 'package:watertracker/features/onboarding/screens/premium_unlock_screen.dart';
import 'package:watertracker/features/onboarding/screens/sugary_drinks_screen.dart';
import 'package:watertracker/features/onboarding/screens/vegetable_intake_screen.dart';
import 'package:watertracker/features/onboarding/screens/weather_preference_screen.dart';
import 'package:watertracker/features/onboarding/screens/weight_selection_screen.dart';
import 'package:watertracker/features/onboarding/screens/welcome_screen.dart';

/// Optimized main onboarding flow screen with smooth navigation
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late List<Widget> _onboardingPages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  /// Initialize all onboarding pages
  void _initializePages() {
    _onboardingPages = [
      const WelcomeScreen(),
      const DrinkGoalSelectionScreen(),
      const AgeSelectionScreen(),
      const GenderSelectionScreen(),
      const WeightSelectionScreen(),
      const GoalSelectionScreen(),
      const FitnessLevelScreen(),
      const PregnancyScreen(),
      const SugaryBeveragesScreen(),
      const VegetablesFruitsScreen(),
      const WeatherSelectionScreen(),
      const NotificationSetupScreen(),
      const DailyRoutineScreen(),
      const PremiumUnlockScreen(),
      const CompileDataScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        if (onboardingProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
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
          return _buildErrorScreen(context, onboardingProvider);
        }

        // Use optimized onboarding navigator
        return Scaffold(
          backgroundColor: Colors.white,
          body: OnboardingNavigator(
            pages: _onboardingPages,
            totalSteps: OnboardingProvider.totalSteps,
          ),
        );
      },
    );
  }

  /// Build error screen with recovery options
  Widget _buildErrorScreen(BuildContext context, OnboardingProvider provider) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textSubtitle),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      provider.clearError();
                    },
                    child: const Text('Dismiss'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.resetOnboarding();
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
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
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
