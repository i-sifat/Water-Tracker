import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/premium_features.dart' as premium_constants;
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/empty_state_widget.dart';
import 'package:watertracker/core/widgets/common/loading_widget.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/analytics/models/analytics_data.dart';
import 'package:watertracker/features/analytics/providers/analytics_provider.dart';

class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadCurrentWeekAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Weekly Progress',
          style: TextStyle(
            color: AppColors.textHeadline,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.appBar,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeadline),
      ),
      body: PremiumGate(
        feature: premium_constants.PremiumFeature.advancedAnalytics,
        lockedChild: _buildPremiumPrompt(),
        child: Consumer<AnalyticsProvider>(
          builder: (context, analytics, child) {
            if (analytics.isLoading) {
              return const LoadingWidget();
            }

            if (analytics.lastError != null) {
              return _buildErrorState(analytics);
            }

            final weeklyData = analytics.currentWeekAnalytics;
            if (weeklyData == null) {
              return const EmptyStateWidget(
                title: 'No Data Available',
                message: 'Start tracking your water intake to see weekly progress.',
              );
            }

            return _buildWeeklyAnalytics(weeklyData);
          },
        ),
      ),
    );
  }

  Widget _buildWeeklyAnalytics(WeeklyAnalytics data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekHeader(data),
          const SizedBox(height: 24),
          _buildWeeklyChart(data),
          const SizedBox(height: 24),
          _buildWeeklyStats(data),
          const SizedBox(height: 24),
          _buildDailyBreakdown(data),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(WeeklyAnalytics data) {
    final startDate = data.weekStart;
    final endDate = data.weekEnd;
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Week of ${_formatDate(startDate)} - ${_formatDate(endDate)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(data.goalAchievementRate * 100).toInt()}% goal achievement',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(WeeklyAnalytics data) {
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
                  maxY: _getMaxY(data),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.darkBlue,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date = data.weekStart.add(Duration(days: groupIndex));
                        final intake = data.dailyIntakes[date] ?? 0;
                        return BarTooltipItem(
                          '${_getDayName(date)}\n${intake}ml',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = data.weekStart.add(Duration(days: value.toInt()));
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
                  barGroups: _buildBarGroups(data),
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

  Widget _buildWeeklyStats(WeeklyAnalytics data) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Average',
            '${(data.averageIntake / 1000).toStringAsFixed(1)}L',
            AppColors.lightBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total',
            '${(data.totalIntake / 1000).toStringAsFixed(1)}L',
            AppColors.chartBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Streak',
            '${data.streak} days',
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

  Widget _buildDailyBreakdown(WeeklyAnalytics data) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            ...data.dailyIntakes.entries.map((entry) {
              final date = entry.key;
              final intake = entry.value;
              final goal = data.dailyGoals[date] ?? 2000;
              final percentage = goal > 0 ? (intake / goal).clamp(0.0, 1.0) : 0.0;
              final achieved = intake >= goal;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        _getDayName(date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSubtitle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.waterLow,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: achieved ? AppColors.waterFull : AppColors.lightBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${(intake / 1000).toStringAsFixed(1)}L',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: achieved ? AppColors.waterFull : AppColors.textSubtitle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      achieved ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: achieved ? AppColors.waterFull : AppColors.textSubtitle,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AnalyticsProvider analytics) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSubtitle,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Analytics',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              analytics.lastError?.message ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSubtitle,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: () {
                analytics.clearError();
                analytics.loadCurrentWeekAnalytics();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.lightBlue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Advanced Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get detailed insights into your hydration patterns with weekly progress charts and statistics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSubtitle,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Unlock Premium',
              onPressed: () {
                Navigator.pushNamed(context, '/premium/donation-info');
              },
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(WeeklyAnalytics data) {
    return data.dailyIntakes.entries.map((entry) {
      final index = data.dailyIntakes.keys.toList().indexOf(entry.key);
      final intake = entry.value;
      final goal = data.dailyGoals[entry.key] ?? 2000;
      final achieved = intake >= goal;

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

  double _getMaxY(WeeklyAnalytics data) {
    final maxIntake = data.dailyIntakes.values.reduce((a, b) => a > b ? a : b);
    final maxGoal = data.dailyGoals.values.reduce((a, b) => a > b ? a : b);
    final max = maxIntake > maxGoal ? maxIntake : maxGoal;
    return (max * 1.2).ceilToDouble();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _getDayAbbreviation(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}