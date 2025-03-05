import 'package:flutter/material.dart';
import 'package:watertracker/screens/onboarding/custom-button.dart';
import 'package:watertracker/screens/onboarding/training-frequency-screen.dart';
import 'package:watertracker/utils/app_colors.dart';

class SugaryBeveragesScreen extends StatefulWidget {
  const SugaryBeveragesScreen({Key? key}) : super(key: key);

  @override
  _SugaryBeveragesScreenState createState() => _SugaryBeveragesScreenState();
}

class _SugaryBeveragesScreenState extends State<SugaryBeveragesScreen> {
  int _selectedOption = 0; // Default to first option

  final List<Map<String, Object>> _beverageOptions = [
    {
      'title': 'Almost never',
      'subtitle': 'Never / several times a month',
      'icon': Icons.local_drink,
    },
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': Icons.local_cafe,
    },
    {'title': 'Regularly', 'subtitle': 'Every day', 'icon': Icons.local_bar},
    {
      'title': 'Often',
      'subtitle': 'Several per day',
      'icon': Icons.local_drink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Sugary Beverages',
          style: TextStyle(color: AppColors.darkBlue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We will calculate the daily water goal individually for you',
              style: TextStyle(color: AppColors.textSubtitle, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _beverageOptions.length,
                itemBuilder: (context, index) {
                  final option = _beverageOptions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedOption = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _selectedOption == index
                                  ? AppColors.lightBlue
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              option['icon'] as IconData,
                              color:
                                  _selectedOption == index
                                      ? Colors.white
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['title'] as String,
                                    style: TextStyle(
                                      color:
                                          _selectedOption == index
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    option['subtitle'] as String,
                                    style: TextStyle(
                                      color:
                                          _selectedOption == index
                                              ? Colors.white70
                                              : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Next',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TrainingFrequencyScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.lightBlue,
            ),
          ],
        ),
      ),
    );
  }
}
