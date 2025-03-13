import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/core/widgets/selection_box.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.assessmentText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('Assessment', style: AppTypography.subtitle),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '6 of 10',
              style: TextStyle(
                color: AppColors.pageCounter,
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
            const Text('Vegetables', style: AppTypography.headline),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.separated(
                itemCount: _frequencies.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final frequency = _frequencies[index];
                  return SelectionBox(
                    title: frequency['title']!,
                    subtitle: frequency['subtitle']!,
                    icon: Text(
                      frequency['icon']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    isSelected: _selectedFrequency == frequency['title'],
                    onTap: () {
                      setState(() {
                        _selectedFrequency = frequency['title']!;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ContinueButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
