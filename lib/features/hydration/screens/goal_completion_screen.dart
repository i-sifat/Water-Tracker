import 'package:flutter/material.dart';

import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/features/history/history_screen.dart';

class GoalCompletionScreen extends StatefulWidget {
  const GoalCompletionScreen({super.key});

  @override
  State<GoalCompletionScreen> createState() => _GoalCompletionScreenState();
}

class _GoalCompletionScreenState extends State<GoalCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7FB364),
                      width: 3,
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Color(0xFF7FB364),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Continue button
            ContinueButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder:
                        (BuildContext context) =>
                            const HistoryScreenContent(selectedWeekIndex: 0),
                  ),
                );
              },
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
