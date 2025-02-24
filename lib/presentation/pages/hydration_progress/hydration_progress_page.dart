import 'package:flutter/material.dart';
import 'package:watertracker/presentation/pages/hydration_progress/widgets/progress_view.dart';
import 'package:watertracker/presentation/pages/hydration_progress/widgets/water_input_group.dart';

class HydrationProgressPage extends StatelessWidget {
  const HydrationProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32 + 64 + 40, top: 32.0),
        child: Column(
          children: [
            const SizedBox(width: double.infinity),
            Text(
              "Current Hydration",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Expanded(
              child: ProgressView(),
            ),
            const WaterInputGroup(),
          ],
        ),
      ),
    );
  }
}