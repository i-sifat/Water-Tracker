import 'package:flutter/material.dart';
import 'package:watertracker/screens/onboarding/custom-button.dart';
import 'package:watertracker/utils/app_colors.dart';

class CoffeeEnergyDrinksScreen extends StatefulWidget {
  const CoffeeEnergyDrinksScreen({Key? key}) : super(key: key);

  @override
  _CoffeeEnergyDrinksScreenState createState() =>
      _CoffeeEnergyDrinksScreenState();
}

class _CoffeeEnergyDrinksScreenState extends State<CoffeeEnergyDrinksScreen> {
  int _selectedOption = 0; // Default to first option

  final List<Map<String, dynamic>> _coffeeOptions = [
    {
      'title': 'Almost never',
      'subtitle': 'Never / several times a month',
      'icon': Icons.coffee,
    },
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': Icons.local_cafe,
    },
    {'title': 'Regularly', 'subtitle': 'Every day', 'icon': Icons.local_drink},
    {
      'title': 'Often',
      'subtitle': 'Several per day',
      'icon': Icons.local_cafe_outlined,
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
          'Coffee and Energy Drinks',
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
                itemCount: _coffeeOptions.length,
                itemBuilder: (context, index) {
                  final option = _coffeeOptions[index];
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
                              option['icon'],
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
                                    option['title'],
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
                                    option['subtitle'],
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
                    builder: (context) => const SugaryBeveragesScreen(),
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
