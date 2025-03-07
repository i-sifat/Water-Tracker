import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/core/utils/app_animations.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';

// Main screen widget that appears when users want to add hydration
class AddHydrationScreen extends StatefulWidget {
  const AddHydrationScreen({Key? key}) : super(key: key);

  @override
  _AddHydrationScreenState createState() => _AddHydrationScreenState();
}

class _AddHydrationScreenState extends State<AddHydrationScreen> {
  // Current selected index for the bottom navigation
  int _selectedIndex = 1;

  // List of screens corresponding to each navigation item
  static final List<Widget> _widgetOptions = <Widget>[
    const Placeholder(), // Home screen content (placeholder for now)
    const AddHydrationScreenContent(), // Current screen content
    const Placeholder(), // History screen content (placeholder for now)
  ];

  // Function to update the selected navigation index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Basic scaffold structure for the screen
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _widgetOptions.elementAt(
          _selectedIndex,
        ), // Show selected screen content
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Content widget specifically for the Add Hydration screen
class AddHydrationScreenContent extends StatefulWidget {
  const AddHydrationScreenContent({Key? key}) : super(key: key);

  @override
  State<AddHydrationScreenContent> createState() =>
      _AddHydrationScreenContentState();
}

class _AddHydrationScreenContentState extends State<AddHydrationScreenContent>
    with SingleTickerProviderStateMixin {
  // Using the separated animation controller and animations
  late HydrationAnimations animations;

  @override
  void initState() {
    super.initState();

    // Initialize the animations
    animations = HydrationAnimations(vsync: this);
    animations.startAnimations(); // Start animations when screen loads
  }

  @override
  void dispose() {
    animations.dispose(); // Clean up animation resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the hydration data from the provider
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    final Color darkBlueColor = const Color(0xFF323062);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 200), // Space at the top
        // Animated circular progress indicator
        ScaleTransition(
          scale: animations.circleAnimation,
          child: _buildProgressCircle(hydrationProvider, darkBlueColor),
        ),

        const SizedBox(
          height: 80,
        ), // 50px gap between progress circle and buttons
        // First row of water amount buttons with slide animation
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ), // Bring buttons inward
          child: Row(
            children: [
              Expanded(
                child: SlideTransition(
                  position: animations.firstRowLeftSlideAnimation,
                  child: _buildAmountButton(
                    context,
                    250,
                    hydrationProvider,
                    const Color(0xFFE9D9FF), // Light purple
                    darkBlueColor,
                  ),
                ),
              ),
              const SizedBox(width: 15), // Keep same distance between buttons
              Expanded(
                child: SlideTransition(
                  position: animations.firstRowRightSlideAnimation,
                  child: _buildAmountButton(
                    context,
                    500,
                    hydrationProvider,
                    const Color(0xFFD4FFFB), // Light cyan
                    darkBlueColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15), // Keep same distance between rows
        // Second row of water amount buttons with slide animation
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ), // Bring buttons inward
          child: Row(
            children: [
              Expanded(
                child: SlideTransition(
                  position: animations.secondRowLeftSlideAnimation,
                  child: _buildAmountButton(
                    context,
                    100,
                    hydrationProvider,
                    const Color(0xFFDAFFC7), // Light green
                    darkBlueColor,
                  ),
                ),
              ),
              const SizedBox(width: 15), // Keep same distance between buttons
              Expanded(
                child: SlideTransition(
                  position: animations.secondRowRightSlideAnimation,
                  child: _buildAmountButton(
                    context,
                    400,
                    hydrationProvider,
                    const Color(0xFFFFF8BB), // Light yellow
                    darkBlueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget to build the circular progress indicator showing hydration stats
  Widget _buildProgressCircle(
    HydrationProvider hydrationProvider,
    Color darkBlueColor,
  ) {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        margin: const EdgeInsets.only(bottom: 40),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: hydrationProvider.intakePercentage,
                strokeWidth: 15,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF918DFE), // Purple color
                ),
              ),
            ),
            // Text information in the center of the circle
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Percentage display
                Text(
                  "${(hydrationProvider.intakePercentage * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 5),
                // Current intake display
                Text(
                  "${hydrationProvider.currentIntake} ml",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: darkBlueColor,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 5),
                // Remaining intake display
                Text(
                  "-${hydrationProvider.remainingIntake} ml",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7F8192),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build each water amount button
  Widget _buildAmountButton(
    BuildContext context,
    int amount,
    HydrationProvider provider,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      height: 75, // Reduced height by 10px
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          // Add water when button is pressed
          provider.addHydration(amount);

          // Show feedback to the user
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $amount ml of water'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF323062),
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          minimumSize: const Size.fromHeight(70), // Reduced height by 10px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "$amount ml",
          style: TextStyle(
            fontSize: 20, // Reduced text size from 24 to 20
            fontWeight: FontWeight.w600,
            color: textColor,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
