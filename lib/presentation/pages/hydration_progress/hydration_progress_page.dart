import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_event.dart';
import 'package:watertracker/presentation/blocs/water/water_state.dart';
import 'package:watertracker/presentation/pages/hydration_progress/widgets/progress_view.dart';
import 'package:watertracker/presentation/pages/hydration_progress/widgets/water_input_group.dart';
import 'package:watertracker/presentation/widgets/error_snackbar.dart';

class HydrationProgressPage extends StatelessWidget {
  const HydrationProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<WaterBloc, WaterState>(
        listener: (context, state) {
          final error = state.error;
          if (error != null) {
            showErrorSnackBar(context, error);
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 136,
                top: 32,
              ),
              child: Column(
                children: [
                  const SizedBox(width: double.infinity),
                  Text(
                    'Current Hydration',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textHeadline,
                    ),
                  ),
                  const Expanded(
                    child: ProgressView(),
                  ),
                  const WaterInputGroup(),
                ],
              ),
            ),
            BlocBuilder<WaterBloc, WaterState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}