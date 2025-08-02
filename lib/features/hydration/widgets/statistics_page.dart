import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/utils/accessibility_utils.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

enum StatisticsPeriod { weekly, monthly, yearly }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatisticsPeriod _selectedPeriod = StatisticsPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, child) {
        return Semantics(
          label: 'Statistics page',
          hint: 'View your hydration statistics and progress over time',
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildPeriodSelector(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Performance optimization: RepaintBoundary around streak section
                          RepaintBoundary(child: _buildStreakSection(provider)),
                          const SizedBox(height: 16),
                          // Performance optimization: RepaintBoundary around chart
                          RepaintBoundary(child: _buildIntakeChart(provider)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Performance optimization: RepaintBoundary around cards
                              Expanded(
                                child: RepaintBoundary(
                                  child: _buildBalanceCard(provider),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: RepaintBoundary(
                                  child: _buildDailyAverageCard(provider),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Performance optimization: RepaintBoundary around most used section
                          RepaintBoundary(
                            child: _buildMostUsedSection(provider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AccessibilityUtils.createAccessibleText(
        text: 'Statistics',
        style: AppTypography.hydrationTitle.copyWith(
          color: AppColors.textHeadline,
        ),
        semanticLabel: 'Statistics page header',
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            StatisticsPeriod.values.map((period) {
              final isSelected = _selectedPeriod == period;
              return Expanded(
                child: AccessibilityUtils.ensureMinTouchTarget(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  semanticLabel:
                      '${period.name.toUpperCase()} time period${isSelected ? ', currently selected' : ''}',
                  semanticHint:
                      'Double tap to select this time period for statistics',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.waterFull : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.waterFull
                                : AppColors.textSubtitle,
                      ),
                    ),
                    child: AccessibilityUtils.createAccessibleText(
                      text: period.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppColors.textSubtitle,
                        fontFamily: 'Nunito',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildStreakSection(HydrationProvider provider) {
    return Semantics(
      label: AccessibilityUtils.createStatisticsCardLabel(
        'Days in a row streak',
        '${provider.currentStreak}',
        'days',
      ),
      hint: 'Your current consecutive days of meeting hydration goals',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  excludeSemantics: true, // Icon is decorative
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppColors.goalYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                AccessibilityUtils.createAccessibleText(
                  text: 'Days in a row',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                    fontFamily: 'Nunito',
                  ),
                ),
                const Spacer(),
                AccessibilityUtils.createAccessibleText(
                  text: '${provider.currentStreak}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.waterFull,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeeklyDots(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyDots(HydrationProvider provider) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        final dayEntries = provider.getEntriesForDate(date);
        final isCompleted = dayEntries.totalWaterIntake >= provider.dailyGoal;
        final isToday =
            date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;

        return Semantics(
          label: AccessibilityUtils.createStreakIndicatorLabel(
            index,
            isCompleted,
            isToday,
          ),
          child: Column(
            children: [
              AccessibilityUtils.createAccessibleText(
                text: weekDays[index],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSubtitle,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isCompleted
                          ? AppColors.waterFull
                          : (isToday
                              ? AppColors.waterFull.withValues(alpha: 0.3)
                              : AppColors.goalGrey),
                  border:
                      isToday && !isCompleted
                          ? Border.all(color: AppColors.waterFull, width: 2)
                          : null,
                ),
                child:
                    isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIntakeChart(HydrationProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Intake',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textHeadline,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildBarChart(provider)),
        ],
      ),
    );
  }

  Widget _buildBarChart(HydrationProvider provider) {
    final chartData = _getChartData(provider);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: provider.dailyGoal.toDouble() * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getBottomTitle(value.toInt()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSubtitle,
                    fontFamily: 'Nunito',
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(),
        barGroups:
            chartData.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value.toDouble(),
                    color: AppColors.waterFull,
                    width: 16,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: provider.dailyGoal.toDouble() / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.goalGrey.withValues(alpha: 0.3));
          },
        ),
      ),
    );
  }

  List<int> _getChartData(HydrationProvider provider) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case StatisticsPeriod.weekly:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final dayEntries = provider.getEntriesForDate(date);
          return dayEntries.totalWaterIntake;
        });

      case StatisticsPeriod.monthly:
        final monthStart = DateTime(now.year, now.month);
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return List.generate(daysInMonth, (index) {
          final date = monthStart.add(Duration(days: index));
          final dayEntries = provider.getEntriesForDate(date);
          return dayEntries.totalWaterIntake;
        });

      case StatisticsPeriod.yearly:
        return List.generate(12, (index) {
          final monthStart = DateTime(now.year, index + 1);
          final monthEnd = DateTime(now.year, index + 2, 0);
          var monthTotal = 0;
          var daysCount = 0;

          for (
            var day = monthStart;
            day.isBefore(monthEnd.add(const Duration(days: 1)));
            day = day.add(const Duration(days: 1))
          ) {
            final dayEntries = provider.getEntriesForDate(day);
            monthTotal += dayEntries.totalWaterIntake;
            daysCount++;
          }

          return daysCount > 0 ? (monthTotal / daysCount).round() : 0;
        });
    }
  }

  String _getBottomTitle(int index) {
    switch (_selectedPeriod) {
      case StatisticsPeriod.weekly:
        final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
        return weekDays[index % 7];

      case StatisticsPeriod.monthly:
        return '${index + 1}';

      case StatisticsPeriod.yearly:
        final months = [
          'J',
          'F',
          'M',
          'A',
          'M',
          'J',
          'J',
          'A',
          'S',
          'O',
          'N',
          'D',
        ];
        return months[index % 12];
    }
  }

  Widget _buildBalanceCard(HydrationProvider provider) {
    final percentage = (provider.intakePercentage * 100).round();

    return Semantics(
      label: AccessibilityUtils.createStatisticsCardLabel(
        'Balance',
        '$percentage%',
        'completed',
      ),
      hint: 'Percentage of daily hydration goal completed',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccessibilityUtils.createAccessibleText(
              text: 'Balance',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            AccessibilityUtils.createAccessibleText(
              text: '$percentage%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.waterFull,
                fontFamily: 'Nunito',
              ),
            ),
            AccessibilityUtils.createAccessibleText(
              text: 'completed',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSubtitle,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyAverageCard(HydrationProvider provider) {
    final average = _calculateDailyAverage(provider);

    return Semantics(
      label: AccessibilityUtils.createStatisticsCardLabel(
        'Daily average',
        '${(average / 1000).toStringAsFixed(1)} liters',
        'per day',
      ),
      hint: 'Your average daily hydration intake',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccessibilityUtils.createAccessibleText(
              text: 'Daily average',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            AccessibilityUtils.createAccessibleText(
              text: '${(average / 1000).toStringAsFixed(1)} L',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.waterFull,
                fontFamily: 'Nunito',
              ),
            ),
            AccessibilityUtils.createAccessibleText(
              text: 'per day',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSubtitle,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDailyAverage(HydrationProvider provider) {
    final now = DateTime.now();
    final daysToCheck =
        _selectedPeriod == StatisticsPeriod.weekly
            ? 7
            : _selectedPeriod == StatisticsPeriod.monthly
            ? 30
            : 365;

    var totalIntake = 0;
    var daysWithData = 0;

    for (var i = 0; i < daysToCheck; i++) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = provider.getEntriesForDate(date);
      final dayIntake = dayEntries.totalWaterIntake;

      if (dayIntake > 0) {
        totalIntake += dayIntake;
        daysWithData++;
      }
    }

    return daysWithData > 0 ? totalIntake / daysWithData : 0.0;
  }

  Widget _buildMostUsedSection(HydrationProvider provider) {
    final mostUsedDrinks = _getMostUsedDrinks(provider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most used',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textHeadline,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 16),
          ...mostUsedDrinks.asMap().entries.map((entry) {
            final index = entry.key;
            final drinkData = entry.value;

            return Padding(
              padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
              child: Row(
                children: [
                  Text(
                    '${index + 1}.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeadline,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    drinkData['icon'] as IconData,
                    color: AppColors.waterFull,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      drinkData['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textHeadline,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  Text(
                    '${((drinkData['amount'] as int) / 1000).toStringAsFixed(1)} L',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.waterFull,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMostUsedDrinks(HydrationProvider provider) {
    final now = DateTime.now();
    final daysToCheck =
        _selectedPeriod == StatisticsPeriod.weekly
            ? 7
            : _selectedPeriod == StatisticsPeriod.monthly
            ? 30
            : 365;

    final drinkTotals = <DrinkType, int>{};

    for (var i = 0; i < daysToCheck; i++) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = provider.getEntriesForDate(date);

      for (final entry in dayEntries) {
        drinkTotals[entry.type] =
            (drinkTotals[entry.type] ?? 0) + entry.waterContent;
      }
    }

    final sortedDrinks =
        drinkTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedDrinks.take(3).map((entry) {
      return {
        'name': entry.key.displayName,
        'icon': entry.key.icon,
        'amount': entry.value,
      };
    }).toList();
  }
}
