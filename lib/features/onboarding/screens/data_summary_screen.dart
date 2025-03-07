import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/screens/home_screen.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/providers/hydration_provider.dart';

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
  void initState() {
    super.initState();
    _initializeBubbles();
    _calculateUserData();
  }

  void _initializeBubbles() {
    // Create multiple bubbles with different animations
    _bubbleControllers = List.generate(
      8,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + _random.nextInt(1000)),
        vsync: this,
      ),
    );

    _bubbleAnimations =
        _bubbleControllers.map((controller) {
          return Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    // Generate random starting positions for bubbles
    for (int i = 0; i < 8; i++) {
      _bubblePositions.add(
        Offset(_random.nextDouble() * 300, _random.nextDouble() * 300),
      );
    }

    // Start animations
    for (var controller in _bubbleControllers) {
      controller.repeat(reverse: true);
    }
  }

  Future<void> _calculateUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Get user data from preferences
    final weight = prefs.getDouble('user_weight') ?? 70.0;
    final isKg = prefs.getBool('weight_unit_is_kg') ?? true;
    final age = prefs.getInt('user_age') ?? 25;
    final isMale = prefs.getString('selected_gender') == 'male';
    final activityLevel = prefs.getInt('fitness_level') ?? 1;
    final weather = prefs.getString('weather_preference') ?? 'normal';

    // Calculate daily water intake based on factors
    double dailyIntake = _calculateDailyIntake(
      weight: weight,
      isKg: isKg,
      age: age,
      isMale: isMale,
      activityLevel: activityLevel,
      weather: weather,
    );

    // Wait for 2 seconds to show animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Update provider with calculated intake
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    provider.setDailyGoal(dailyIntake.round());

    // Navigate to home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  double _calculateDailyIntake({
    required double weight,
    required bool isKg,
    required int age,
    required bool isMale,
    required int activityLevel,
    required String weather,
  }) {
    // Convert weight to kg if needed
    final weightInKg = isKg ? weight : weight * 0.45359237;

    // Base calculation: 30-35ml per kg of body weight
    double baseIntake = weightInKg * 33;

    // Age adjustment
    if (age > 65) {
      baseIntake *= 0.9;
    } else if (age < 18) {
      baseIntake *= 1.1;
    }

    // Gender adjustment
    if (isMale) {
      baseIntake *= 1.1;
    }

    // Activity level adjustment
    switch (activityLevel) {
      case 0: // Sedentary
        baseIntake *= 1.0;
      case 1: // Moderate
        baseIntake *= 1.2;
      case 2: // Active
        baseIntake *= 1.4;
    }

    // Weather adjustment
    switch (weather) {
      case 'hot':
        baseIntake *= 1.3;
      case 'cold':
        baseIntake *= 0.9;
      default: // normal
        baseIntake *= 1.0;
    }

    // Round to nearest 100ml
    return (baseIntake / 100).round() * 100;
  }

  @override
  void dispose() {
    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: Stack(
        children: [
          // Animated bubbles
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Center text
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
                    color: Colors.white.withOpacity(0.8),
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
}
