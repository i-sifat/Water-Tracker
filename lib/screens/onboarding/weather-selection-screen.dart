import 'package:flutter/material.dart';
import 'package:watertracker/screens/onboarding/custom-button.dart';
import 'package:watertracker/utils/app_colors.dart';

class WeatherSelectionScreen extends StatefulWidget {
  const WeatherSelectionScreen({Key? key}) : super(key: key);

  @override
  _WeatherSelectionScreenState createState() => _WeatherSelectionScreenState();
}

class _WeatherSelectionScreenState extends State<WeatherSelectionScreen> {
  int _selectedWeather = 1; // Default to middle option

  final List<Map<String, dynamic>> _weatherOptions = [
    {
      'title': 'Cold',
      'subtitle': 'Few sunny days, rainy',
      'icon': Icons.cloudy_snowing,
    },
    {
      'title': 'Normal',
      'subtitle': 'Temperate climate (default)',
      'icon': Icons.wb_sunny_outlined,
    },
    {
      'title': 'Hot',
      'subtitle': 'Lots of sunny and hot days',
      'icon': Icons.wb_sunny,
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
        title: Text('Weather', style: TextStyle(color: AppColors.darkBlue)),
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
                itemCount: _weatherOptions.length,
                itemBuilder: (context, index) {
                  final option = _weatherOptions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedWeather = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              _selectedWeather == index
                                  ? AppColors.lightBlue
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              option['icon'],
                              color:
                                  _selectedWeather == index
                                      ? Colors.white
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['title'],
                                    style: TextStyle(
                                      color:
                                          _selectedWeather == index
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    option['subtitle'],
                                    style: TextStyle(
                                      color:
                                          _selectedWeather == index
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
                    builder: (context) => const CoffeeEnergyDrinksScreen(),
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
