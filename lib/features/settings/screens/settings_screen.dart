import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/providers/theme_provider.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/utils/avatar_extensions.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/loading_widget.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/premium/screens/donation_info_screen.dart';
import 'package:watertracker/features/settings/models/settings_models.dart';
import 'package:watertracker/features/settings/providers/settings_provider.dart';
import 'package:watertracker/features/settings/screens/accessibility_settings_screen.dart';
import 'package:watertracker/features/settings/screens/avatar_selection_screen.dart';
import 'package:watertracker/features/settings/screens/backup_restore_screen.dart';
import 'package:watertracker/features/settings/screens/custom_reminders_screen.dart';
import 'package:watertracker/features/settings/screens/data_management_screen.dart';
import 'package:watertracker/features/settings/screens/language_selection_screen.dart';
import 'package:watertracker/features/settings/screens/notification_settings_screen.dart';
import 'package:watertracker/features/settings/screens/user_profile_screen.dart';
import 'package:watertracker/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize settings provider if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (!settingsProvider.isInitialized) {
        settingsProvider.reloadSettings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (!settingsProvider.isInitialized || settingsProvider.isLoading) {
            return const Center(child: LoadingWidget());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                _buildSectionHeader('Profile'),
                const SizedBox(height: 12),
                _buildUserProfileCard(context, settingsProvider),
                const SizedBox(height: 24),

                // Notifications Section
                _buildSectionHeader('Notifications'),
                const SizedBox(height: 12),
                _buildNotificationCard(context, settingsProvider),
                const SizedBox(height: 24),

                // App Preferences Section
                _buildSectionHeader('Preferences'),
                const SizedBox(height: 12),
                _buildPreferencesCard(context, settingsProvider),
                const SizedBox(height: 24),

                // Theme Section
                _buildSectionHeader('Appearance'),
                const SizedBox(height: 12),
                _buildThemeCard(context),
                const SizedBox(height: 24),

                // Accessibility Section
                _buildSectionHeader('Accessibility'),
                const SizedBox(height: 12),
                _buildAccessibilityCard(context),
                const SizedBox(height: 24),

                // Language Section
                _buildSectionHeader('Language'),
                const SizedBox(height: 12),
                _buildLanguageCard(context),
                const SizedBox(height: 24),

                // Data Management Section
                _buildSectionHeader('Data'),
                const SizedBox(height: 12),
                _buildDataManagementCard(context, settingsProvider),
                const SizedBox(height: 24),

                // Premium Section
                _buildSectionHeader('Premium'),
                const SizedBox(height: 12),
                _buildPremiumCard(context, settingsProvider),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader('About'),
                const SizedBox(height: 12),
                _buildAboutCard(context),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, SettingsProvider settingsProvider) {
    final userProfile = settingsProvider.userProfile;
    final avatar = settingsProvider.appPreferences.selectedAvatar;

    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.waterFull.withValues(alpha: 0.1),
              child: SvgPicture.asset(
                avatar.assetPath,
                width: 32,
                height: 32,
              ),
            ),
            title: Text(
              userProfile?.isComplete == true 
                  ? '${userProfile!.age} years old, ${userProfile.gender.displayName}'
                  : 'Complete your profile',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Daily Goal: ${settingsProvider.getFormattedDailyGoal()}',
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _navigateToUserProfile(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.face, color: AppColors.waterFull),
            title: const Text(
              'Avatar',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              avatar.displayName,
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _navigateToAvatarSelection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, SettingsProvider settingsProvider) {
    final notificationSettings = settingsProvider.notificationSettings;

    return AppCard(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: AppColors.waterFull),
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              notificationSettings.enabled 
                  ? 'Every ${notificationSettings.interval}h from ${notificationSettings.startHour}:00 to ${notificationSettings.endHour}:00'
                  : 'Disabled',
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
            value: notificationSettings.enabled,
            onChanged: (value) => settingsProvider.toggleNotifications(enabled: value),
            activeColor: AppColors.waterFull,
          ),
          if (notificationSettings.enabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.schedule, color: AppColors.waterFull),
              title: const Text(
                'Notification Schedule',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Customize timing and frequency',
                style: TextStyle(color: AppColors.textSubtitle),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
              onTap: () => _navigateToNotificationSettings(context),
            ),
            const Divider(height: 1),
            PremiumGate(
              feature: PremiumFeature.customReminders,
              lockedChild: ListTile(
                leading: Icon(Icons.alarm_add, color: AppColors.textSubtitle.withValues(alpha: 0.5)),
                title: Text(
                  'Custom Reminders',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSubtitle.withValues(alpha: 0.5),
                  ),
                ),
                subtitle: const Text(
                  'Premium feature - Unlock to customize',
                  style: TextStyle(color: AppColors.textSubtitle),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.waterFull.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.waterFull,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.lock, size: 16, color: AppColors.textSubtitle),
                  ],
                ),
                onTap: () => _showPremiumDialog(context),
              ),
              child: ListTile(
                leading: const Icon(Icons.alarm_add, color: AppColors.waterFull),
                title: const Text(
                  'Custom Reminders',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${notificationSettings.customReminders.length} custom reminders',
                  style: const TextStyle(color: AppColors.textSubtitle),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.waterFull.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.waterFull,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
                  ],
                ),
                onTap: () => _navigateToCustomReminders(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, SettingsProvider settingsProvider) {
    final preferences = settingsProvider.appPreferences;

    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.straighten, color: AppColors.waterFull),
            title: const Text(
              'Units',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              preferences.units.displayName,
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _showUnitsDialog(context, settingsProvider),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.track_changes, color: AppColors.waterFull),
            title: const Text(
              'Daily Goal',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              settingsProvider.getFormattedDailyGoal(),
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _showDailyGoalDialog(context, settingsProvider),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up, color: AppColors.waterFull),
            title: const Text(
              'Sound Effects',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Play sounds for interactions',
              style: TextStyle(color: AppColors.textSubtitle),
            ),
            value: preferences.soundEnabled,
            onChanged: (value) => settingsProvider.toggleSound(enabled: value),
            activeColor: AppColors.waterFull,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.vibration, color: AppColors.waterFull),
            title: const Text(
              'Haptic Feedback',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Vibrate on button presses',
              style: TextStyle(color: AppColors.textSubtitle),
            ),
            value: preferences.hapticFeedbackEnabled,
            onChanged: (value) => settingsProvider.toggleHapticFeedback(enabled: value),
            activeColor: AppColors.waterFull,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AppCard(
          child: ListTile(
            leading: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.waterFull,
            ),
            title: const Text(
              'Theme',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              themeProvider.themeModeDisplayName,
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _showThemeDialog(context, themeProvider),
          ),
        );
      },
    );
  }

  Widget _buildDataManagementCard(BuildContext context, SettingsProvider settingsProvider) {
    final dataManagement = settingsProvider.dataManagement;

    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.waterFull),
            title: const Text(
              'Backup & Restore',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              dataManagement.autoBackupEnabled 
                  ? 'Auto backup: ${dataManagement.backupFrequency.displayName}'
                  : 'Auto backup disabled',
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _navigateToBackupRestore(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storage, color: AppColors.waterFull),
            title: const Text(
              'Data Management',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Export, clear, and manage your data',
              style: TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _navigateToDataManagement(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, SettingsProvider settingsProvider) {
    return FutureBuilder<bool>(
      future: settingsProvider.isPremiumUnlocked(),
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;

        return AppCard(
          child: ListTile(
            leading: Icon(
              isPremium ? Icons.star : Icons.star_border,
              color: isPremium ? Colors.amber : AppColors.waterFull,
            ),
            title: Text(
              isPremium ? 'Premium Active' : 'Unlock Premium',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              isPremium 
                  ? 'Thank you for supporting the app!'
                  : 'Unlock advanced features with a donation',
              style: const TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: isPremium 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: isPremium ? null : () => _navigateToPremium(context),
          ),
        );
      },
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.waterFull),
            title: const Text(
              'About Water Tracker',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help, color: AppColors.waterFull),
            title: const Text(
              'Help & Support',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Get help and contact support',
              style: TextStyle(color: AppColors.textSubtitle),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
            onTap: () => _showHelpDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityCard(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        
        return AppCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.accessibility, color: AppColors.waterFull),
                title: Text(
                  l10n.accessibility,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  themeProvider.isHighContrastEnabled 
                      ? 'High contrast enabled'
                      : 'Configure accessibility options',
                  style: const TextStyle(color: AppColors.textSubtitle),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
                onTap: () => _navigateToAccessibilitySettings(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.text_fields, color: AppColors.waterFull),
                title: Text(
                  l10n.textSize,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${(themeProvider.textScaleFactor * 100).round()}%',
                  style: const TextStyle(color: AppColors.textSubtitle),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(themeProvider.textScaleFactor * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.textSubtitle,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
                  ],
                ),
                onTap: () => _navigateToAccessibilitySettings(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    
    return AppCard(
      child: ListTile(
        leading: const Icon(Icons.language, color: AppColors.waterFull),
        title: Text(
          l10n.language,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          _getLanguageDisplayName(currentLocale),
          style: const TextStyle(color: AppColors.textSubtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
        onTap: () => _navigateToLanguageSelection(context),
      ),
    );
  }

  String _getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  // Navigation methods
  void _navigateToAccessibilitySettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AccessibilitySettingsScreen(),
      ),
    );
  }

  void _navigateToLanguageSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const LanguageSelectionScreen(),
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const UserProfileScreen(),
      ),
    );
  }

  void _navigateToAvatarSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AvatarSelectionScreen(),
      ),
    );
  }

  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  void _navigateToCustomReminders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const CustomRemindersScreen(),
      ),
    );
  }

  void _navigateToBackupRestore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const BackupRestoreScreen(),
      ),
    );
  }

  void _navigateToDataManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const DataManagementScreen(),
      ),
    );
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.of(context).pushNamed(DonationInfoScreen.routeName);
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLocalizations.supportedLocales.map((locale) {
              final isSelected = locale.languageCode == currentLocale.languageCode;
              return ListTile(
                title: Text(_getLanguageDisplayName(locale)),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.waterFull) : null,
                onTap: () {
                  Navigator.of(context).pop();
                  // Note: Language switching would require app restart or more complex state management
                  // For now, we'll show a message that this feature is coming soon
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language switching will be available in a future update'),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  // Dialog methods
  void _showUnitsDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WaterUnits.values.map((unit) {
            return RadioListTile<WaterUnits>(
              title: Text(unit.displayName),
              value: unit,
              groupValue: settingsProvider.appPreferences.units,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.updateWaterUnits(value);
                  Navigator.of(context).pop();
                }
              },
              activeColor: AppColors.waterFull,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context, SettingsProvider settingsProvider) {
    final controller = TextEditingController();
    final currentGoal = settingsProvider.appPreferences.dailyGoal;
    final units = settingsProvider.appPreferences.units;
    final convertedGoal = units.fromMilliliters(currentGoal);
    
    controller.text = units == WaterUnits.milliliters 
        ? convertedGoal.toInt().toString()
        : convertedGoal.toStringAsFixed(1);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Goal',
                suffixText: units.shortName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recommended: ${units.fromMilliliters(2000).toStringAsFixed(1)} ${units.shortName}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSubtitle,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Save',
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                final goalInMl = units.toMilliliters(value);
                settingsProvider.updateDailyGoal(goalInMl);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeProvider.availableThemes.entries.map((entry) {
            return RadioListTile<ThemeMode>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
              activeColor: AppColors.waterFull,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
          'This feature requires premium unlock. Support the app development by making a donation to unlock all premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Unlock Premium',
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToPremium(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Water Tracker'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Water Tracker v1.0.0'),
            SizedBox(height: 8),
            Text('A simple and effective way to track your daily water intake and stay hydrated.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Track daily water intake'),
            Text('• Smart reminders'),
            Text('• Progress analytics'),
            Text('• Premium features available'),
            SizedBox(height: 16),
            Text('Made with ❤️ for your health'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help with the app?'),
            SizedBox(height: 16),
            Text('Common Questions:'),
            Text('• How to set up notifications?'),
            Text('• How to unlock premium features?'),
            Text('• How to backup my data?'),
            SizedBox(height: 16),
            Text('For support, please contact:'),
            Text('developer@watertracker.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}