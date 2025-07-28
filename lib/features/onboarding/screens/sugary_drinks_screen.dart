import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/core/widgets/cards/selection_box.dart';
import 'package:watertracker/features/onboarding/screens/pregnancy_status_screen.dart';

class SugaryBeveragesScreen extends StatefulWidget {
  const SugaryBeveragesScreen({super.key});

  @override
  State<SugaryBeveragesScreen> createState() => _SugaryBeveragesScreenState();
}

class _SugaryBeveragesScreenState extends State<SugaryBeveragesScreen> {
  String _selectedFrequency = '';

  final List<Map<String, dynamic>> _frequencies = [
    {
      'title': 'Almost never',
      'subtitle': 'Never / several times a month',
      'icon': Icons.block,
      'emoji': '🚫',
      'value': 'almost_never',
      'iconBgColor': const Color(0xFFF2F2F2),
    },
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': Icons.local_drink,
      'emoji': '🥤',
      'value': 'rarely',
      'iconBgColor': const Color(0xFFF2F2F2),
    },
    {
      'title': 'Regularly',
      'subtitle': 'Every day',
      'icon': Icons.local_cafe,
      'emoji': '🧃',
      'value': 'regularly',
      'iconBgColor': const Color(0xFFF2F2F2),
    },
  ];

  Future<void> _saveFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sugary_beverages_frequency', _selectedFrequency);
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
              '8 of 10',
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
            const Text('Sugary Beverages', style: AppTypography.headline),
            const SizedBox(height: 8),
            const Text(
              'Select your habit.',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.pageCounter,
                fontWeight: FontWeight.w400,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: _frequencies.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final frequency = _frequencies[index];
                  return SelectionBox(
                    title: '${frequency['emoji']} ${frequency['title']}',
                    subtitle: frequency['subtitle'] as String,
                    icon: frequency['icon'] as IconData,
                    isSelected: _selectedFrequency == frequency['value'],
                    onTap: () {
                      setState(() {
                        _selectedFrequency = frequency['value'] as String;
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
                              builder: (context) => const PregnancyScreen(),
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
