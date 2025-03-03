import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/providers/hydration_provider.dart';
import 'package:watertracker/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/screens/add_hydration_screen.dart';
import 'package:watertracker/screens/home_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 2;
  int selectedWeekIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenContent(),
    const AddHydrationScreenContent(),
    HistoryScreenContent(selectedWeekIndex: 0),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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

  Widget _buildSegmentedControl(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Occupy full width
      child: CupertinoSlidingSegmentedControl<int>(
        children: {
          0: _buildSegmentedControlItem(context, "Week 1"),
          1: _buildSegmentedControlItem(context, "Week 2"),
          2: _buildSegmentedControlItem(context, "Week 3"),
          3: _buildSegmentedControlItem(context, "Week 4"),
        },
        groupValue: selectedWeekIndex,
        onValueChanged: (value) {
          setState(() {
            selectedWeekIndex = value!;
          });
        },
        thumbColor: const Color(0xFFB1C7FF), // Light blue thumb color
        backgroundColor: Colors.grey[200]!, // Light grey background
      ),
    );
  }

  Widget _buildSegmentedControlItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<int> weeklyData,
    HydrationProvider hydrationProvider,
  ) {
    return List.generate(7, (index) {
      final value =
          index < weeklyData.length
              ? weeklyData[index] / 1000
              : 0.0; // Convert ml to L
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: const Color(0xFFB1C7FF), // Light blue
            width: 25,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            rodStackItems: [
              BarChartRodStackItem(0, value, const Color(0xFFB1C7FF)),
            ],
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }
}

class HistoryScreenContent extends StatelessWidget {
  final int selectedWeekIndex;
  const HistoryScreenContent({super.key, required this.selectedWeekIndex});

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    // final weeklyData = hydrationProvider.getWeeklyData(selectedWeekIndex);
    // final averageIntake = hydrationProvider.getAverageIntake(selectedWeekIndex);
    final historyScreenState =
        context.findAncestorStateOfType<_HistoryScreenState>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "History",
              style: textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (historyScreenState != null)
              historyScreenState._buildSegmentedControl(context),
            const SizedBox(height: 40),
            Text("Average", style: textTheme.titleMedium),
            Text(
              // "${averageIntake.toStringAsFixed(1)} L",
              "${historyScreenState?.selectedWeekIndex ?? "0"}",
              style: textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: historyScreenState!._buildBarGroups(
                    hydrationProvider.getWeeklyData(
                      historyScreenState.selectedWeekIndex,
                    ),
                    hydrationProvider,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Sa',
                            'Su',
                            'Mo',
                            'Tu',
                            'We',
                            'Th',
                            'Fr',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()]),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      getTooltipItem: (
                        BarChartGroupData group,
                        int groupIndex,
                        BarChartRodData rod,
                        int rodIndex,
                      ) {
                        return BarTooltipItem(
                          rod.toY.toStringAsFixed(2),
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
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
}
