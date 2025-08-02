import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/features/hydration/widgets/swipeable_page_view.dart';

/// Example implementation of SwipeablePageView showing three hydration pages
/// This demonstrates the vertical swipe navigation between history, main, and goal pages
class SwipeablePageViewExample extends StatefulWidget {
  const SwipeablePageViewExample({super.key});

  @override
  State<SwipeablePageViewExample> createState() =>
      _SwipeablePageViewExampleState();
}

class _SwipeablePageViewExampleState extends State<SwipeablePageViewExample> {
  late PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Swipeable Hydration Interface'),
        backgroundColor: AppColors.waterFull,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SwipeablePageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        pages: [
          _buildHistoryPage(),
          _buildMainPage(),
          _buildGoalBreakdownPage(),
        ],
      ),
    );
  }

  /// Build history/statistics page (swipe up destination)
  Widget _buildHistoryPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4CAF50), // Green gradient for history
            Color(0xFF2E7D32),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Text(
                'Statistics',
                style: AppTypography.headline.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Swipe instruction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swipe_down, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Swipe down to return to main page',
                        style: AppTypography.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Mock statistics content
              Expanded(
                child: Column(
                  children: [
                    _buildStatCard(
                      'Days in a row',
                      '7',
                      Icons.local_fire_department,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Weekly average',
                      '2.1 L',
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Best streak',
                      '14 days',
                      Icons.emoji_events,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build main hydration page (center page)
  Widget _buildMainPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6B73FF), // Main page gradient
            Color(0xFF9546C4),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Text(
                'Today',
                style: AppTypography.headline.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Swipe instructions
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swipe_up,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Statistics',
                              style: AppTypography.subtitle.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swipe_down,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Goal Setup',
                              style: AppTypography.subtitle.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Mock circular progress
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '1.75 L',
                        style: AppTypography.headline.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'drank so far',
                        style: AppTypography.subtitle.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Mock quick add buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAddButton('250ml', Colors.blue.shade300),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAddButton(
                      '500ml',
                      Colors.purple.shade300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAddButton('400ml', Colors.green.shade300),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAddButton(
                      '100ml',
                      Colors.yellow.shade300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build goal breakdown page (swipe down destination)
  Widget _buildGoalBreakdownPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF9800), // Orange gradient for goal breakdown
            Color(0xFFE65100),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Text(
                'Goal Breakdown',
                style: AppTypography.headline.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Swipe instruction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swipe_up, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Swipe up to return to main page',
                        style: AppTypography.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Mock goal breakdown content
              Expanded(
                child: Column(
                  children: [
                    _buildGoalFactorCard(
                      'Base requirement',
                      '2.0 L',
                      'Age, weight, gender',
                    ),
                    const SizedBox(height: 16),
                    _buildGoalFactorCard(
                      'Activity level',
                      '+0.5 L',
                      'Moderate exercise',
                    ),
                    const SizedBox(height: 16),
                    _buildGoalFactorCard('Climate', '+0.5 L', 'Hot weather'),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Daily Goal',
                            style: AppTypography.headline.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '3.0 L',
                            style: AppTypography.headline.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build statistics card
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subtitle.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.headline.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build goal factor card
  Widget _buildGoalFactorCard(String title, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.subtitle.copyWith(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick add button
  Widget _buildQuickAddButton(String text, Color color) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTypography.subtitle.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
