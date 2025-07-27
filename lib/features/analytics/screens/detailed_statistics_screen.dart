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

class DetailedStatisticsScreen extends StatefulWidget {
  const DetailedStatisticsScreen({super.key});

  @override
  State<DetailedStatisticsScreen> createState() => _DetailedStatisticsScreenState();
}

class _DetailedStatisticsScreenState extends State<DetailedStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analytics = context.read<AnalyticsProvider>();
      analytics.loadDetailedStatistics();
      analytics.loadStreakData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detailed Statistics',
          style: TextStyle(
            color: AppColors.textHeadline,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.appBar,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeadline),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showExportDialog(),
          ),
        ],
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

            final stats = analytics.detailedStats;
            final streakData = analytics.streakData;
            
            if (stats == null) {
              return const EmptyStateWidget(
                title: 'No Data Available',
                message: 'Start tracking your water intake to see detailed statistics.',
              );
            }

            return _buildDetailedStatistics(stats, streakData);
          },
        ),
      ),
    );
  }

  Widget _buildDetailedStatistics(DetailedStatistics stats, StreakData? streakData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewStats(stats),
          const SizedBox(height: 24),
          _buildStreakSection(streakData ?? _createEmptyStreakData()),
          const SizedBox(height: 24),
          _buildTrendAnalysis(stats),
          const SizedBox(height: 24),
          _buildDrinkTypeBreakdown(stats),
          const SizedBox(height: 24),
          _buildHourlyPattern(stats),
          const SizedBox(height: 24),
          _buildGoalAchievementSection(stats),
        ],
      ),
    );
  }

  Widget _buildOverviewStats(DetailedStatistics stats) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Days Tracked',
                    stats.totalDaysTracked.toString(),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Total Water',
                    '${(stats.totalWaterConsumed / 1000).toStringAsFixed(1)}L',
                    Icons.water_drop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Daily Average',
                    '${(stats.averageDailyIntake / 1000).toStringAsFixed(1)}L',
                    Icons.analytics,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Goal Rate',
                    '${(stats.goalAchievementRate * 100).toInt()}%',
                    Icons.flag,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: AppColors.lightBlue,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeadline,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSubtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSection(StreakData streakData) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Streak Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStreakCard(
                    'Current Streak',
                    streakData.currentStreak,
                    AppColors.waterFull,
                    Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStreakCard(
                    'Longest Streak',
                    streakData.longestStreak,
                    AppColors.darkBlue,
                    Icons.emoji_events,
                  ),
                ),
              ],
            ),
            if (streakData.lastGoalAchievedDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Last goal achieved: ${_formatDate(streakData.lastGoalAchievedDate!)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSubtitle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(String title, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(DetailedStatistics stats) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTrendCard(
                    'Weekly Trend',
                    stats.weeklyTrend,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTrendCard(
                    'Monthly Trend',
                    stats.monthlyTrend,
                    Icons.show_chart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(String title, double trend, IconData icon) {
    final isPositive = trend >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final trendIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                trendIcon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '${trend.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkTypeBreakdown(DetailedStatistics stats) {
    if (stats.drinkTypeBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drink Type Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(stats.drinkTypeBreakdown),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Handle touch events if needed
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDrinkTypeLegend(stats.drinkTypeBreakdown),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkTypeLegend(Map<String, int> breakdown) {
    final colors = [
      AppColors.waterFull,
      AppColors.lightBlue,
      AppColors.chartBlue,
      AppColors.darkBlue,
      AppColors.box1.withOpacity(0.8),
      AppColors.box2.withOpacity(0.8),
      AppColors.box3.withOpacity(0.8),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: breakdown.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final drinkEntry = entry.value;
        final color = colors[index % colors.length];
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              drinkEntry.key,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSubtitle,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHourlyPattern(DetailedStatistics stats) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drinking Pattern',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 24,
                  color: AppColors.lightBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Most active hour: ${_formatHour(stats.favoriteHour)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textHeadline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You tend to drink water most frequently around ${_formatHour(stats.favoriteHour)}.',
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

  Widget _buildGoalAchievementSection(DetailedStatistics stats) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Achievement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.waterLow,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: stats.goalAchievementRate,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.waterFull,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(stats.goalAchievementRate * 100).toInt()}% of days with goal achieved',
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
              'Failed to Load Statistics',
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
                analytics.loadDetailedStatistics();
                analytics.loadStreakData();
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
              Icons.bar_chart,
              size: 64,
              color: AppColors.lightBlue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Detailed Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get comprehensive insights with detailed statistics, streak analysis, and drinking patterns.',
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

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData('csv');
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData('pdf');
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(String format) async {
    final analytics = context.read<AnalyticsProvider>();
    
    String? filePath;
    if (format == 'csv') {
      filePath = await analytics.exportToCsv();
    } else if (format == 'pdf') {
      filePath = await analytics.exportToPdf();
    }

    if (mounted) {
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to: $filePath'),
            backgroundColor: AppColors.waterFull,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(analytics.lastError?.message ?? 'Export failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> breakdown) {
    final total = breakdown.values.fold(0, (sum, value) => sum + value);
    final colors = [
      AppColors.waterFull,
      AppColors.lightBlue,
      AppColors.chartBlue,
      AppColors.darkBlue,
      AppColors.box1.withOpacity(0.8),
      AppColors.box2.withOpacity(0.8),
      AppColors.box3.withOpacity(0.8),
    ];

    return breakdown.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final drinkEntry = entry.value;
      final percentage = (drinkEntry.value / total) * 100;
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: drinkEntry.value.toDouble(),
        title: '${percentage.toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  StreakData _createEmptyStreakData() {
    return const StreakData(
      currentStreak: 0,
      longestStreak: 0,
      streakHistory: [],
      lastGoalAchievedDate: null,
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}