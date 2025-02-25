import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
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
          if (state.error != null) {
            showErrorSnackBar(context, state.error!);
          }
        },
        child: Stack(
          children: [
            Padding(
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