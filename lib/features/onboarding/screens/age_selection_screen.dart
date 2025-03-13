import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/features/onboarding/screens/weight_selection_screen.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class AgeSelectionWheel extends StatelessWidget {
  const AgeSelectionWheel({
    required this.scrollController,
    required this.ages,
    required this.selectedAge,
    required this.itemExtent,
    required this.highlightColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.farTextColor,
    required this.maxFontSize,
    required this.minFontSize,
    required this.onSelectedItemChanged,
    super.key,
  });
  final FixedExtentScrollController scrollController;
  final List<int> ages;
  final int selectedAge;
  final double itemExtent;
  final Color highlightColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color farTextColor;
  final double maxFontSize;
  final double minFontSize;

  final Function(int) onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          // This rebuild handles the animations
        }
        return false;
      },
      child: ListWheelScrollView.useDelegate(
        controller: scrollController,
        itemExtent: itemExtent,
        perspective: 0.0015,
        diameterRatio: 1.6,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: ages.length,
          builder: (context, index) {
            final age = ages[index];
            final distanceFromCenter =
                (scrollController.hasClients
                        ? scrollController.selectedItem - index
                        : 0)
                    .abs();

            // More dramatic font size difference
            final fontSize =
                distanceFromCenter == 0
                    ? maxFontSize
                    : distanceFromCenter == 1
                    ? maxFontSize * 0.7
                    : distanceFromCenter == 2
                    ? maxFontSize * 0.55
                    : minFontSize;

            // More dramatic color transition
            final color =
                distanceFromCenter == 0
                    ? selectedTextColor
                    : distanceFromCenter == 1
                    ? unselectedTextColor.withOpacity(0.9)
                    : distanceFromCenter == 2
                    ? unselectedTextColor.withOpacity(0.5)
                    : farTextColor;

            // Make items beyond visible range nearly invisible
            final opacity =
                distanceFromCenter > 3
                    ? 0.0 // Hide items beyond 3 positions
                    : distanceFromCenter == 3
                    ? 0.3
                    : 1.0;

            final fontWeight =
                distanceFromCenter == 0
                    ? FontWeight.w700
                    : distanceFromCenter <= 1
                    ? FontWeight.w600
                    : FontWeight.w500;

            return Opacity(
              opacity: opacity,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: color,
                  ),
                  child: Text(age.toString(), textAlign: TextAlign.center),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  late final FixedExtentScrollController _scrollController;
  late final List<int> _ages;
  int _selectedAge = 45;

  // Increase font sizes for better visibility
  final double _maxFontSize = 140; // Increased from 74
  final double _minFontSize = 28; // Slightly decreased to create more contrast
  final double _itemExtent = 160; // Increased from 100 for more spacing

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
              '4 of 10',
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
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 40, 24, 60),
            child: Text("What's your Age?", style: AppTypography.headline),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer container with stroke effect
                Container(
                  height: _itemExtent,
                  width: 200, // Fixed width to match design
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.waterFull.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
                // Inner container (the blue background)
                Container(
                  height: _itemExtent - 6, // Account for the border
                  width: 194, // Account for the border
                  decoration: BoxDecoration(
                    color: AppColors.waterFull,
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                AgeSelectionWheel(
                  scrollController: _scrollController,
                  ages: _ages,
                  selectedAge: _selectedAge,
                  itemExtent: _itemExtent,
                  highlightColor: AppColors.selectedBorder,
                  selectedTextColor:
                      Colors.white, // Changed to white for better contrast
                  unselectedTextColor: AppColors.assessmentText,
                  farTextColor: Colors.grey.shade300,
                  maxFontSize: _maxFontSize,
                  minFontSize: _minFontSize,
                  onSelectedItemChanged: _handleSelectionChange,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: ContinueButton(
              onPressed: () {
                _saveAge().then((_) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const WeightSelectionScreen(),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ages = List.generate(100, (index) => index + 1);
    _scrollController = FixedExtentScrollController(
      initialItem: _ages.indexOf(_selectedAge),
    );
  }

  void _handleSelectionChange(int index) {
    if (_ages[index] != _selectedAge) {
      setState(() => _selectedAge = _ages[index]);
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator) {
          Vibration.vibrate(duration: 25, amplitude: 50);
        } else {
          HapticFeedback.lightImpact();
        }
      });
    }
  }

  Future<void> _saveAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_age', _selectedAge);
  }
}
