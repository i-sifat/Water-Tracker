import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:watertracker/screens/history_screen.dart';
import 'package:watertracker/utils/app_colors.dart';

class GoalCompletionScreen extends StatefulWidget {
  const GoalCompletionScreen({super.key});

  @override
  State<GoalCompletionScreen> createState() => _GoalCompletionScreenState();
}

class _GoalCompletionScreenState extends State<GoalCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showCheck = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Start showing the check mark after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showCheck = true;
        });
        _animationController.forward();
      }
    });

    // Listen for animation completion to enable tap
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToHistory() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HistoryScreenContent(selectedWeekIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // Celebration text
            const Text(
              "You've reached\nour goal!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // Animated check icon
            GestureDetector(
              onTap:
                  _animationController.isCompleted ? _navigateToHistory : null,
              child: AnimatedOpacity(
                opacity: _showCheck ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkBlue,
                  ),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40 * _animationController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

// Alternative implementation with Lottie animation
class GoalCompletionScreenWithLottie extends StatefulWidget {
  const GoalCompletionScreenWithLottie({Key? key}) : super(key: key);

  @override
  State<GoalCompletionScreenWithLottie> createState() =>
      _GoalCompletionScreenWithLottieState();
}

class _GoalCompletionScreenWithLottieState
    extends State<GoalCompletionScreenWithLottie> {
  bool _animationCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // Celebration text
            Text(
              "You've reached\nour goal!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // Lottie animation for check icon
            GestureDetector(
              onTap:
                  _animationCompleted
                      ? () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => const HistoryScreenContent(
                                  selectedWeekIndex: 0,
                                ),
                          ),
                        );
                      }
                      : null,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkBlue,
                ),
                child: Lottie.asset(
                  'assets/animations/check_animation.json', // Add this Lottie file to your assets
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    // Mark as complete after animation runs
                    Future.delayed(composition.duration, () {
                      if (mounted) {
                        setState(() {
                          _animationCompleted = true;
                        });
                      }
                    });
                  },
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
