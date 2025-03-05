import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/providers/hydration_provider.dart';
import 'package:watertracker/screens/add_hydration_screen.dart';
import 'package:watertracker/screens/history_screen.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:watertracker/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/widgets/water_animation.dart';
import 'dart:async'; // Add Timer import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreenContent(),
      const AddHydrationScreenContent(),
      const HistoryScreenContent(selectedWeekIndex: 0),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        // Refresh home screen data when Home icon is tapped again
        Provider.of<HydrationProvider>(context, listen: false).loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    // Calculate water level position (from top of screen)
    final waterLevelPosition =
        screenSize.height * (1 - hydrationProvider.intakePercentage);

    // Add some padding to position the percentage just above the water level
    final percentagePosition = waterLevelPosition - 40;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false, // Allow content to flow behind the bottom navigation bar
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top bar with reset button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            'assets/navbaricons/setting page top right icon.svg',
                            width: 30,
                            height: 30,
                            color: AppColors.darkBlue,
                          ),
                          onPressed: hydrationProvider.resetIntake,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 130),

                // Current intake display
                Text(
                  '${hydrationProvider.currentIntake} ml',
                  style: const TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeadline,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),

                // Remaining text
                Text(
                  'Remaining: ${hydrationProvider.remainingIntake} ml',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSubtitle,
                  ),
                ),

                // Avatar section
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                      hydrationProvider.selectedAvatar == AvatarOption.male
                          ? 'assets/avatars/male-avater.svg'
                          : 'assets/avatars/female-avater.svg',
                      width: 390,
                      height: 390,
                    ),
                  ),
                ),

                // Bottom spacing to accommodate navbar
                const SizedBox(height: 80),
              ],
            ),

            // Water animation overlay
            Positioned.fill(
              child: IgnorePointer(
                // Make water layer non-interactive
                child: WaterAnimation(
                  progress: hydrationProvider.intakePercentage,
                  waterColor: AppColors.waterFull,
                  backgroundColor: AppColors.waterLow,
                  width: screenSize.width,
                  height: screenSize.height,
                ),
              ),
            ),

            // Percentage indicator that moves with water level
            Positioned(
              left: 26,
              top: percentagePosition.clamp(
                100.0, // Don't go higher than this
                screenSize.height - 150.0, // Don't go lower than this
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${(hydrationProvider.intakePercentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
