import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/buttons/secondary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/settings/models/settings_models.dart';
import 'package:watertracker/features/settings/providers/settings_provider.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  List<String> _availableBackups = [];
  bool _isLoadingBackups = false;
  Map<String, dynamic> _syncStatus = {};
  bool _isLoadingSyncStatus = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableBackups();
    _loadSyncStatus();
  }

  Future<void> _loadAvailableBackups() async {
    setState(() {
      _isLoadingBackups = true;
    });

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final backups = await settingsProvider.getAvailableBackups();

    if (mounted) {
      setState(() {
        _availableBackups = backups;
        _isLoadingBackups = false;
      });
    }
  }

  Future<void> _loadSyncStatus() async {
    setState(() {
      _isLoadingSyncStatus = true;
    });

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final status = await settingsProvider.getSyncStatus();

    if (mounted) {
      setState(() {
        _syncStatus = status;
        _isLoadingSyncStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
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
          final dataManagement = settingsProvider.dataManagement;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Auto Backup Settings
                const Text(
                  'Auto Backup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                AppCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.backup, color: AppColors.waterFull),
                        title: const Text(
                          'Auto Backup',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: const Text(
                          'Automatically backup your data',
                          style: TextStyle(color: AppColors.textSubtitle),
                        ),
                        value: dataManagement.autoBackupEnabled,
                        onChanged: (value) => settingsProvider.toggleAutoBackup(enabled: value),
                        activeColor: AppColors.waterFull,
                      ),
                      if (dataManagement.autoBackupEnabled) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.schedule, color: AppColors.waterFull),
                          title: const Text(
                            'Backup Frequency',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            dataManagement.backupFrequency.displayName,
                            style: const TextStyle(color: AppColors.textSubtitle),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtitle),
                          onTap: () => _showBackupFrequencyDialog(settingsProvider),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Manual Backup
                const Text(
                  'Manual Backup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Backup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a backup of your current data',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSubtitle,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Create Backup',
                          onPressed: () => _createBackup(settingsProvider),
                          isLoading: settingsProvider.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Cloud Sync (Premium)
                const Text(
                  'Cloud Sync',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                PremiumGate(
                  feature: PremiumFeature.backupRestore,
                  lockedChild: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Cloud Sync',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSubtitle,
                                ),
                              ),
                              const SizedBox(width: 8),
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
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Premium feature - Sync your data across devices',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSubtitle,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SecondaryButton(
                            text: 'Unlock Premium',
                            onPressed: () {
                              // Navigate to premium screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Navigate to premium unlock'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: _buildCloudSyncCard(settingsProvider),
                ),
                
                const SizedBox(height: 24),
                
                // Available Backups
                const Text(
                  'Available Backups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                AppCard(
                  child: _isLoadingBackups
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _availableBackups.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: 48,
                                      color: AppColors.textSubtitle,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No backups available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSubtitle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: _availableBackups.map((backup) {
                                final fileName = backup.split('/').last;
                                return ListTile(
                                  leading: const Icon(Icons.backup, color: AppColors.waterFull),
                                  title: Text(
                                    fileName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Tap to restore',
                                    style: TextStyle(color: AppColors.textSubtitle),
                                  ),
                                  trailing: const Icon(Icons.restore, color: AppColors.waterFull),
                                  onTap: () => _showRestoreDialog(backup, settingsProvider),
                                );
                              }).toList(),
                            ),
                ),
                
                const SizedBox(height: 16),
                
                SecondaryButton(
                  text: 'Refresh Backups',
                  onPressed: _loadAvailableBackups,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBackupFrequencyDialog(SettingsProvider settingsProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BackupFrequency.values.map((frequency) {
            return RadioListTile<BackupFrequency>(
              title: Text(frequency.displayName),
              value: frequency,
              groupValue: settingsProvider.dataManagement.backupFrequency,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.updateBackupFrequency(value);
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

  Future<void> _createBackup(SettingsProvider settingsProvider) async {
    final success = await settingsProvider.createBackup();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadAvailableBackups();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create backup'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRestoreDialog(String backupPath, SettingsProvider settingsProvider) {
    final fileName = backupPath.split('/').last;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to restore from this backup?'),
            const SizedBox(height: 8),
            Text(
              fileName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will replace all your current data with the backup data.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
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
            text: 'Restore',
            onPressed: () async {
              Navigator.of(context).pop();
              await _restoreBackup(backupPath, settingsProvider);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(String backupPath, SettingsProvider settingsProvider) async {
    final success = await settingsProvider.restoreFromBackup(backupPath);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup restored successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to restore backup'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCloudSyncCard(SettingsProvider settingsProvider) {
    return AppCard(
      child: _isLoadingSyncStatus
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Cloud Sync',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (_syncStatus['isSyncing'] == true)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _syncStatus['lastSyncDate'] != null
                        ? 'Last sync: ${_formatSyncDate(_syncStatus['lastSyncDate'] as String?)}'
                        : 'Never synced',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSubtitle,
                    ),
                  ),
                  if ((_syncStatus['pendingChanges'] as int? ?? 0) > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_syncStatus['pendingChanges']} pending changes',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.waterFull,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Sync Settings',
                          onPressed: () => _showSyncSettingsDialog(settingsProvider),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Sync Now',
                          onPressed: (_syncStatus['isSyncing'] as bool? ?? false) == true 
                              ? null 
                              : () => _performManualSync(settingsProvider),
                          isLoading: (_syncStatus['isSyncing'] as bool? ?? false) == true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _formatSyncDate(String? dateString) {
    if (dateString == null) return 'Never';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _performManualSync(SettingsProvider settingsProvider) async {
    setState(() {
      _syncStatus['isSyncing'] = true;
    });

    final result = await settingsProvider.performManualSync();

    if (!mounted) return;

    setState(() {
      _syncStatus['isSyncing'] = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Sync completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadSyncStatus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Sync failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSyncSettingsDialog(SettingsProvider settingsProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sync settings will be available in a future update.'),
            SizedBox(height: 16),
            Text(
              'Features coming soon:\n• Auto sync frequency\n• WiFi-only sync\n• Conflict resolution',
              style: TextStyle(fontSize: 12),
            ),
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
