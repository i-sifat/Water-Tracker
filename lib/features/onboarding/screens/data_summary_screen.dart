import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/utils/water_intake_calculator.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

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

    // Calculate water intake and save onboarding status after a delay
    Future.delayed(const Duration(seconds: 2), () async {
      await _calculateUserData();
      await _saveOnboardingStatus();

      if (!mounted) return;

      // Navigate to home screen
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
      );
    });
  }

  Future<void> _saveOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  Future<void> _calculateUserData() async {
    try {
      // Calculate the daily intake
      final calculatedIntake =
          await WaterIntakeCalculator.calculateWaterIntake();

      if (!mounted) return;

      // Update provider with calculated intake
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      await provider.setDailyGoal(calculatedIntake);
    } catch (e) {
      debugPrint('Error calculating water intake: $e');
      // Handle error appropriately
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error calculating water intake. Using default value.',
            ),
          ),
        );
      }
    }
  }
}
