import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/core/widgets/water_animation.dart';
import 'package:watertracker/features/history/history_screen.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
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
    final waterLevelPosition =
        screenSize.height * (1 - hydrationProvider.intakePercentage);
    final percentagePosition = waterLevelPosition - 40;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Main content
          Column(
            children: [
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

              Text(
                'Remaining: ${hydrationProvider.remainingIntake} ml',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSubtitle,
                ),
              ),

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

              const SizedBox(height: 80),
            ],
          ),

          // Percentage indicator
          Positioned(
            left: 26,
            top: percentagePosition.clamp(100.0, screenSize.height - 150.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Water animation that covers the entire screen
          Positioned.fill(
            child: WaterAnimation(
              progress: hydrationProvider.intakePercentage,
              waterColor: AppColors.waterFull,
              backgroundColor: AppColors.waterLow,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),

          // Main content
          Center(child: _widgetOptions.elementAt(_selectedIndex)),

          // Custom navigation bar with transparent background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

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
        Provider.of<HydrationProvider>(context, listen: false).loadData();
      }
    });
  }
}
