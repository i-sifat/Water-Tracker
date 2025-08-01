import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/animations/water_animation.dart';
import 'package:watertracker/core/widgets/common/exit_confirmation_modal.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';

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

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Main content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(150),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/icons/navbar/setting page top right icon.svg',
                          width: 30,
                          height: 30,
                          colorFilter: const ColorFilter.mode(
                            AppColors.darkBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(SettingsScreen.routeName);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 130),

              Text(
                '${hydrationProvider.currentIntake} ml',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 58,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),

              // Fixed remaining text visibility
              Text(
                'Remaining: ${hydrationProvider.remainingIntake} ml',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSubtitle,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    hydrationProvider.selectedAvatar == AvatarOption.male
                        ? 'assets/images/avatars/male.svg'
                        : 'assets/images/avatars/female.svg',
                    width: 390,
                    height: 390,
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),

          // Updated percentage indicator
          Positioned(
            left: 26,
            top:
                screenSize.height *
                (1 - hydrationProvider.intakePercentage) *
                0.6,
            child: Text(
              '${(hydrationProvider.intakePercentage * 100).toInt()}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0; // 0: Home (leftmost), 1: Add Hydration (middle), 2: Statistics (rightmost)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
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

            // Swipeable page view
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                // Home Page (leftmost - default)
                const HomeScreenContent(),
                
                // Add Hydration Page (middle)
                const AddHydrationScreen(),
                
                // Statistics Page (rightmost)
                const StatisticsPage(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ExitConfirmationModal(
          title: 'Exit App?',
          onConfirm: SystemNavigator.pop,
          onCancel: () {
            // Stay in the app
          },
        );
      },
    );
  }
}
