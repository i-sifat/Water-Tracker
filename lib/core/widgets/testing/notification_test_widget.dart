import 'package:flutter/material.dart';

import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/design_system/app_spacing.dart';
import 'package:watertracker/core/design_system/app_typography.dart';
import 'package:watertracker/core/services/notification_service.dart';

/// Widget for testing notification functionality and reliability
class NotificationTestWidget extends StatefulWidget {
  const NotificationTestWidget({super.key});

  @override
  State<NotificationTestWidget> createState() => _NotificationTestWidgetState();
}

class _NotificationTestWidgetState extends State<NotificationTestWidget> {
  final NotificationService _notificationService = NotificationService();

  Map<String, dynamic>? _permissionStatus;
  Map<String, dynamic>? _reliabilityStats;
  Map<String, dynamic>? _testResults;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    setState(() => _isLoading = true);

    try {
      await _notificationService.initialize();
      await _loadData();
    } catch (e) {
      _showError('Failed to initialize notification service: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    try {
      final permissionStatus =
          await _notificationService.areNotificationsEnabled();
      final reliabilityStats =
          await _notificationService.getReliabilityStatistics();

      setState(() {
        _permissionStatus = {'enabled': permissionStatus};
        _reliabilityStats = reliabilityStats;
      });
    } catch (e) {
      _showError('Failed to load notification data: $e');
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

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    try {
      final result = await _notificationService.requestPermissions(
        showGuidance: true,
      );

      if (result['granted'] == true) {
        _showSuccess(result['message'] ?? 'Permissions granted');
      } else {
        _showPermissionGuidance(result);
      }

      await _loadData();
    } catch (e) {
      _showError('Failed to request permissions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPermissionGuidance(Map<String, dynamic> result) {
    final guidance = result['guidance'] as Map<String, dynamic>?;
    if (guidance == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(guidance['title'] ?? 'Permission Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guidance['message'] ?? ''),
                const SizedBox(height: AppSpacing.md),
                if (guidance['steps'] != null) ...[
                  const Text(
                    'Steps:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...((guidance['steps'] as List<dynamic>).map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(step.toString())),
                        ],
                      ),
                    ),
                  )),
                ],
              ],
            ),
            actions: [
              if (result['canOpenSettings'] == true)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _notificationService.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              if (guidance['canRetry'] == true)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _requestPermissions();
                  },
                  child: const Text('Try Again'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _testDelivery() async {
    setState(() => _isLoading = true);

    try {
      final results = await _notificationService.testNotificationDelivery();
      setState(() => _testResults = results);

      if (results['success'] == true) {
        _showSuccess('Delivery test completed successfully');
      } else {
        _showError('Delivery test failed: ${results['error']}');
      }

      await _loadData();
    } catch (e) {
      _showError('Failed to run delivery test: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testPersistence() async {
    setState(() => _isLoading = true);

    try {
      final result = await _notificationService.testNotificationPersistence();

      if (result['success'] == true) {
        _showPersistenceInstructions(result);
      } else {
        _showError('Failed to start persistence test: ${result['error']}');
      }
    } catch (e) {
      _showError('Failed to start persistence test: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPersistenceInstructions(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Persistence Test Started'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Test ID: ${result['testId']}'),
                Text('Scheduled for: ${result['scheduledTime']}'),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...((result['instructions'] as List<dynamic>).map(
                  (instruction) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(instruction.toString())),
                      ],
                    ),
                  ),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _clearDebugData() async {
    try {
      await _notificationService.clearAllDebugData();
      _showSuccess('Debug data cleared');
      await _loadData();
    } catch (e) {
      _showError('Failed to clear debug data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearDebugData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPermissionSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildTestingSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildReliabilitySection(),
            const SizedBox(height: AppSpacing.lg),
            _buildTestResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection() {
    final isEnabled = _permissionStatus?['enabled'] ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notification Permissions',
                  style: AppTypography.headlineSmall,
                ),
                Icon(
                  isEnabled ? Icons.check_circle : Icons.error,
                  color: isEnabled ? AppColors.success : AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isEnabled
                  ? 'Notifications are enabled'
                  : 'Notifications are disabled',
              style: AppTypography.bodyMedium.copyWith(
                color: isEnabled ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (!isEnabled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                  child: const Text('Request Permissions'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Testing', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                    child: const Text('Test Delivery'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testPersistence,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                    child: const Text('Test Persistence'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _notificationService.showImmediateNotification(
                    title: 'Test Notification',
                    body: 'This is a test notification sent immediately',
                    payload: 'test_immediate',
                  );
                  _showSuccess('Immediate test notification sent');
                },
                child: const Text('Send Test Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReliabilitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reliability Statistics', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            if (_reliabilityStats != null) ...[
              _buildStatRow(
                'Permission Success Rate',
                '${((_reliabilityStats!['permissionStatistics']?['successRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
              ),
              _buildStatRow(
                'Delivery Success Rate',
                '${((_reliabilityStats!['deliveryStatistics']?['successRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
              ),
              _buildStatRow(
                'Total Permission Requests',
                '${_reliabilityStats!['permissionStatistics']?['totalRequests'] ?? 0}',
              ),
              _buildStatRow(
                'Total Deliveries',
                '${_reliabilityStats!['deliveryStatistics']?['totalDeliveries'] ?? 0}',
              ),
            ] else
              const Text('Loading statistics...'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            Text('Latest Test Results', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            if (_testResults != null) ...[
              Text('Test Started: ${_testResults!['testStarted'] ?? 'N/A'}'),
              Text(
                'Test Completed: ${_testResults!['testCompleted'] ?? 'N/A'}',
              ),
              Text('Success: ${_testResults!['success'] ?? false}'),
              const SizedBox(height: AppSpacing.sm),
              if (_testResults!['tests'] != null) ...[
                Text(
                  'Individual Tests:',
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
                          entry.value['sent'] == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              entry.value['sent'] == true
                                  ? AppColors.success
                                  : AppColors.error,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_testResults!['error'] != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Error: ${_testResults!['error']}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
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
}
