import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/screens/onboarding/vegetables-fruits-screen.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:watertracker/widgets/primary_button.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({Key? key}) : super(key: key);

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  int _selectedLevel = 0;

  Future<void> _saveFitnessLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fitness_level', _selectedLevel);
  }

  void _handleContinue() {
    _saveFitnessLevel().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const VegetablesFruitsScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Assessment',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '6 of 17',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Fitness Level",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  "How frequent do you take exercise?",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Fitness equipment illustration
                SizedBox(
                  height: 160,
                  child: SvgPicture.asset(
                    'assets/onboarding_elements/trainning_icon.svg',
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(),

                // Custom slider with tick marks
                Stack(
                  children: [
                    // Background track with tick marks
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0FF),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            return Container(
                              width: 2,
                              height: 24,
                              color: Colors.white,
                            );
                          }),
                        ),
                      ),
                    ),

                    // Slider thumb that overlaps the track
                    Positioned(
                      top: -8,
                      left:
                          24 +
                          (_selectedLevel *
                              ((MediaQuery.of(context).size.width - 48) / 3)),
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          final width = MediaQuery.of(context).size.width - 48;
                          final segmentWidth = width / 3;
                          final dx = details.globalPosition.dx - 24;
                          final newLevel = (dx / segmentWidth).round().clamp(
                            0,
                            2,
                          );
                          if (newLevel != _selectedLevel) {
                            setState(() {
                              _selectedLevel = newLevel;
                              HapticFeedback.selectionClick();
                            });
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lightBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Labels below slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Frequent",
                            style: TextStyle(
                              color:
                                  _selectedLevel == 0
                                      ? AppColors.darkBlue
                                      : Colors.grey,
                              fontSize: 16,
                              fontWeight:
                                  _selectedLevel == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: const Center(
                              child: Text(
                                "?",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "2-3x Weekly",
                        style: TextStyle(
                          color:
                              _selectedLevel == 2
                                  ? AppColors.darkBlue
                                  : Colors.grey,
                          fontSize: 16,
                          fontWeight:
                              _selectedLevel == 2
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: PrimaryButton(
              text: 'Continue',
              onPressed: _handleContinue,
              rightIcon: const Icon(Icons.arrow_forward, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
