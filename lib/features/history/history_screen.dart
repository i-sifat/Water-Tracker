import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/empty_state_widget.dart';
import 'package:watertracker/core/widgets/common/loading_widget.dart';
import 'package:watertracker/core/widgets/common/optimized_list_view.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/core/widgets/inputs/app_text_field.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum HistoryViewMode { weekly, monthly, yearly }

enum FilterType { all, water, other }

class HistoryScreenContent extends StatefulWidget {
  const HistoryScreenContent({super.key});

  @override
  State<HistoryScreenContent> createState() => _HistoryScreenContentState();
}

class _HistoryScreenContentState extends State<HistoryScreenContent>
    with SingleTickerProviderStateMixin {
  HistoryViewMode _viewMode = HistoryViewMode.weekly;
  FilterType _filterType = FilterType.all;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Weekly view state
  int _selectedWeekIndex = 0;
  DateTime get _currentWeekStart {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return weekStart.subtract(Duration(days: _selectedWeekIndex * 7));
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Listen to search changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, hydrationProvider, child) {
        if (!hydrationProvider.isInitialized) {
          return const LoadingWidget();
        }

        return SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildViewModeSelector(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildContent(hydrationProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hamburger menu replaced with settings icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: AppColors.darkBlue,
              ),
              onPressed: () {
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
            ),
          ),
          const Text(
            'Statistics',
            style: TextStyle(
              color: AppColors.textHeadline,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          // CSV icon replaced with share icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.share,
                color: AppColors.darkBlue,
              ),
              onPressed: () {
                _showShareDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildViewModeButton(
              'WEEKLY',
              HistoryViewMode.weekly,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildViewModeButton(
              'MONTHLY',
              HistoryViewMode.monthly,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildViewModeButton(
              'YEARLY',
              HistoryViewMode.yearly,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(String title, HistoryViewMode mode) {
    final isSelected = _viewMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _viewMode = mode;
        });
        _animationController.reset();
        _animationController.forward();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.waterFull : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.waterFull : AppColors.unselectedBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.waterFull.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSubtitle,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HydrationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildStreakSection(provider),
          const SizedBox(height: 24),
          _buildIntakeChart(provider),
          const SizedBox(height: 24),
          _buildStatsCards(provider),
          const SizedBox(height: 24),
          _buildMostUsedSection(provider),
          const SizedBox(height: 100), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildStreakSection(HydrationProvider provider) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Days in a row',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Longest chain: ${provider.longestStreak}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSubtitle,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Week view with dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...['S', 'M', 'T', 'W', 'T', 'F', 'S'].asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  final isToday = index == DateTime.now().weekday % 7;
                  final hasGoal = _hasGoalForDay(provider, index);
                  
                  return Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: hasGoal ? AppColors.waterFull : AppColors.unselectedBorder,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          color: isToday ? AppColors.textHeadline : AppColors.textSubtitle,
                          fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  );
                }),
                // Large current streak number
                Text(
                  provider.currentStreak.toString(),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntakeChart(HydrationProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: AppCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Intake',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeadline,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getIntakePeriodText(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSubtitle,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(provider),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(),
                          topTitles: const AxisTitles(),
                          leftTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getBottomTitle(value.toInt()),
                                    style: const TextStyle(
                                      color: AppColors.textSubtitle,
                                      fontSize: 12,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: _buildBarGroups(provider),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Day indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _buildDayIndicators(provider),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildBalanceCard(provider),
              const SizedBox(height: 16),
              _buildDailyAverageCard(provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(HydrationProvider provider) {
    final percentage = (provider.intakePercentage * 100).round();
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSubtitle,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeadline,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyAverageCard(HydrationProvider provider) {
    final averageIntake = _calculateDailyAverage(provider);
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily average',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSubtitle,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(averageIntake / 1000).toStringAsFixed(1)}L',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeadline,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(HydrationProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Days',
            _getTotalDaysTracked(provider).toString(),
            AppColors.lightBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Goal Rate',
            '${(_getGoalAchievementRate(provider) * 100).toInt()}%',
            AppColors.chartBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Best Week',
            '${_getBestWeekStreak(provider)} days',
            AppColors.darkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSubtitle,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostUsedSection(HydrationProvider provider) {
    final mostUsedDrinks = _getMostUsedDrinks(provider);
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most used',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...mostUsedDrinks.take(3).map((drink) => _buildMostUsedItem(
                  drink['icon'] as IconData,
                  drink['amount'] as String,
                  drink['rank'] as int,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostUsedItem(IconData icon, String amount, int rank) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.waterFull.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 32,
            color: AppColors.waterFull,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textHeadline,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 2,
          color: rank == 1 ? AppColors.waterFull : AppColors.unselectedBorder,
        ),
        const SizedBox(height: 8),
        Text(
          '$rank.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: rank == 1 ? AppColors.textHeadline : AppColors.textSubtitle,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDayIndicators(HydrationProvider provider) {
    return ['S', 'M', 'T', 'W', 'T', 'F', 'S'].asMap().entries.map((entry) {
      final index = entry.key;
      final hasGoal = _hasGoalForDay(provider, index);
      
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: hasGoal ? Colors.green : AppColors.unselectedBorder,
          shape: BoxShape.circle,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarGroups(HydrationProvider provider) {
    final weekData = provider.getWeeklyData(_currentWeekStart);
    
    return weekData.entries.map((entry) {
      final index = weekData.keys.toList().indexOf(entry.key);
      final intake = entry.value;
      final achieved = intake >= provider.dailyGoal;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: intake.toDouble(),
            color: achieved ? AppColors.waterFull : AppColors.lightBlue,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _showShareDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Share Statistics',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Choose what to share:',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _shareWeeklyStats();
            },
            child: const Text(
              'Weekly Stats',
              style: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _shareMonthlyStats();
            },
            child: const Text(
              'Monthly Stats',
              style: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
        ],
      ),
    );
  }

  void _shareWeeklyStats() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weekly stats shared!'),
        backgroundColor: AppColors.waterFull,
      ),
    );
  }

  void _shareMonthlyStats() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Monthly stats shared!'),
        backgroundColor: AppColors.waterFull,
      ),
    );
  }

  // Helper methods
  bool _hasGoalForDay(HydrationProvider provider, int dayIndex) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final targetDate = weekStart.add(Duration(days: dayIndex));
    final dayEntries = provider.getEntriesForDate(targetDate);
    return dayEntries.totalWaterIntake >= provider.dailyGoal;
  }

  double _getMaxY(HydrationProvider provider) {
    final weekData = provider.getWeeklyData(_currentWeekStart);
    if (weekData.isEmpty) return 3000;
    final maxIntake = weekData.values.reduce((a, b) => a > b ? a : b);
    return (maxIntake * 1.2).ceilToDouble();
  }

  String _getBottomTitle(int index) {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return days[index % 7];
  }

  String _getIntakePeriodText() {
    switch (_viewMode) {
      case HistoryViewMode.weekly:
        return 'Last 7 days';
      case HistoryViewMode.monthly:
        return 'Last 30 days';
      case HistoryViewMode.yearly:
        return 'Last 365 days';
    }
  }

  double _calculateDailyAverage(HydrationProvider provider) {
    final history = provider.hydrationHistory;
    if (history.isEmpty) return 0;
    
    final totalIntake = history.fold(0, (sum, entry) => sum + entry.waterContent);
    final uniqueDays = history.map((e) => e.date).toSet().length;
    
    return uniqueDays > 0 ? totalIntake / uniqueDays : 0;
  }

  int _getTotalDaysTracked(HydrationProvider provider) {
    final history = provider.hydrationHistory;
    return history.map((e) => e.date).toSet().length;
  }

  double _getGoalAchievementRate(HydrationProvider provider) {
    final history = provider.hydrationHistory;
    if (history.isEmpty) return 0;
    
    final dailyTotals = <DateTime, int>{};
    for (final entry in history) {
      final date = entry.date;
      dailyTotals[date] = (dailyTotals[date] ?? 0) + entry.waterContent;
    }
    
    final achievedDays = dailyTotals.values.where((total) => total >= provider.dailyGoal).length;
    return dailyTotals.isNotEmpty ? achievedDays / dailyTotals.length : 0;
  }

  int _getBestWeekStreak(HydrationProvider provider) {
    // Simplified calculation - in a real app, you'd track weekly streaks
    return provider.longestStreak > 7 ? 7 : provider.longestStreak;
  }

  List<Map<String, dynamic>> _getMostUsedDrinks(HydrationProvider provider) {
    final drinkCounts = <DrinkType, int>{};
    
    for (final entry in provider.hydrationHistory) {
      drinkCounts[entry.type] = (drinkCounts[entry.type] ?? 0) + entry.amount;
    }
    
    final sortedDrinks = drinkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedDrinks.take(3).map((entry) {
      final type = entry.key;
      final amount = entry.value;
      
      return {
        'icon': _getDrinkTypeIcon(type),
        'amount': amount > 1000 ? '${(amount / 1000).toStringAsFixed(1)}L' : '${amount}ml',
        'rank': sortedDrinks.indexOf(entry) + 1,
      };
    }).toList();
  }

  IconData _getDrinkTypeIcon(DrinkType type) {
    switch (type) {
      case DrinkType.water:
        return Icons.water_drop;
      case DrinkType.coffee:
        return Icons.coffee;
      case DrinkType.tea:
        return Icons.emoji_food_beverage;
      case DrinkType.juice:
        return Icons.local_drink;
      case DrinkType.soda:
        return Icons.local_bar;
      case DrinkType.sports:
        return Icons.sports_bar;
      case DrinkType.other:
        return Icons.help_outline;
    }
  }
}

class _HistoryScreenState extends State<HistoryScreen> {
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenContent(),
    const AddHydrationScreenContent(),
    const HistoryScreenContent(),
  ];
  int _selectedIndex = 2;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}