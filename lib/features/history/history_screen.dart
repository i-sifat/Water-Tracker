import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/screens/add_hydration_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class HistoryScreenContent extends StatefulWidget {
  const HistoryScreenContent({required this.selectedWeekIndex, super.key});

  final int selectedWeekIndex;

  @override
  State<HistoryScreenContent> createState() => _HistoryScreenContentState();
}

class _HistoryScreenContentState extends State<HistoryScreenContent>
    with SingleTickerProviderStateMixin {
  late int _selectedWeekIndex;
  late AnimationController _animationController;
  late Animation<double> _barAnimation;

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);

    // Sample data for visualization
    final weeklyData = <double>[1.45, 1.45, 1.45, 1.45, 1.45, 1.45, 1.45];
    const averageIntake = 1.84;

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildWeekSelector(),
          const SizedBox(height: 40),
          _buildAverageCard(averageIntake, weeklyData),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedWeekIndex = widget.selectedWeekIndex;

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Bar height animation
    _barAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animation when page is loaded
    _animationController.forward();
  }

  Widget _buildAverageCard(double averageIntake, List<double> weeklyData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.chartBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/navbaricons/waterdropicons-unselect.svg',
                    width: 30,
                    height: 30,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'average',
                    style: TextStyle(
                      color: AppColors.textSubtitle,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$averageIntake L',
                    style: const TextStyle(
                      color: AppColors.textHeadline,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SizedBox(
                height: 240,
                child: BarChart(
                  BarChartData(
                    barGroups: _buildBarGroups(weeklyData),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = [
                              'sa',
                              'su',
                              'mo',
                              'tu',
                              'we',
                              'th',
                              'fr',
                            ];
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  color: AppColors.textHeadline,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        tooltipPadding: EdgeInsets.zero,
                        tooltipMargin: 0,
                        getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          return BarTooltipItem(
                            rod.toY.toStringAsFixed(2),
                            const TextStyle(
                              color: AppColors.textHeadline,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<double> weeklyData) {
    // Based on the image, Monday, Tuesday, and Thursday are filled (indices 2, 3, 5)
    final filledDays = [2, 3, 5];

    // Get actual hydration data from provider to determine which days should be filled
    // This is a placeholder - in a real app, you would pull this from your hydration provider

    return List.generate(7, (index) {
      final isActive = filledDays.contains(index);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY:
                weeklyData[index] *
                _barAnimation.value, // Animate the height of the bars
            color: isActive ? AppColors.chartBlue : Colors.white,
            width: 40,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            borderSide:
                isActive
                    ? BorderSide.none
                    : const BorderSide(color: Colors.grey),
          ),
        ],
        showingTooltipIndicators:
            isActive ? [0] : [], // Show tooltips only for active bars
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.darkBlue),
              onPressed: () {
                // Add functionality
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          final weekNum = index + 1;
          final isSelected = _selectedWeekIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWeekIndex = index;
                // Restart animation when changing weeks
                _animationController
                  ..reset()
                  ..forward();
              });
            },
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.selectedWeekBackground
                        : AppColors.unselectedWeekBackground,
                borderRadius: BorderRadius.circular(30),
                border:
                    !isSelected
                        ? Border.all(color: Colors.grey.shade200)
                        : null,
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Center(
                child: Text(
                  "week $weekNum",
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textHeadline,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HistoryScreenState extends State<HistoryScreen> {
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenContent(),
    const AddHydrationScreenContent(),
    HistoryScreenContent(selectedWeekIndex: 1), // Default to week 2
  ];
  int _selectedIndex = 2;

  int selectedWeekIndex = 1; // Start with week 2 selected as shown in the image

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
