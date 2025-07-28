import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/onboarding_completion_screen.dart';

class CompileDataScreen extends StatefulWidget {
  const CompileDataScreen({super.key});

  @override
  State<CompileDataScreen> createState() => _CompileDataScreenState();
}

class _CompileDataScreenState extends State<CompileDataScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _bubbleControllers;
  late List<Animation<double>> _bubbleAnimations;
  final List<Offset> _bubblePositions = [];
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: Stack(
        children: [
          ...List.generate(
            8,
            (index) => AnimatedBuilder(
              animation: _bubbleAnimations[index],
              builder: (context, child) {
                return Positioned(
                  left:
                      _bubblePositions[index].dx +
                      (sin(_bubbleAnimations[index].value * 2 * pi) * 20),
                  top:
                      _bubblePositions[index].dy -
                      (_bubbleAnimations[index].value * 50),
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      width: 100 + (index * 20),
                      height: 100 + (index * 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Compiling\nData...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white.withAlpha(200),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _bubbleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _bubbleControllers = List.generate(
      8,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(seconds: 2 + index),
      ),
    );

    _bubbleAnimations =
        _bubbleControllers.map((controller) {
          return Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
        }).toList();

    // Initialize bubble positions
    // We need to use a post-frame callback to access MediaQuery safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        for (var i = 0; i < 8; i++) {
          _bubblePositions.add(
            Offset(
              _random.nextDouble() * screenWidth,
              screenHeight + _random.nextDouble() * 100,
            ),
          );
        }
      });
    });
  }

  void _startAnimations() {
    // Start all bubble animations
    for (final controller in _bubbleControllers) {
      controller.repeat();
    }

    // Complete onboarding after a delay
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );
      final hydrationProvider = Provider.of<HydrationProvider>(
        context,
        listen: false,
      );

      try {
        // Complete onboarding process
        await onboardingProvider.completeOnboarding();

        // Update hydration provider with calculated goal
        final dailyGoal = onboardingProvider.userProfile.effectiveDailyGoal;
        await hydrationProvider.setDailyGoal(dailyGoal);

        if (!mounted) return;

        // Navigate to completion screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder:
                (context) => OnboardingCompletionScreen(dailyGoal: dailyGoal),
          ),
        );
      } catch (e) {
        debugPrint('Error completing onboarding: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing setup: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}
