import 'package:flutter/material.dart';
import 'weight-selection-screen.dart';
import 'custom-button.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({Key? key}) : super(key: key);

  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  final List<int> _ages = [17, 18, 19, 20, 21];
  int? _selectedAge;

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
            value: 3 / 17, // Third step of 17
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
              "What's your Age?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ages.length,
                itemBuilder: (context, index) {
                  final age = _ages[index];
                  final isSelected = _selectedAge == age;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAge = age;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF8E97FD)
                                : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '$age',
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Continue',
              isEnabled: _selectedAge != null,
              onPressed:
                  _selectedAge != null
                      ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WeightSelectionScreen(),
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
}
