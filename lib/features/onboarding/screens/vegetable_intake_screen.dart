import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/primary_button.dart';
import 'package:watertracker/features/onboarding/screens/sugary_drinks_screen.dart';

class VegetablesFruitsScreen extends StatefulWidget {
  const VegetablesFruitsScreen({Key? key}) : super(key: key);

  @override
  State<VegetablesFruitsScreen> createState() => _VegetablesFruitsScreenState();
}

class _VegetablesFruitsScreenState extends State<VegetablesFruitsScreen> {
  String _selectedFrequency = '';

  final List<Map<String, String>> _frequencies = [
    {'title': 'Rarely', 'subtitle': 'Few times a week', 'icon': '🥗'},
    {'title': 'Often', 'subtitle': 'Several per day', 'icon': '🥬'},
    {'title': 'Regularly', 'subtitle': 'Every day', 'icon': '🥦'},
  ];

  Future<void> _saveFrequency() async {
    if (_selectedFrequency.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vegetable_frequency', _selectedFrequency);
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
            icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
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
            child: const Text(
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vegetables',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlue,
                height: 1.2,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.separated(
                itemCount: _frequencies.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final frequency = _frequencies[index];
                  final isSelected = _selectedFrequency == frequency['title'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFrequency = frequency['title']!;
                      });
                    },
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.lightBlue.withOpacity(0.1)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.lightBlue
                                  : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.lightBlue.withOpacity(0.1)
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  frequency['icon']!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    frequency['title']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? AppColors.lightBlue
                                              : AppColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    frequency['subtitle']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
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
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Continue',
              onPressed:
                  _selectedFrequency.isNotEmpty
                      ? () async {
                        await _saveFrequency();
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const SugaryBeveragesScreen(),
                            ),
                          );
                        }
                      }
                      : () {},

              isDisabled: _selectedFrequency.isEmpty,
              rightIcon: const Icon(Icons.arrow_forward, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
