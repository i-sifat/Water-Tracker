import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/domain/models/water_history.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    required this.weekData,
    super.key,
  });
  
  final WeeklyWaterData weekData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water drop icon and average text
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: AppColors.darkBlue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'average',
                    style: TextStyle(
                      color: AppColors.textSubtitle,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${(weekData.average / 1000).toStringAsFixed(2)} L',
                    style: const TextStyle(
                      color: AppColors.darkBlue,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Bar chart
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 2,
                minY: 0,
                groupsSpace: 12,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < weekData.dailyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weekData.dailyData[index].dayAbbreviation,
                              style: const TextStyle(
                                color: AppColors.darkBlue,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  weekData.dailyData.length,
                  (index) {
                    final data = weekData.dailyData[index];
                    final hasData = data.amount > 0;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.liters,
                          width: 40,
                          color: hasData ? AppColors.lightBlue : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Values below the chart
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                weekData.dailyData.length,
                (index) {
                  final data = weekData.dailyData[index];
                  final hasData = data.amount > 0;
                  
                  return Text(
                    data.liters.toStringAsFixed(2),
                    style: TextStyle(
                      color: hasData ? AppColors.darkBlue : AppColors.darkBlue,
                      fontWeight: hasData ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}