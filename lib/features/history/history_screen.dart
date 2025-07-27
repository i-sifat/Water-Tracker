import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/empty_state_widget.dart';
import 'package:watertracker/core/widgets/common/loading_widget.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/core/widgets/inputs/app_text_field.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum HistoryViewMode { weekly, calendar, list }

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
              _buildFilterAndSearch(),
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

  Widget _buildViewModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildViewModeButton(
              'Weekly',
              HistoryViewMode.weekly,
              Icons.bar_chart,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildViewModeButton(
              'Calendar',
              HistoryViewMode.calendar,
              Icons.calendar_today,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildViewModeButton(
              'List',
              HistoryViewMode.list,
              Icons.list,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(String title, HistoryViewMode mode, IconData icon) {
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.waterFull : AppColors.unselectedBorder,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.waterFull.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSubtitle,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSubtitle,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterAndSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Filter chips
          Row(
            children: [
              _buildFilterChip('All', FilterType.all),
              const SizedBox(width: 8),
              _buildFilterChip('Water', FilterType.water),
              const SizedBox(width: 8),
              _buildFilterChip('Other', FilterType.other),
              const Spacer(),
              if (_viewMode == HistoryViewMode.list)
                IconButton(
                  icon: Icon(
                    _searchQuery.isEmpty ? Icons.search : Icons.clear,
                    color: AppColors.textSubtitle,
                  ),
                  onPressed: () {
                    if (_searchQuery.isEmpty) {
                      // Show search field
                      setState(() {});
                    } else {
                      // Clear search
                      _searchController.clear();
                    }
                  },
                ),
            ],
          ),
          // Search field (only for list view)
          if (_viewMode == HistoryViewMode.list && _searchQuery.isNotEmpty)
            const SizedBox(height: 8),
          if (_viewMode == HistoryViewMode.list && _searchQuery.isNotEmpty)
            AppTextField(
              controller: _searchController,
              hintText: 'Search entries...',
              prefixIcon: const Icon(Icons.search),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String title, FilterType type) {
    final isSelected = _filterType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.lightBlue : AppColors.unselectedBorder,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSubtitle,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HydrationProvider provider) {
    switch (_viewMode) {
      case HistoryViewMode.weekly:
        return _buildWeeklyView(provider);
      case HistoryViewMode.calendar:
        return _buildCalendarView(provider);
      case HistoryViewMode.list:
        return _buildListView(provider);
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'History',
            style: TextStyle(
              color: AppColors.textHeadline,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          Row(
            children: [
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
                  icon: const Icon(Icons.analytics_outlined, color: AppColors.darkBlue),
                  onPressed: () {
                    Navigator.pushNamed(context, '/analytics/weekly');
                  },
                ),
              ),
              const SizedBox(width: 8),
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
                  icon: const Icon(Icons.add, color: AppColors.darkBlue),
                  onPressed: () {
                    Navigator.pushNamed(context, '/hydration/add');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(HydrationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildWeekSelector(),
          const SizedBox(height: 20),
          _buildWeeklyChart(provider),
          const SizedBox(height: 20),
          _buildWeeklyStats(provider),
          const SizedBox(height: 20),
          _buildWeeklyComparison(provider),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textSubtitle),
          onPressed: () {
            setState(() {
              _selectedWeekIndex++;
            });
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              _getWeekRangeText(),
              style: const TextStyle(
                color: AppColors.textHeadline,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: _selectedWeekIndex > 0 ? AppColors.textSubtitle : AppColors.unselectedBorder,
          ),
          onPressed: _selectedWeekIndex > 0 ? () {
            setState(() {
              _selectedWeekIndex--;
            });
          } : null,
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(HydrationProvider provider) {
    final weekData = provider.getWeeklyData(_currentWeekStart);
    final filteredData = _filterWeeklyData(weekData);
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Intake',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(filteredData),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.darkBlue,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date = _currentWeekStart.add(Duration(days: groupIndex));
                        final intake = filteredData[date] ?? 0;
                        return BarTooltipItem(
                          '${_getDayName(date)}\n${(intake / 1000).toStringAsFixed(1)}L',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = _currentWeekStart.add(Duration(days: value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getDayAbbreviation(date),
                              style: const TextStyle(
                                color: AppColors.textSubtitle,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000).toStringAsFixed(1)}L',
                            style: const TextStyle(
                              color: AppColors.textSubtitle,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildWeeklyBarGroups(filteredData, provider.dailyGoal),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 500,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: AppColors.unselectedBorder,
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStats(HydrationProvider provider) {
    final weekData = provider.getWeeklyData(_currentWeekStart);
    final filteredData = _filterWeeklyData(weekData);
    
    final totalIntake = filteredData.values.fold(0, (sum, value) => sum + value);
    final averageIntake = totalIntake / 7.0;
    final goalAchievedDays = filteredData.values.where((intake) => intake >= provider.dailyGoal).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Average',
            '${(averageIntake / 1000).toStringAsFixed(1)}L',
            AppColors.lightBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total',
            '${(totalIntake / 1000).toStringAsFixed(1)}L',
            AppColors.chartBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Goals',
            '$goalAchievedDays/7',
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
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyComparison(HydrationProvider provider) {
    final thisWeekData = provider.getWeeklyData(_currentWeekStart);
    final lastWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    final lastWeekData = provider.getWeeklyData(lastWeekStart);
    
    final thisWeekTotal = thisWeekData.values.fold(0, (sum, value) => sum + value);
    final lastWeekTotal = lastWeekData.values.fold(0, (sum, value) => sum + value);
    
    final percentageChange = lastWeekTotal > 0 
        ? ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100
        : 0.0;
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  percentageChange >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: percentageChange >= 0 ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentageChange.abs().toStringAsFixed(1)}% ${percentageChange >= 0 ? 'increase' : 'decrease'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: percentageChange >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const Text(
                  ' from last week',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSubtitle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(HydrationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          AppCard(
            child: TableCalendar<HydrationData>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: AppColors.textSubtitle),
                holidayTextStyle: const TextStyle(color: AppColors.textSubtitle),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.waterFull,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.chartBlue,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeadline,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.textSubtitle,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSubtitle,
                ),
              ),
              eventLoader: (day) {
                final entries = provider.getEntriesForDate(day);
                return _filterEntries(entries);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  
                  final entries = events.cast<HydrationData>();
                  final totalIntake = entries.totalWaterIntake;
                  final goalAchieved = totalIntake >= provider.dailyGoal;
                  
                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: goalAchieved ? AppColors.waterFull : AppColors.lightBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
                defaultBuilder: (context, date, _) {
                  final entries = provider.getEntriesForDate(date);
                  final filteredEntries = _filterEntries(entries);
                  final totalIntake = filteredEntries.totalWaterIntake;
                  
                  Color? backgroundColor;
                  if (totalIntake > 0) {
                    final percentage = (totalIntake / provider.dailyGoal).clamp(0.0, 1.0);
                    backgroundColor = AppColors.waterFull.withValues(alpha: 0.1 + (percentage * 0.3));
                  }
                  
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: AppColors.textHeadline),
                      ),
                    ),
                  );
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDate = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDate = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildSelectedDayDetails(provider),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails(HydrationProvider provider) {
    final entries = provider.getEntriesForDate(_selectedDate);
    final filteredEntries = _filterEntries(entries);
    final totalIntake = filteredEntries.totalWaterIntake;
    final goalAchieved = totalIntake >= provider.dailyGoal;
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _formatSelectedDate(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeadline,
                  ),
                ),
                const Spacer(),
                Icon(
                  goalAchieved ? Icons.check_circle : Icons.circle_outlined,
                  color: goalAchieved ? AppColors.waterFull : AppColors.textSubtitle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Total: ${(totalIntake / 1000).toStringAsFixed(1)}L',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                  ),
                ),
                const Spacer(),
                Text(
                  'Goal: ${(provider.dailyGoal / 1000).toStringAsFixed(1)}L',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSubtitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (totalIntake / provider.dailyGoal).clamp(0.0, 1.0),
              backgroundColor: AppColors.waterLow,
              valueColor: AlwaysStoppedAnimation<Color>(
                goalAchieved ? AppColors.waterFull : AppColors.lightBlue,
              ),
            ),
            if (filteredEntries.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Entries',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeadline,
                ),
              ),
              const SizedBox(height: 8),
              ...filteredEntries.take(3).map(_buildEntryTile),
              if (filteredEntries.length > 3)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _viewMode = HistoryViewMode.list;
                    });
                  },
                  child: Text('View all ${filteredEntries.length} entries'),
                ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'No entries for this day',
                  style: TextStyle(
                    color: AppColors.textSubtitle,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(HydrationProvider provider) {
    final allEntries = provider.hydrationHistory;
    final filteredEntries = _filterEntries(allEntries)
        .where((entry) => _searchQuery.isEmpty || 
            entry.type.displayName.toLowerCase().contains(_searchQuery) ||
            (entry.notes?.toLowerCase().contains(_searchQuery) ?? false))
        .toList();
    
    if (filteredEntries.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Entries Found',
        subtitle: 'Try adjusting your filters or search terms.',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = filteredEntries[index];
        return _buildEntryCard(entry, provider);
      },
    );
  }

  Widget _buildEntryCard(HydrationData entry, HydrationProvider provider) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.lightBlue.withValues(alpha: 0.2),
          child: Icon(
            _getDrinkTypeIcon(entry.type),
            color: AppColors.lightBlue,
            size: 20,
          ),
        ),
        title: Text(
          '${entry.amount}ml ${entry.type.displayName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textHeadline,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatEntryTime(entry.timestamp),
              style: const TextStyle(
                color: AppColors.textSubtitle,
                fontSize: 12,
              ),
            ),
            if (entry.notes != null && entry.notes!.isNotEmpty)
              Text(
                entry.notes!,
                style: const TextStyle(
                  color: AppColors.textSubtitle,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(entry.waterContent / 1000).toStringAsFixed(1)}L',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.waterFull,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleEntryAction(value, entry, provider),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTile(HydrationData entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            _getDrinkTypeIcon(entry.type),
            color: AppColors.lightBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(entry.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSubtitle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.amount}ml',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textHeadline,
            ),
          ),
          const Spacer(),
          Text(
            '${(entry.waterContent / 1000).toStringAsFixed(1)}L',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.waterFull,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<HydrationData> _filterEntries(List<HydrationData> entries) {
    switch (_filterType) {
      case FilterType.all:
        return entries;
      case FilterType.water:
        return entries.where((entry) => entry.type == DrinkType.water).toList();
      case FilterType.other:
        return entries.where((entry) => entry.type != DrinkType.water).toList();
    }
  }

  Map<DateTime, int> _filterWeeklyData(Map<DateTime, int> weekData) {
    // For now, return all data since filtering by drink type in weekly view
    // would require more complex data aggregation
    return weekData;
  }

  List<BarChartGroupData> _buildWeeklyBarGroups(Map<DateTime, int> weekData, int dailyGoal) {
    return weekData.entries.map((entry) {
      final index = weekData.keys.toList().indexOf(entry.key);
      final intake = entry.value;
      final achieved = intake >= dailyGoal;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: intake.toDouble(),
            color: achieved ? AppColors.waterFull : AppColors.lightBlue,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY(Map<DateTime, int> data) {
    if (data.isEmpty) return 3000;
    final maxIntake = data.values.reduce((a, b) => a > b ? a : b);
    return (maxIntake * 1.2).ceilToDouble();
  }

  String _getWeekRangeText() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    return '${_formatDateShort(_currentWeekStart)} - ${_formatDateShort(weekEnd)}';
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatSelectedDate() {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return '${days[_selectedDate.weekday - 1]}, ${months[_selectedDate.month - 1]} ${_selectedDate.day}';
  }

  String _formatEntryTime(DateTime timestamp) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final time = _formatTime(timestamp);
    return '${months[timestamp.month - 1]} ${timestamp.day} at $time';
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _getDayAbbreviation(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
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
        return Icons.local_drink;
    }
  }

  void _handleEntryAction(String action, HydrationData entry, HydrationProvider provider) {
    switch (action) {
      case 'edit':
        _showEditEntryDialog(entry, provider);
      case 'delete':
        _showDeleteConfirmation(entry, provider);
    }
  }

  void _showEditEntryDialog(HydrationData entry, HydrationProvider provider) {
    // This would open an edit dialog - for now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon'),
        backgroundColor: AppColors.lightBlue,
      ),
    );
  }

  void _showDeleteConfirmation(HydrationData entry, HydrationProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete this ${entry.amount}ml ${entry.type.displayName} entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteHydrationEntry(entry.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entry deleted'),
                  backgroundColor: AppColors.waterFull,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
