import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:watertracker/core/design_system/design_system.dart';
import 'package:watertracker/core/utils/performance_utils.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';
import 'package:watertracker/core/utils/widget_cache.dart';
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
                padding: ResponsiveHelper.getResponsivePadding(
                  context,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: ResponsiveHelper.getResponsiveHeight(context, 40),
                      width: ResponsiveHelper.getResponsiveWidth(context, 40),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: ResponsiveHelper.getResponsiveWidth(
                              context,
                              4,
                            ),
                            offset: Offset(
                              0,
                              ResponsiveHelper.getResponsiveHeight(context, 2),
                            ),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: CachedAvatarWidget(
                          avatarPath:
                              'assets/images/icons/navbar/setting page top right icon.svg',
                          width: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            30,
                          ),
                          height: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            30,
                          ),
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
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 130),
              ),

              Text(
                '${hydrationProvider.currentIntake} ml',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 58),
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 8),
              ),

              // Fixed remaining text visibility
              Text(
                'Remaining: ${hydrationProvider.remainingIntake} ml',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSubtitle,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Debug info (remove this later)
              Text(
                'Debug: Current: ${hydrationProvider.currentIntake}ml, Goal: ${hydrationProvider.dailyGoal}ml',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDisabled,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                ),
              ),

              Expanded(
                child: Center(
                  child: PerformanceUtils.optimizedRepaintBoundary(
                    debugLabel: 'HomeScreenAvatar',
                    child: CachedAvatarWidget(
                      avatarPath:
                          hydrationProvider.selectedAvatar == AvatarOption.male
                              ? 'assets/images/avatars/male.svg'
                              : 'assets/images/avatars/female.svg',
                      width: ResponsiveHelper.getResponsiveWidth(context, 390),
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        390,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(context, 80),
              ),
            ],
          ),

          // Updated percentage indicator
          Positioned(
            left: ResponsiveHelper.getResponsiveWidth(context, 26),
            top:
                screenSize.height *
                (1 - hydrationProvider.intakePercentage) *
                0.6,
            child: Text(
              '${(hydrationProvider.intakePercentage * 100).toInt()}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 32),
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
  int _currentPage =
      0; // 0: Home (leftmost), 1: Add Hydration (middle), 2: Statistics (rightmost)

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
            // Water animation that covers the entire screen with RepaintBoundary optimization
            Positioned.fill(
              child: PerformanceUtils.optimizedRepaintBoundary(
                debugLabel: 'HomeScreenWaterAnimation',
                child: WaterAnimation(
                  progress: hydrationProvider.intakePercentage,
                  waterColor: AppColors.waterFull,
                  backgroundColor: AppColors.waterLow,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),

            // Swipeable page view
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: const [
                // Home Page (leftmost - default)
                HomeScreenContent(),

                // Add Hydration Page (middle)
                AddHydrationScreen(),

                // Statistics Page (rightmost)
                StatisticsPage(),
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
