import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_event.dart';
import 'package:watertracker/presentation/widgets/rolling_switch_button.dart';
import 'package:watertracker/presentation/utils/dialog_utils.dart';
import 'package:watertracker/core/utils/extensions.dart';
import 'package:watertracker/presentation/widgets/error_snackbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            _buildMainContent(context),
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: 32 + 64 + 40, top: 32.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const SizedBox(width: double.infinity),
                Text(
                  "Settings",
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 4),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text("Reminders"),
                      ),
                      RollingSwitchButton(
                        value: state.settings.alarmEnabled,
                        colorOff: theme.colorScheme.error,
                        onChange: (value) => context.read<WaterBloc>().add(ChangeAlarmEnabled(value)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => showConsumptionDialog(context),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        theme.colorScheme.primary.withOpacity(0.06)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Daily consumption",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          state.settings.recommendedMilliliters.asMilliliters(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => clearDataStore(context),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          theme.colorScheme.error.withOpacity(0.06)),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Hard Reset",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> clearDataStore(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: "Hard Reset",
      content:
          "You are about to reset all the application data. This action cannot be undone.",
    );
    if (confirmed) {
      if (context.mounted) {
        context.read<WaterBloc>().add(const ClearDataStore());
      }
    }
  }
}