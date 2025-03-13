import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/core/widgets/custom_ruler_picker.dart';
import 'package:watertracker/features/onboarding/screens/exercise_frequency_screen.dart';

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool _isKg = true;
  double _weight = 65;
  final double _minWeightKg = 1;
  final double _maxWeightKg = 150;

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
      final newWeight =
          _isKg ? _convertKgToLbs(_weight) : _convertLbsToKg(_weight);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.assessmentText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('Assessment', style: AppTypography.subtitle),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '4 of 10',
              style: TextStyle(
                color: AppColors.pageCounter,
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "What's your current\nweight right now?",
                    style: AppTypography.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),

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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _isKg
                            ? _weight.toStringAsFixed(1)
                            : _weight.round().toString(),
                        style: AppTypography.headline.copyWith(fontSize: 89),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isKg ? 'kg' : 'lbs',
                        style: AppTypography.subtitle.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

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

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: ContinueButton(
              onPressed: () {
                _saveWeight().then((_) {
                  // context.read<OnboardingProvider>().nextPage();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FitnessLevelScreen(),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String unit, bool isKg) {
    final isSelected = _isKg == isKg;

    return GestureDetector(
      onTap: () => _handleUnitChange(isKg),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedBorder : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.assessmentText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
