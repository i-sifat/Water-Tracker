import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
import 'package:watertracker/presentation/widgets/rolling_switch_button.dart';
import 'package:watertracker/presentation/utils/dialog_utils.dart';
import 'package:watertracker/core/utils/extensions.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WaterBloc>();
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
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
                      value: bloc.state.alarmEnabled,
                      colorOff: theme.colorScheme.error,
                      onChange: (value) => bloc.changeAlarmEnabled(value),
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
                        bloc.state.recommendedMilliliters.asMilliliters(),
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
      ),
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
        context.read<WaterBloc>().clearDataStore();
      }
    }
  }
}