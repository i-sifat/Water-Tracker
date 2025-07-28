import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/features/onboarding/screens/vegetable_intake_screen.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({super.key});

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  int _selectedLevel = 0; // 0: Frequent, 1: Medium, 2: 2-3x Weekly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onBoardingpagebackground,
      appBar: AppBar(
        backgroundColor: AppColors.onBoardingpagebackground,
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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '6 of 10',
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
                const SizedBox(height: 60), // Reduced from 100

                // Made image smaller
                SizedBox(
                  height: 200, // Reduced from 300
                  width: double.infinity,
                  child: SvgPicture.asset(
                    'assets/images/icons/onboarding_elements/trainning_icon.svg',
                  ),
                ),

                const Spacer(),

                // Fixed slider alignment and colors
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Stack(
                    children: [
                      // Background slider track
                      Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0FF),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      
                      // Vertical divider lines (ash color)
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            return Container(
                              width: 2,
                              height: 24,
                              color: Colors.grey.shade400, // Ash color
                            );
                          }),
                        ),
                      ),

                      // Draggable circle - properly aligned
                      Positioned(
                        top: 2, // Positioned on top of slider
                        left: _getSliderPosition(context),
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final width = MediaQuery.of(context).size.width - 48;
                            final segmentWidth = width / 2; // Only 2 segments for 3 positions
                            final dx = details.globalPosition.dx - 24;
                            final newLevel = (dx / segmentWidth).round().clamp(0, 2);
                            if (newLevel != _selectedLevel) {
                              setState(() {
                                _selectedLevel = newLevel;
                                HapticFeedback.selectionClick();
                              });
                            }
                          },
                          child: Container(
                            width: 60,
                            height: 60,
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
                ),

                const SizedBox(height: 16),

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

                const SizedBox(height: 20), // Reduced from 40
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32), // Moved button up
            child: ContinueButton(
              onPressed: () async {
                await _saveFitnessLevel();
                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VegetablesFruitsScreen(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate slider position
  double _getSliderPosition(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 48; // Account for padding
    const circleWidth = 60.0;
    
    // Calculate positions for 3 stops: start, middle, end
    switch (_selectedLevel) {
      case 0: // Frequent - leftmost position
        return 0;
      case 1: // Medium - center position
        return (screenWidth - circleWidth) / 2;
      case 2: // 2-3x Weekly - rightmost position
        return screenWidth - circleWidth;
      default:
        return 0;
    }
  }

  Future<void> _saveFitnessLevel() async {
    final prefs = await SharedPreferences.getInstance();
    // Save as 2 for Frequent, 1 for Medium, 0 for 2-3x Weekly
    // This matches the calculator's expected values
    final levelValue = 2 - _selectedLevel;
    await prefs.setInt('fitness_level', levelValue);
  }
}
