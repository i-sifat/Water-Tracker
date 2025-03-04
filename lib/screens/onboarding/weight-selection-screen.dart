import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({Key? key}) : super(key: key);

  @override
  _WeightSelectionScreenState createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  bool _isKg = true;
  double _weight = 65.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Assessment'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 4 / 17, // Fourth step of 17
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8E97FD)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "What's your current weight right now?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUnitButton('kg', _isKg),
                const SizedBox(width: 16),
                _buildUnitButton('lbs', !_isKg),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '${_weight.toStringAsFixed(0)}${_isKg ? 'kg' : 'lbs'}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF8E97FD),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: const Color(0xFF8E97FD),
                overlayColor: const Color(0xFF8E97FD).withOpacity(0.2),
              ),
              child: Slider(
                value: _weight,
                min: 40,
                max: 150,
                divisions: 110,
                label: _weight.toStringAsFixed(0),
                onChanged: (double value) {
                  setState(() {
                    _weight = value;
                  });
                },
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Continue',
              onPressed: () {
                // Navigate to next screen or process the data
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitButton(String unit, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isKg = unit == 'kg';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8E97FD) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
