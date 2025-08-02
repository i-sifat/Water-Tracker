import 'package:flutter/material.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/widgets/drink_type_selector.dart';

/// Example screen to demonstrate DrinkTypeSelector widget
class DrinkTypeSelectorExample extends StatefulWidget {
  const DrinkTypeSelectorExample({super.key});

  @override
  State<DrinkTypeSelectorExample> createState() =>
      _DrinkTypeSelectorExampleState();
}

class _DrinkTypeSelectorExampleState extends State<DrinkTypeSelectorExample> {
  DrinkType _selectedDrinkType = DrinkType.water;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5), // Blue gradient background
      appBar: AppBar(
        title: const Text('Drink Type Selector Example'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Title
            const Text(
              'Select Your Drink Type',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Nunito',
              ),
            ),

            const SizedBox(height: 20),

            // Current selection info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Currently Selected: ${_selectedDrinkType.displayName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Water Content: ${(_selectedDrinkType.waterContent * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // DrinkTypeSelector widget
            DrinkTypeSelector(
              selectedType: _selectedDrinkType,
              onTypeChanged: (DrinkType newType) {
                setState(() {
                  _selectedDrinkType = newType;
                });

                // Show snackbar for feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${newType.displayName}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),

            const Spacer(),

            // Instructions
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tap the drink type selector above to choose from different beverage options. Each drink type has a different water content percentage.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
