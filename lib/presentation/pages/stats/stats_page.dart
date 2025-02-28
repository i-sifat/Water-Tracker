import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_event.dart';
import 'package:watertracker/presentation/pages/stats/widgets/hydration_circle.dart';
import 'package:watertracker/presentation/pages/stats/widgets/water_amount_button.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 100, // Space for bottom nav bar
          top: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Current Hydration',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 40),

            // Circular progress indicator
            const Expanded(
              child: HydrationCircle(),
            ),

            const SizedBox(height: 40),

            // Water amount buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: WaterAmountButton(
                          amount: 250,
                          color: const Color(0xFFE9D9FF),
                          onTap: () => _addWater(context, 250),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: WaterAmountButton(
                          amount: 500,
                          color: const Color(0xFFD4FFFB),
                          onTap: () => _addWater(context, 500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: WaterAmountButton(
                          amount: 100,
                          color: const Color(0xFFDAFFC7),
                          onTap: () => _addWater(context, 100),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: WaterAmountButton(
                          amount: 400,
                          color: const Color(0xFFFFF8BB),
                          onTap: () => _addWater(context, 400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addWater(BuildContext context, int amount) {
    context.read<WaterBloc>().add(DrinkWater(amount));
  }
}
