import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/buttons/secondary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/settings/providers/settings_provider.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  Map<String, dynamic> _storageStats = {};
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
  }

  Future<void> _loadStorageStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final stats = await settingsProvider.getStorageStats();

    if (mounted) {
      setState(() {
        _storageStats = stats;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Data Management',
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Storage Information
                const Text(
                  'Storage Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                AppCard(
                  child: _isLoadingStats
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatRow('Regular Keys', '${_storageStats['regular_keys_count'] ?? 0}'),
                              const SizedBox(height: 8),
                              _buildStatRow('Encrypted Keys', '${_storageStats['encrypted_keys_count'] ?? 0}'),
                              const SizedBox(height: 8),
                              _buildStatRow('Storage Version', (_storageStats['storage_version'] as String?) ?? 'Unknown'),
                              const SizedBox(height: 16),
                              SecondaryButton(
                                text: 'Refresh Stats',
                                onPressed: _loadStorageStats,
                              ),
                            ],
                          ),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // Data Export (Premium)
                const Text(
                  'Data Export',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                PremiumGate(
                  feature: PremiumFeature.dataExport,
                  lockedChild: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Export Your Data',
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
                            'Premium feature - Export all your data in JSON format',
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
                  child: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Export Your Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Export all your data in JSON format',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSubtitle,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  text: 'Export JSON',
                                  onPressed: () => _exportData(settingsProvider, 'json'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PrimaryButton(
                                  text: 'Export CSV',
                                  onPressed: () => _exportData(settingsProvider, 'csv'),
                                  isLoading: settingsProvider.isLoading,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Data Retention
                const Text(
                  'Data Retention',
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
                          'Data Retention Period',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keep data for ${settingsProvider.dataManagement.dataRetentionDays} days',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSubtitle,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SecondaryButton(
                          text: 'Change Retention Period',
                          onPressed: () => _showRetentionDialog(settingsProvider),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Danger Zone
                const Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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
                          'Clear All Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This will permanently delete all your data. This action cannot be undone.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSubtitle,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SecondaryButton(
                          text: 'Clear All Data',
                          onPressed: () => _showClearDataDialog(settingsProvider),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSubtitle,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _exportData(SettingsProvider settingsProvider, String format) async {
    final dataTypes = settingsProvider.getAvailableDataTypes();
    final filePath = await settingsProvider.exportDataWithFormat(
      dataTypes: dataTypes,
      format: format,
    );

    if (!mounted) return;

    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported to: ${filePath.split('/').last}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Share',
            onPressed: () {
              // In a real app, you would use share_plus package
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRetentionDialog(SettingsProvider settingsProvider) {
    final controller = TextEditingController();
    controller.text = settingsProvider.dataManagement.dataRetentionDays.toString();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Retention Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days',
                border: OutlineInputBorder(),
                helperText: 'Number of days to keep data (1-3650)',
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
              final days = int.tryParse(controller.text);
              if (days != null && days > 0 && days <= 3650) {
                settingsProvider.updateDataRetention(days);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(SettingsProvider settingsProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: Colors.red),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to clear all data?'),
            SizedBox(height: 16),
            Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• All hydration records'),
            Text('• User profile information'),
            Text('• App preferences'),
            Text('• Notification settings'),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
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
            text: 'Clear All Data',
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData(settingsProvider);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(SettingsProvider settingsProvider) async {
    final success = await settingsProvider.clearAllData();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadStorageStats();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to clear data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
