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

            // Font sizes matching the image
            final fontSize =
                distanceFromCenter == 0
                    ? 120.0 // Selected item - very large
                    : distanceFromCenter == 1
                    ? 80.0 // Adjacent items - large
                    : distanceFromCenter == 2
                    ? 50.0 // Far items - medium
                    : 30.0; // Very far items - small

            // Colors matching the image
            final color =
                distanceFromCenter == 0
                    ? selectedTextColor // White for selected
                    : distanceFromCenter == 1
                    ? unselectedTextColor // Dark gray for adjacent
                    : farTextColor; // Light gray for far items

            // Opacity for items beyond visible range
            final opacity =
                distanceFromCenter > 3
                    ? 0.0
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
                child: Container(
                  width: 200.0,
                  height: distanceFromCenter == 0 ? 100.0 : 70.0,
                  decoration: distanceFromCenter == 0
                      ? BoxDecoration(
                          color: highlightColor,
                          borderRadius: BorderRadius.circular(25),
                        )
                      : null,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: color,
                        fontFamily: 'Nunito',
                      ),
                      child: Text(age.toString(), textAlign: TextAlign.center),
                    ),
                  ),
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
  int _selectedAge = 19; // Changed to 19 to match image

  // Adjusted font sizes for better visibility
  final double _maxFontSize = 120.0; // Adjusted to match image
  final double _minFontSize = 30.0; // Adjusted for better contrast
  final double _itemExtent = 140.0; // Adjusted for better spacing

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
          subtitle: null, // Remove subtitle to match image
          onContinue: () => _handleContinue(onboardingProvider),
          isLoading: onboardingProvider.isSaving,
          child: Center(
            child: Container(
              height: 300.0,
              width: 200.0,
              child: AgeSelectionWheel(
                scrollController: _scrollController,
                ages: _ages,
                selectedAge: _selectedAge,
                itemExtent: _itemExtent,
                highlightColor: AppColors.ageSelectionHighlight,
                selectedTextColor: Colors.white,
                unselectedTextColor: AppColors.ageSelectionText,
                farTextColor: AppColors.ageSelectionTextLight,
                maxFontSize: _maxFontSize,
                minFontSize: _minFontSize,
                onSelectedItemChanged: _handleSelectionChange,
              ),
            ),
          ),
        );
      },
    );
  }
}
