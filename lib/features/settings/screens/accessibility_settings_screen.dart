import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/providers/theme_provider.dart';
import 'package:watertracker/core/widgets/common/accessible_button.dart';
import 'package:watertracker/l10n/app_localizations.dart';

class AccessibilitySettingsScreen extends StatelessWidget {

  const AccessibilitySettingsScreen({super.key});
  static const String routeName = '/accessibility-settings';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accessibility),
        leading: AccessibleIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          semanticLabel: l10n.backButton,
          tooltip: l10n.back,
        ),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // High Contrast Mode
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.highContrast,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Increase contrast for better visibility',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enable High Contrast',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Switch(
                            value: themeProvider.isHighContrastEnabled,
                            onChanged: (value) {
                              themeProvider.setHighContrastMode(value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Text Size
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.textSize,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adjust text size for better readability',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'A',
                            style: theme.textTheme.bodySmall,
                          ),
                          Expanded(
                            child: Slider(
                              value: themeProvider.textScaleFactor,
                              min: 0.8,
                              max: 2,
                              divisions: 12,
                              label: '${(themeProvider.textScaleFactor * 100).round()}%',
                              onChanged: (value) {
                                themeProvider.setTextScaleFactor(value);
                              },
                            ),
                          ),
                          Text(
                            'A',
                            style: theme.textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Sample text at ${(themeProvider.textScaleFactor * 100).round()}% size',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reduced Motion
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reducedMotion,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reduce animations and motion effects',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enable Reduced Motion',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Switch(
                            value: themeProvider.isReducedMotionEnabled,
                            onChanged: (value) {
                              themeProvider.setReducedMotion(value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reset to Defaults
              AccessibleButton(
                onPressed: () => _showResetDialog(context, themeProvider, l10n),
                semanticLabel: 'Reset accessibility settings to default',
                child: const Text('Reset to Defaults'),
              ),

              const SizedBox(height: 32),

              // Accessibility Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Accessibility Information',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This app supports screen readers, voice control, and other accessibility features. '
                        'For the best experience, enable accessibility features in your device settings.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Minimum touch target size: 44x44 dp',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeProvider themeProvider, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Accessibility Settings'),
          content: const Text('This will reset all accessibility settings to their default values. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                themeProvider
                  ..setHighContrastMode(false)
                  ..setTextScaleFactor(1)
                  ..setReducedMotion(false);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Accessibility settings reset to defaults'),
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}