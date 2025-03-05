import 'package:flutter/material.dart';
import 'package:watertracker/screens/onboarding/custom-button.dart';
import 'package:watertracker/screens/onboarding/vegetables-fruits-screen.dart';
import 'package:watertracker/utils/app_colors.dart';

class TrainingFrequencyScreen extends StatefulWidget {
  const TrainingFrequencyScreen({Key? key}) : super(key: key);

  @override
  _TrainingFrequencyScreenState createState() =>
      _TrainingFrequencyScreenState();
}

class _TrainingFrequencyScreenState extends State<TrainingFrequencyScreen> {
  int _selectedFrequency = 1; // Default to middle option

  final List<Map<String, Object>> _frequencyOptions = [
    {
      'title': 'Rarely',
      'subtitle': 'No workouts',
      'icon': Icons.sports_soccer,
    },
    {
      'title': 'Regularly',
      'subtitle': '2-3 times a week',
      'icon': Icons.fitness_center,
    },
    {
      'title': 'Often',
      'subtitle': 'Almost every day',
      'icon': Icons.sports,
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
          'Training Frequency',
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
                itemCount: _frequencyOptions.length,
                itemBuilder: (context, index) {
                  final option = _frequencyOptions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFrequency = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _selectedFrequency == index
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
                                  _selectedFrequency == index
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
                                          _selectedFrequency == index
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
                                          _selectedFrequency == index
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
                    builder: (context) => const VegetablesFruitsScreen(),
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