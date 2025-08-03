import 'package:flutter/material.dart';

import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/design_system/app_spacing.dart';
import 'package:watertracker/core/design_system/app_typography.dart';
import 'package:watertracker/core/services/vibration_service.dart';

/// Widget for testing vibration and haptic feedback functionality
class VibrationTestWidget extends StatefulWidget {
  const VibrationTestWidget({super.key});

  @override
  State<VibrationTestWidget> createState() => _VibrationTestWidgetState();
}

class _VibrationTestWidgetState extends State<VibrationTestWidget> {
  final VibrationService _vibrationService = VibrationService();

  Map<String, dynamic>? _capabilities;
  Map<String, dynamic>? _settings;
  Map<String, dynamic>? _testResults;
  List<Map<String, dynamic>> _eventLogs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeVibrationService();
  }

  Future<void> _initializeVibrationService() async {
    setState(() => _isLoading = true);

    try {
      await _vibrationService.initialize();
      await _loadData();
    } catch (e) {
      _showError('Failed to initialize vibration service: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    try {
      final capabilities = _vibrationService.getCapabilities();
      final settings = await _vibrationService.getVibrationSettings();
      final testResults = await _vibrationService.getTestResults();
      final eventLogs = await _vibrationService.getEventLogs(limit: 10);

      setState(() {
        _capabilities = capabilities;
        _settings = settings;
        _testResults = testResults;
        _eventLogs = eventLogs;
      });
    } catch (e) {
      _showError('Failed to load vibration data: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _testVibration(
    String type,
    Future<bool> Function() vibrationFunction,
  ) async {
    try {
      final success = await vibrationFunction();
      if (success) {
        _showSuccess('$type vibration executed successfully');
      } else {
        _showError('$type vibration failed or is disabled');
      }
      await _loadData(); // Refresh logs
    } catch (e) {
      _showError('Error testing $type vibration: $e');
    }
  }

  Future<void> _runAllTests() async {
    setState(() => _isLoading = true);

    try {
      final results = await _vibrationService.testAllVibrationTypes();
      _showSuccess('All vibration tests completed');
      await _loadData();
    } catch (e) {
      _showError('Failed to run all tests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runCompatibilityTest() async {
    setState(() => _isLoading = true);

    try {
      final results = await _vibrationService.testDeviceCompatibility();
      _showSuccess('Device compatibility test completed');
      await _loadData();
    } catch (e) {
      _showError('Failed to run compatibility test: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleVibrationEnabled() async {
    try {
      final currentSettings = _settings ?? {};
      final newEnabled = !(currentSettings['enabled'] ?? true);

      await _vibrationService.updateVibrationSettings(enabled: newEnabled);
      _showSuccess('Vibration ${newEnabled ? 'enabled' : 'disabled'}');
      await _loadData();
    } catch (e) {
      _showError('Failed to toggle vibration: $e');
    }
  }

  Future<void> _clearLogs() async {
    try {
      await _vibrationService.clearEventLogs();
      await _vibrationService.clearTestResults();
      _showSuccess('Logs and test results cleared');
      await _loadData();
    } catch (e) {
      _showError('Failed to clear logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibration Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.clear_all), onPressed: _clearLogs),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCapabilitiesSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildTestButtonsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildTestResultsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildEventLogsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilitiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device Capabilities', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            if (_capabilities != null) ...[
              _buildCapabilityRow(
                'Has Vibrator',
                _capabilities!['hasVibrator'],
              ),
              _buildCapabilityRow(
                'Has Amplitude Control',
                _capabilities!['hasAmplitudeControl'],
              ),
              _buildCapabilityRow(
                'Has Custom Vibrations',
                _capabilities!['hasCustomVibrationsSupport'],
              ),
            ] else
              const Text('Loading capabilities...'),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityRow(String label, bool? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            value == true ? Icons.check_circle : Icons.cancel,
            color: value == true ? AppColors.success : AppColors.error,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vibration Settings', style: AppTypography.headlineSmall),
                Switch(
                  value: _settings?['enabled'] ?? true,
                  onChanged: (_) => _toggleVibrationEnabled(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_settings != null) ...[
              _buildSettingRow(
                'Intensity',
                _settings!['intensity'] ?? 'medium',
              ),
              _buildSettingRow(
                'Notification Vibration',
                _settings!['notificationVibration'],
              ),
              _buildSettingRow('Button Feedback', _settings!['buttonFeedback']),
              _buildSettingRow(
                'Success Feedback',
                _settings!['successFeedback'],
              ),
              _buildSettingRow('Error Feedback', _settings!['errorFeedback']),
            ] else
              const Text('Loading settings...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtonsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vibration Tests', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Light',
                        _vibrationService.lightHaptic,
                      ),
                  child: const Text('Light Haptic'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Medium',
                        _vibrationService.mediumHaptic,
                      ),
                  child: const Text('Medium Haptic'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Heavy',
                        _vibrationService.heavyHaptic,
                      ),
                  child: const Text('Heavy Haptic'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Selection',
                        _vibrationService.selectionHaptic,
                      ),
                  child: const Text('Selection'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Notification',
                        _vibrationService.notificationVibration,
                      ),
                  child: const Text('Notification'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Success',
                        _vibrationService.successVibration,
                      ),
                  child: const Text('Success'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Error',
                        _vibrationService.errorVibration,
                      ),
                  child: const Text('Error'),
                ),
                ElevatedButton(
                  onPressed: _vibrationService.cancelVibration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runAllTests,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                    child: const Text('Run All Tests'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runCompatibilityTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                    child: const Text('Compatibility Test'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test Results', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            if (_testResults != null) ...[
              Text('Test Started: ${_testResults!['testStarted'] ?? 'N/A'}'),
              Text(
                'Test Completed: ${_testResults!['testCompleted'] ?? 'N/A'}',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_testResults!['tests'] != null) ...[
                Text(
                  'Individual Test Results:',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...(_testResults!['tests'] as Map<String, dynamic>).entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      top: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Icon(
                          entry.value == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              entry.value == true
                                  ? AppColors.success
                                  : AppColors.error,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ] else
              const Text('No test results available'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventLogsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Event Logs (Last 10)',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_eventLogs.isNotEmpty) ...[
              ..._eventLogs.map((log) => _buildLogEntry(log)),
            ] else
              const Text('No event logs available'),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(Map<String, dynamic> log) {
    final timestamp = DateTime.tryParse(log['timestamp'] ?? '');
    final timeString = timestamp?.toString().substring(11, 19) ?? 'Unknown';

    Color statusColor;
    switch (log['status']) {
      case 'success':
        statusColor = AppColors.success;
        break;
      case 'error':
        statusColor = AppColors.error;
        break;
      case 'failed':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.left(color: statusColor, width: 3),
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log['eventType'] ?? 'Unknown',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timeString,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (log['details'] != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(log['details'], style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}
