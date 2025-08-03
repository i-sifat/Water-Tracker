import 'package:flutter/material.dart';

import 'package:watertracker/core/services/vibration_service.dart';
import 'package:watertracker/core/widgets/testing/vibration_test_widget.dart';

/// Simple test app to verify vibration functionality on real devices
class VibrationTestApp extends StatelessWidget {
  const VibrationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibration Test',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const VibrationTestScreen(),
    );
  }
}

class VibrationTestScreen extends StatefulWidget {
  const VibrationTestScreen({super.key});

  @override
  State<VibrationTestScreen> createState() => _VibrationTestScreenState();
}

class _VibrationTestScreenState extends State<VibrationTestScreen> {
  final VibrationService _vibrationService = VibrationService();
  Map<String, bool?> _capabilities = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVibration();
  }

  Future<void> _initializeVibration() async {
    await _vibrationService.initialize();
    final capabilities = _vibrationService.getCapabilities();
    setState(() {
      _capabilities = capabilities;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibration Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isInitialized ? _buildTestInterface() : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildTestInterface() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCapabilitiesCard(),
          const SizedBox(height: 16),
          _buildQuickTestCard(),
          const SizedBox(height: 16),
          _buildFullTestButton(),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Capabilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCapabilityRow('Has Vibrator', _capabilities['hasVibrator']),
            _buildCapabilityRow(
              'Has Amplitude Control',
              _capabilities['hasAmplitudeControl'],
            ),
            _buildCapabilityRow(
              'Has Custom Vibrations',
              _capabilities['hasCustomVibrationsSupport'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityRow(String label, bool? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            value == true ? Icons.check_circle : Icons.cancel,
            color: value == true ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Light',
                        _vibrationService.lightHaptic,
                      ),
                  child: const Text('Light'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Medium',
                        _vibrationService.mediumHaptic,
                      ),
                  child: const Text('Medium'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _testVibration(
                        'Heavy',
                        _vibrationService.heavyHaptic,
                      ),
                  child: const Text('Heavy'),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Error'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const VibrationTestWidget(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Open Full Test Suite'),
      ),
    );
  }

  Future<void> _testVibration(
    String type,
    Future<bool> Function() vibrationFunction,
  ) async {
    try {
      final success = await vibrationFunction();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '$type vibration executed successfully'
                  : '$type vibration failed or is disabled',
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error testing $type vibration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Entry point for the vibration test app
void main() {
  runApp(const VibrationTestApp());
}
