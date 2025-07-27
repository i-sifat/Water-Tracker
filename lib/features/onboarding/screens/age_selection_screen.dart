import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

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

  final void Function(int) onSelectedItemChanged;

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
                    ? unselectedTextColor.withValues(alpha: 0.9)
                    : distanceFromCenter == 2
                    ? unselectedTextColor.withValues(alpha: 0.5)
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

  void _handleSelectionChange(int index) {
    if (_ages[index] != _selectedAge) {
      setState(() => _selectedAge = _ages[index]);
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 25, amplitude: 50);
        } else {
          HapticFeedback.lightImpact();
        }
      });
    }
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    provider.updateAge(_selectedAge);
    await provider.navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          title: "What's your Age?",
          subtitle: 'This helps us calculate your personalized hydration goal',
          backgroundColor: AppColors.onBoardingpagebackground,
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer container with stroke effect
              Container(
                height: _itemExtent,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.waterFull.withValues(alpha: 0.3),
                    width: 9,
                  ),
                ),
              ),
              // Inner container (the blue background)
              Container(
                height: _itemExtent - 9,
                width: 194,
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
                selectedTextColor: Colors.white,
                unselectedTextColor: AppColors.assessmentText,
                farTextColor: Colors.grey.shade300,
                maxFontSize: _maxFontSize,
                minFontSize: _minFontSize,
                onSelectedItemChanged: _handleSelectionChange,
              ),
            ],
          ),
        );
      },
    );
  }
}