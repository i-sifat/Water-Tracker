import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/goal_breakdown_page.dart';

/// Example app demonstrating the GoalBreakdownPage widget
class GoalBreakdownPageExample extends StatelessWidget {
  const GoalBreakdownPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Breakdown Page Example',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Nunito'),
      home: ChangeNotifierProvider(
        create: (context) => HydrationProvider(),
        child: const GoalBreakdownPage(),
      ),
    );
  }
}

/// Main function to run the example
void main() {
  runApp(const GoalBreakdownPageExample());
}
