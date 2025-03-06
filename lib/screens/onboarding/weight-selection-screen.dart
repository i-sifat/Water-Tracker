import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/screens/onboarding/height-selection-screen.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:watertracker/widgets/custom_ruler_picker.dart';
import 'package:watertracker/widgets/primary_button.dart';

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool _isKg = true;
  double _weight = 65.0;
  final double _minWeightKg = 1.0;
  final double _maxWeightKg = 150.0;

  @override
  void initState() {
    super.initState();
    _loadSavedWeight();
  }

  Future<void> _loadSavedWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnit = prefs.getBool('weight_unit_is_kg') ?? true;
    final savedWeight = prefs.getDouble('user_weight') ?? 65.0;

    setState(() {
      _isKg = savedUnit;
      _weight = _clampWeight(savedWeight, savedUnit);
    });
  }

  double _convertKgToLbs(double kg) => kg * 2.20462;
  double _convertLbsToKg(double lbs) => lbs / 2.20462;

  double _clampWeight(double value, bool isKg) {
    final min = isKg ? _minWeightKg : _convertKgToLbs(_minWeightKg);
    final max = isKg ? _maxWeightKg : _convertKgToLbs(_maxWeightKg);
    return value.clamp(min, max);
  }

  Future<void> _saveWeight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_weight', _weight);
    await prefs.setBool('weight_unit_is_kg', _isKg);
  }

  void _handleUnitChange(bool isKg) {
    if (_isKg == isKg) return;

    setState(() {
      // Convert weight directly between units
      final newWeight =
          _isKg ? _convertKgToLbs(_weight) : _convertLbsToKg(_weight);

      // Apply clamping after conversion
      _weight = _clampWeight(newWeight, isKg);
      _isKg = isKg;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final minValue = _isKg ? _minWeightKg : _convertKgToLbs(_minWeightKg);
    final maxValue = _isKg ? _maxWeightKg : _convertKgToLbs(_maxWeightKg);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Assessment',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '4 of 17',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "What's your current\nweight right now?",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlue,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),

                  // Unit selection toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildUnitButton('kg', true),
                        const SizedBox(width: 8),
                        _buildUnitButton('lbs', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Weight display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _isKg
                            ? _weight.toStringAsFixed(1)
                            : _weight.round().toString(),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 89,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isKg ? 'kg' : 'lbs',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Ruler picker
                  CustomRulerPicker(
                    value: _weight,
                    minValue: minValue,
                    maxValue: maxValue,
                    isKg: _isKg,
                    onValueChanged: (value) {
                      setState(() => _weight = value);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: PrimaryButton(
              text: 'Continue',
              onPressed: () {
                _saveWeight().then((_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HeightSelectionScreen(),
                    ),
                  );
                });
              },
              rightIcon: const Icon(Icons.arrow_forward, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String unit, bool isKg) {
    final bool isSelected = _isKg == isKg;

    return GestureDetector(
      onTap: () => _handleUnitChange(isKg),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
