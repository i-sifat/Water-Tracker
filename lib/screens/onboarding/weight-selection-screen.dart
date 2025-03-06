import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/screens/onboarding/height-selection-screen.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:watertracker/widgets/primary_button.dart';
import 'package:simple_ruler_picker/simple_ruler_picker.dart';

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({Key? key}) : super(key: key);

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool _isKg = true;
  double _weight = 65.0;
  final double _minWeight = 40.0;
  final double _maxWeight = 150.0;

  @override
  void initState() {
    super.initState();
    _loadSavedWeight();
  }

  // Load saved weight if available
  Future<void> _loadSavedWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWeight = prefs.getDouble('user_weight');
    final savedUnit = prefs.getBool('weight_unit_is_kg');

    if (savedWeight != null) {
      setState(() {
        _weight = savedWeight;
      });
    }

    if (savedUnit != null) {
      setState(() {
        _isKg = savedUnit;
      });
    }
  }

  // Save weight and unit selection
  Future<void> _saveWeight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_weight', _weight);
    await prefs.setBool('weight_unit_is_kg', _isKg);
  }

  // Convert weight between kg and lbs
  void _convertWeight() {
    if (_isKg) {
      // Convert lbs to kg
      _weight = (_weight / 2.20462).clamp(_minWeight, _maxWeight);
    } else {
      // Convert kg to lbs
      _weight = (_weight * 2.20462).clamp(_minWeight, _maxWeight);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.arrow_back, color: AppColors.darkBlue),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
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
            child: Text(
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
                  // Title
                  Text(
                    "What's your current\nweight right now?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeadline,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),

                  // Unit selection buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildUnitButton('kg', true),
                      const SizedBox(width: 16),
                      _buildUnitButton('lbs', false),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Weight display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _weight.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isKg ? 'kg' : 'lbs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Simple Ruler Picker
                  _buildSimpleRulerPicker(),
                ],
              ),
            ),
          ),

          // Continue button using PrimaryButton component
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
    final bool isSelected = (isKg && _isKg) || (!isKg && !_isKg);

    return GestureDetector(
      onTap: () {
        if ((isKg && !_isKg) || (!isKg && _isKg)) {
          setState(() {
            _isKg = isKg;
            _convertWeight();
          });
          HapticFeedback.lightImpact();
        }
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(28),
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

  Widget _buildSimpleRulerPicker() {
    // Calculate weight range based on unit
    final double min = _isKg ? 40.0 : 88.0;
    final double max = _isKg ? 150.0 : 330.0;

    return Container(
      height: 150,
      width: double.infinity,
      child: SimpleRulerPicker(
        value: _weight,
        minValue: min,
        maxValue: max,
        onValueChange: (value) {
          setState(() {
            _weight = value;
          });
          HapticFeedback.selectionClick();
        },
        activeLineColor: AppColors.lightBlue,
        indicatorColor: AppColors.lightBlue,
        indicatorWidth: 3,
        lineColor: Colors.grey.shade300,
        textStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
        showLabel: (i) => i % (_isKg ? 5 : 10) == 0,
        interval: 1,
        longLineInterval: _isKg ? 5 : 10,
        shortLineInterval: 1,
        longLineHeight: 40,
        shortLineHeight: 20,
        initialValue: _weight,
      ),
    );
  }
}
