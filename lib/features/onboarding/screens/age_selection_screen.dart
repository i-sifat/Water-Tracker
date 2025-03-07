import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/weight_selection_screen.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  late final FixedExtentScrollController _scrollController;
  late final List<int> _ages;
  int _selectedAge = 45;

  final double _maxFontSize = 64;
  final double _minFontSize = 32;
  final double _itemExtent = 80;

  @override
  void initState() {
    super.initState();
    _ages = List.generate(100, (index) => index + 1);
    _scrollController = FixedExtentScrollController(
      initialItem: _ages.indexOf(_selectedAge),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_age', _selectedAge);
  }

  void _handleSelectionChange(int index) {
    if (_ages[index] != _selectedAge) {
      setState(() => _selectedAge = _ages[index]);
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.vibrate(duration: 25, amplitude: 50);
        } else {
          HapticFeedback.lightImpact();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // In AgeSelectionScreen's build method, update the AppBar:
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
              '3 of 10',
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
                Container(
                  height: _itemExtent,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 120,
                    // vertical: 50,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.selectedBorder,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                AgeSelectionWheel(
                  scrollController: _scrollController,
                  ages: _ages,
                  selectedAge: _selectedAge,
                  itemExtent: _itemExtent,
                  highlightColor: AppColors.selectedBorder,
                  selectedTextColor: AppColors.buttonText,
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
                  context.read<OnboardingProvider>().nextPage();
                  Navigator.of(context).push(
                    MaterialPageRoute(
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
}

class AgeSelectionWheel extends StatelessWidget {
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

  const AgeSelectionWheel({
    super.key,
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
  });

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
        perspective: 0.001,
        diameterRatio: 1.3,
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

            final fontSize =
                distanceFromCenter <= 2
                    ? maxFontSize -
                        (distanceFromCenter * (maxFontSize - minFontSize) / 2)
                    : minFontSize;

            final color =
                distanceFromCenter == 0
                    ? selectedTextColor
                    : distanceFromCenter <= 2
                    ? unselectedTextColor
                    : farTextColor;

            final opacity =
                distanceFromCenter > 5
                    ? 0.5
                    : distanceFromCenter > 3
                    ? 0.7
                    : 1.0;

            final fontWeight =
                distanceFromCenter == 0
                    ? FontWeight.w700
                    : distanceFromCenter <= 1
                    ? FontWeight.w600
                    : FontWeight.w500;

            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: color,
                ),
                child: Opacity(
                  opacity: opacity,
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
