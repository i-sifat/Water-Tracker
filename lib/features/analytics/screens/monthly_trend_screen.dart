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

class MonthlyTrendScreen extends StatefulWidget {
  const MonthlyTrendScreen({super.key});

  @override
  State<MonthlyTrendScreen> createState() => _MonthlyTrendScreenState();
}

class _MonthlyTrendScreenState extends State<MonthlyTrendScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadCurrentMonthAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Monthly Trends',
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

            final monthlyData = analytics.currentMonthAnalytics;
            if (monthlyData == null) {
              return const EmptyStateWidget(
                title: 'No Data Available',
                message: 'Start tracking your water intake to see monthly trends.',
              );
            }

            return _buildMonthlyAnalytics(monthlyData);
          },
        ),
      ),
    );
  }

  Widget _buildMonthlyAnalytics(MonthlyAnalytics data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthHeader(data),
          const SizedBox(height: 24),
          _buildMonthlyChart(data),
          const SizedBox(height: 24),
          _buildMonthlyStats(data),
          const SizedBox(height: 24),
          _buildWeeklyAverages(data),
          const SizedBox(height: 24),
          _buildGoalAchievementHeatmap(data),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(MonthlyAnalytics data) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getMonthName(data.month, data.year),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(data.goalAchievementRate * 100).toInt()}% goal achievement rate',
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

  Widget _buildMonthlyChart(MonthlyAnalytics data) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Intake Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
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
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              value.toInt().toString(),
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
                  minX: 1,
                  maxX: DateTime(data.year, data.month + 1, 0).day.toDouble(),
                  minY: 0,
                  maxY: _getMaxY(data),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildLineSpots(data),
                      isCurved: true,
                      color: AppColors.waterFull,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: AppColors.waterFull,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.waterFullTransparent,
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: AppColors.darkBlue,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final day = spot.x.toInt();
                          final intake = spot.y.toInt();
                          return LineTooltipItem(
                            'Day $day\n${(intake / 1000).toStringAsFixed(1)}L',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(MonthlyAnalytics data) {
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
            'Best Streak',
            '${data.bestStreak} days',
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

  Widget _buildWeeklyAverages(MonthlyAnalytics data) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Averages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxWeeklyAverage(data),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.darkBlue,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final week = group.x + 1;
                        final average = rod.toY;
                        return BarTooltipItem(
                          'Week $week\n${(average / 1000).toStringAsFixed(1)}L',
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'W${(value + 1).toInt()}',
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
                  barGroups: _buildWeeklyBarGroups(data),
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

  Widget _buildGoalAchievementHeatmap(MonthlyAnalytics data) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Achievement Heatmap',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeatmapGrid(data),
            const SizedBox(height: 12),
            _buildHeatmapLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(MonthlyAnalytics data) {
    final daysInMonth = DateTime(data.year, data.month + 1, 0).day;
    const daysPerRow = 7;
    final rows = (daysInMonth / daysPerRow).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(daysPerRow, (colIndex) {
              final day = rowIndex * daysPerRow + colIndex + 1;
              if (day > daysInMonth) {
                return const SizedBox(width: 32, height: 32);
              }

              final date = DateTime(data.year, data.month, day);
              final intake = data.dailyIntakes[date] ?? 0;
              final goalAchieved = intake >= 2000; // Assuming 2L goal

              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: goalAchieved ? AppColors.waterFull : AppColors.waterLow,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.unselectedBorder,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: goalAchieved ? Colors.white : AppColors.textSubtitle,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildHeatmapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Goal not achieved', AppColors.waterLow),
        const SizedBox(width: 16),
        _buildLegendItem('Goal achieved', AppColors.waterFull),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSubtitle,
          ),
        ),
      ],
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
            const Text(
              'Failed to Load Analytics',
              style: TextStyle(
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
                analytics.loadCurrentMonthAnalytics();
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
              Icons.trending_up,
              size: 64,
              color: AppColors.lightBlue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Monthly Trends',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your monthly progress with detailed trend analysis and goal achievement heatmaps.',
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

  List<FlSpot> _buildLineSpots(MonthlyAnalytics data) {
    return data.dailyIntakes.entries.map((entry) {
      return FlSpot(entry.key.day.toDouble(), entry.value.toDouble());
    }).toList();
  }

  List<BarChartGroupData> _buildWeeklyBarGroups(MonthlyAnalytics data) {
    return data.weeklyAverages.entries.map((entry) {
      final weekIndex = entry.key - 1;
      final average = entry.value;

      return BarChartGroupData(
        x: weekIndex,
        barRods: [
          BarChartRodData(
            toY: average,
            color: AppColors.chartBlue,
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

  double _getMaxY(MonthlyAnalytics data) {
    if (data.dailyIntakes.isEmpty) return 3000;
    final maxIntake = data.dailyIntakes.values.reduce((a, b) => a > b ? a : b);
    return (maxIntake * 1.2).ceilToDouble();
  }

  double _getMaxWeeklyAverage(MonthlyAnalytics data) {
    if (data.weeklyAverages.isEmpty) return 3000;
    final maxAverage = data.weeklyAverages.values.reduce((a, b) => a > b ? a : b);
    return (maxAverage * 1.2).ceilToDouble();
  }

  String _getMonthName(int month, int year) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }
}