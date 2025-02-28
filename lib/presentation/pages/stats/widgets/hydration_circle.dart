import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_state.dart';

class HydrationCircle extends StatelessWidget {
  const HydrationCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        final bloc = context.read<WaterBloc>();
        final progress = bloc.progress;
        final currentWater = bloc.currentWater;
        final remainingWater = bloc.remainingWater;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress circle
              SizedBox(
                width: 280,
                height: 280,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 20,
                  backgroundColor: AppColors.waterLow,
                  color: AppColors.lightBlue,
                ),
              ),

              // Content inside circle
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Percentage
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.darkBlue,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Current amount
                  Text(
                    '$currentWater ml',
                    style: const TextStyle(
                      color: AppColors.darkBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Remaining amount
                  Text(
                    '-$remainingWater ml',
                    style: const TextStyle(
                      color: AppColors.textSubtitle,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
