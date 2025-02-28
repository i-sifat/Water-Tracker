import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/presentation/blocs/history/history_bloc.dart';
import 'package:watertracker/presentation/blocs/history/history_event.dart';
import 'package:watertracker/presentation/blocs/history/history_state.dart';
import 'package:watertracker/presentation/pages/history/widgets/week_selector.dart';
import 'package:watertracker/presentation/pages/history/widgets/weekly_chart.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 100, // Space for bottom nav bar
          top: 32,
          left: 20,
          right: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: AppColors.darkBlue),
                  onPressed: () {
                    // Add new history entry
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Week selector
            BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                return WeekSelector(
                  weeks: state.weeks,
                  selectedWeek: state.selectedWeek.weekNumber,
                  onWeekSelected: (weekNumber) {
                    context.read<HistoryBloc>().add(SelectWeek(weekNumber));
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Weekly chart
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  return WeeklyChart(weekData: state.selectedWeek);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}