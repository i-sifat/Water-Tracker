import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/core/widgets/cards/selection_box.dart';
import 'package:watertracker/features/onboarding/screens/gender_selection_screen.dart';

class VegetablesFruitsScreen extends StatefulWidget {
  const VegetablesFruitsScreen({super.key});

  @override
  State<VegetablesFruitsScreen> createState() => _VegetablesFruitsScreenState();
}

class _VegetablesFruitsScreenState extends State<VegetablesFruitsScreen> {
  String _selectedFrequency = '';

  final List<Map<String, dynamic>> _frequencies = [
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': Icons.eco,
      'emoji': '🥗',
    },
    {
      'title': 'Often',
      'subtitle': 'Several per day',
      'icon': Icons.local_florist,
      'emoji': '🥬',
    },
    {
      'title': 'Regularly',
      'subtitle': 'Every day',
      'icon': Icons.grass,
      'emoji': '🥦',
    },
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
      backgroundColor: AppColors.onBoardingpagebackground,
      appBar: AppBar(
        backgroundColor: AppColors.onBoardingpagebackground,
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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '7 of 10',
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
        padding: const EdgeInsets.all(24),
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
                    title: '${frequency['emoji']} ${frequency['title']}',
                    subtitle: frequency['subtitle'] as String?,
                    icon: frequency['icon'] as IconData,
                    isSelected: _selectedFrequency == frequency['title'],
                    onTap: () {
                      setState(() {
                        _selectedFrequency = frequency['title'] as String;
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
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const GenderSelectionScreen(),
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
