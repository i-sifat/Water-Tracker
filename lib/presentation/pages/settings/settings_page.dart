import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/resources/app_colors.dart';
import 'package:watertracker/core/utils/extensions.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_event.dart';
import 'package:watertracker/presentation/blocs/water/water_state.dart';
import 'package:watertracker/presentation/utils/dialog_utils.dart';
import 'package:watertracker/presentation/widgets/error_snackbar.dart';
import 'package:watertracker/presentation/widgets/rolling_switch_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          padding: const EdgeInsets.only(
            bottom: 136,
            top: 32,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(width: double.infinity),
                Text(
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textHeadline,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Avatar selection
                _buildAvatarSelection(context),
                
                const SizedBox(height: 32),
                
                // Reminders toggle
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reminders',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textHeadline,
                          ),
                        ),
                      ),
                      RollingSwitchButton(
                        value: state.settings.alarmEnabled,
                        onChange: (value) => context
                            .read<WaterBloc>()
                            .add(ChangeAlarmEnabled(value)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Daily consumption
                TextButton(
                  onPressed: () => showConsumptionDialog(context),
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(
                      theme.colorScheme.primary.withOpacity(0.06),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Daily consumption',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textHeadline,
                            ),
                          ),
                        ),
                        Text(
                          state.settings.recommendedMilliliters.asMilliliters(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Reset button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => clearDataStore(context),
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(
                        theme.colorScheme.error.withOpacity(0.06),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Reset Data',
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

  Widget _buildAvatarSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avatar',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textHeadline,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AvatarOption(
              isSelected: true, // Will be dynamic based on user preference
              isMale: true,
              onTap: () {
                // Update user preference to male
              },
            ),
            const SizedBox(width: 32),
            _AvatarOption(
              isSelected: false, // Will be dynamic based on user preference
              isMale: false,
              onTap: () {
                // Update user preference to female
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const ColoredBox(
            color: Colors.black26,
            child: Center(
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
      title: 'Reset Data',
      content: 'You are about to reset all the application data. '
          'This action cannot be undone.',
    );
    if (confirmed && context.mounted) {
      context.read<WaterBloc>().add(const ClearDataStore());
    }
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.isSelected,
    required this.isMale,
    required this.onTap,
  });
  
  final bool isSelected;
  final bool isMale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.box1 : AppColors.checkBoxCircle,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.lightBlue, width: 2)
              : null,
        ),
        child: Center(
          child: Image.asset(
            isMale ? 'assets/avatars/male-avater.svg' : 'assets/avatars/female-avater.svg',
            width: 60,
            height: 60,
          ),
        ),
      ),
    );
  }
}