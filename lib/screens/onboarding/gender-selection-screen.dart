import 'package:flutter/material.dart';
import 'package:watertracker/screens/onboarding/age-selection-screen.dart';
import 'package:watertracker/screens/onboarding/custom-button.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({Key? key}) : super(key: key);

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

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
            value: 2 / 17, // Second step of 17
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
              'Select your Gender',
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
                _buildGenderOption(
                  icon: Icons.male,
                  text: 'I am Male',
                  color:
                      _selectedGender == 'male'
                          ? const Color(0xFF8E97FD)
                          : Colors.grey.shade200,
                  textColor:
                      _selectedGender == 'male' ? Colors.white : Colors.black,
                  onTap: () => setState(() => _selectedGender = 'male'),
                ),
                const SizedBox(width: 16),
                _buildGenderOption(
                  icon: Icons.female,
                  text: 'I am Female',
                  color:
                      _selectedGender == 'female'
                          ? const Color(0xFF8E97FD)
                          : Colors.grey.shade200,
                  textColor:
                      _selectedGender == 'female' ? Colors.white : Colors.black,
                  onTap: () => setState(() => _selectedGender = 'female'),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Handle "Prefer not to answer"
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AgeSelectionScreen(),
                  ),
                );
              },
              child: const Text(
                'Prefer not to answer',
                style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Continue',
              isEnabled: _selectedGender != null,
              onPressed:
                  _selectedGender != null
                      ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AgeSelectionScreen(),
                          ),
                        );
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption({
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: textColor),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
