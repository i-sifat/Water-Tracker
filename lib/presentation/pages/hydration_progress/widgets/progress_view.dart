import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/core/utils/extensions.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WaterBloc>();
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: bloc.progress,
              backgroundColor: AppColors.waterLow,
              color: AppColors.getWaterColor(bloc.progress),
              strokeWidth: 10,
            ),
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bloc.currentWater.asMilliliters(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textHeadline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${bloc.state.settings.recommendedMilliliters.asMilliliters()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSubtitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}