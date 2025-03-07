import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({Key? key}) : super(key: key);

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  int _selectedLevel = 0; // Default to first option (Frequent)

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
                const SizedBox(height: 40),

                // Fitness equipment illustration with additional equipment icons
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main treadmill
                    SvgPicture.asset(
                      'assets/onboarding_elements/trainning_icon.svg',
                      height: 200,
                    ),

                    // Additional positioned equipment can be added if needed
                    // These would be added if the SVG doesn't include all equipment shown in the image
                  ],
                ),

                const Spacer(),

                // Slider container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0FF),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Stack(
                      children: [
                        // Three vertical line indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(3, (index) {
                            return Container(
                              width: 2,
                              height: 40,
                              color: Colors.white,
                            );
                          }),
                        ),

                        // Animated selection pill
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          left:
                              8 +
                              (_selectedLevel *
                                  ((MediaQuery.of(context).size.width - 48) /
                                      3)),
                          top: 8,
                          child: GestureDetector(
                            onTap: () {
                              // This is just to ensure the blue pill is tappable if needed
                            },
                            child: Container(
                              width:
                                  (MediaQuery.of(context).size.width - 64) / 3,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(27),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Touch areas for each option
                        Row(
                          children: List.generate(3, (index) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedLevel = index;
                                  });
                                  HapticFeedback.selectionClick();
                                },
                                child: Container(color: Colors.transparent),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Labels below slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            "?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the next screen
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => const NextScreen(),
                //   ),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
