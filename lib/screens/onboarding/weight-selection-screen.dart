import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/screens/onboarding/height-selection-screen.dart';
import 'package:ruler_scale_picker/ruler_scale_picker.dart';

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

  // Colors
  final Color _primaryColor = const Color(0xFF7671FF);
  final Color _darkTextColor = const Color(0xFF323062);
  final Color _lightGrayColor = const Color(0xFFF0F0F0);
  final Color _mediumGrayColor = const Color(0xFFCDCDCD);

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
            icon: Icon(Icons.arrow_back, color: _darkTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Assessment',
          style: TextStyle(
            color: _darkTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _lightGrayColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '4 of 17',
              style: TextStyle(
                color: _darkTextColor,
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
                      color: _darkTextColor,
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
                          color: _darkTextColor,
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

                  // Ruler Scale Picker
                  _buildRulerScalePicker(),
                ],
              ),
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: ElevatedButton(
              onPressed: () {
                _saveWeight().then((_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HeightSelectionScreen(),
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
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
          color: isSelected ? _darkTextColor : _lightGrayColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : _darkTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRulerScalePicker() {
    // Determine min, max and intervals based on unit type
    final int minVal = _isKg ? 40 : 88; // 40kg or 88lbs
    final int maxVal = _isKg ? 150 : 330; // 150kg or 330lbs

    final List<int> majorTickValues = [];

    // Create tick values at appropriate intervals
    if (_isKg) {
      for (int i = minVal; i <= maxVal; i += 5) {
        majorTickValues.add(i);
      }
    } else {
      for (int i = minVal; i <= maxVal; i += 10) {
        majorTickValues.add(i);
      }
    }

    return SizedBox(
      height: 150,
      child: RulerScalePicker(
        controller: RulerScalePickerController(
          initialValue: _weight,
          minValue: _minWeight,
          maxValue: _maxWeight,
        ),
        onValueChange: (value) {
          setState(() {
            _weight = value;
          });
          HapticFeedback.selectionClick();
        },
        scaleLineStyleList: [
          ScaleLineStyle(
            height: 50,
            color: _mediumGrayColor,
            width: 1.0,
            showValue: false,
            valueTextStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            offset: 5,
          ),
          ScaleLineStyle(
            height: 30,
            color: _mediumGrayColor,
            width: 1.0,
            showValue: false,
          ),
          ScaleLineStyle(
            height: 20,
            color: _mediumGrayColor,
            width: 1.0,
            showValue: false,
          ),
          ScaleLineStyle(
            height: 20,
            color: _mediumGrayColor,
            width: 1.0,
            showValue: false,
          ),
          ScaleLineStyle(
            height: 30,
            color: _mediumGrayColor,
            width: 1.0,
            showValue: false,
          ),
        ],
        majorTickValues: majorTickValues,
        indicator: Container(
          width: 3,
          height: 100,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        interval: 1.0,
        width: MediaQuery.of(context).size.width - 40,
        tickLabelOffset: const Offset(0, 15),
        tickLabelBuilder: (value, i) {
          // Only show labels for major ticks
          if (majorTickValues.contains(value.toInt())) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
