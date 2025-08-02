import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/statistics_page.dart';

/// Example widget to demonstrate the StatisticsPage component
class StatisticsPageExample extends StatelessWidget {
  const StatisticsPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HydrationProvider(),
      child: MaterialApp(
        title: 'Statistics Page Example',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Nunito'),
        home: const StatisticsPage(),
      ),
    );
  }
}

/// Main function to run the example
void main() {
  runApp(const StatisticsPageExample());
}
