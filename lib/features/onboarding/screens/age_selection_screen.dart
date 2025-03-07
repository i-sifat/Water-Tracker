import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:watertracker/features/onboarding/screens/weight_selection_screen.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  late final FixedExtentScrollController _scrollController;
  late final List<int> _ages;
  int _selectedAge = 19; // Default selected age

  // Constants for better readability and adjustability
  final double _maxFontSize = 64.0;
  final double _minFontSize = 32.0;
  final double _itemExtent = 80.0;
  final Color _highlightColor = const Color(0xFF7671FF);
  final Color _selectedTextColor = Colors.white;
  final Color _unselectedTextColor = const Color(0xFF323062);
  final Color _farTextColor = Colors.grey.shade300;

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

  // Trigger vibration when the selected age changes
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF323062)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Assessment',
          style: TextStyle(
            color: Color(0xFF323062),
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
              '3 of 17',
              style: TextStyle(
                color: Color(0xFF323062),
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
            child: Text(
              "What's your Age?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF323062),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fixed center selection indicator (behind the wheel)
                Container(
                  height: _itemExtent,
                  margin: const EdgeInsets.symmetric(horizontal: 80),
                  decoration: BoxDecoration(
                    color: _highlightColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                // The customized wheel widget that scrolls over the fixed container
                AgeSelectionWheel(
                  scrollController: _scrollController,
                  ages: _ages,
                  selectedAge: _selectedAge,
                  itemExtent: _itemExtent,
                  highlightColor: _highlightColor,
                  selectedTextColor: _selectedTextColor,
                  unselectedTextColor: _unselectedTextColor,
                  farTextColor: _farTextColor,
                  maxFontSize: _maxFontSize,
                  minFontSize: _minFontSize,
                  onSelectedItemChanged: _handleSelectionChange,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: ElevatedButton(
              onPressed: () {
                _saveAge().then((_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WeightSelectionScreen(),
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _highlightColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

// Custom wheel widget that implements advanced styling and animations
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
        // We're just using this to rebuild on scroll for animated transitions
        if (notification is ScrollUpdateNotification) {
          // This doesn't need to do anything specific
          // The rebuild handles the animations
        }
        return false;
      },
      child: ListWheelScrollView.useDelegate(
        controller: scrollController,
        itemExtent: itemExtent,
        perspective: 0.002,
        diameterRatio: 1.8,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: ages.length,
          builder: (context, index) {
            final age = ages[index];
            // Calculate distance from center for animated scaling
            final distanceFromCenter =
                (scrollController.hasClients
                        ? scrollController.selectedItem - index
                        : 0)
                    .abs();

            // Calculate the scaled font size based on distance from center
            // We use a non-linear scaling that decreases faster as we move away
            final fontSize =
                distanceFromCenter <= 2
                    ? maxFontSize -
                        (distanceFromCenter * (maxFontSize - minFontSize) / 2)
                    : minFontSize;

            // Determine text color based on distance
            final color =
                distanceFromCenter == 0
                    ? selectedTextColor
                    : distanceFromCenter <= 2
                    ? unselectedTextColor
                    : farTextColor;

            // Apply fade in/out animation for smooth transitions
            final opacity =
                distanceFromCenter > 5
                    ? 0.5
                    : distanceFromCenter > 3
                    ? 0.7
                    : 1.0;

            // Calculate font weight based on distance
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
