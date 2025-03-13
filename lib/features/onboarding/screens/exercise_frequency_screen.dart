import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/features/onboarding/screens/vegetable_intake_screen.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({Key? key}) : super(key: key);

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  int _selectedLevel = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.assessmentText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('Assessment', style: AppTypography.subtitle),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '5 of 10',
              style: TextStyle(
                color: AppColors.pageCounter,
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
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Fitness Level',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.assessmentText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'How frequent do you take exercise?',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.pageCounter,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 100),

                // Fitness equipment illustration
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: SvgPicture.asset(
                    'assets/images/icons/onboarding_elements/trainning_icon.svg',
                  ),
                ),

                const Spacer(),

                // Custom slider with tick marks
                Stack(
                  children: [
                    // Background track with tick marks
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                color: AppColors.lightBlue.withAlpha(77),
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
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Frequent',
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
                                '?',
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
                        '2-3x Weekly',
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
            child: ContinueButton(
              onPressed: () {
                _saveFitnessLevel().then((_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VegetablesFruitsScreen(),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    _saveFitnessLevel().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const VegetablesFruitsScreen()),
      );
    });
  }

  Future<void> _saveFitnessLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fitness_level', _selectedLevel);
  }
}
