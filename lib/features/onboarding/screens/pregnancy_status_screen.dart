import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/features/onboarding/screens/weather_preference_screen.dart';

import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/widgets/large_selection_box.dart';
import 'package:watertracker/core/widgets/prefer_not_to_answer_button.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  String? _selectedOption;

  final List<Map<String, String>> _options = [
    {
      'title': 'Pregnancy',
      'subtitle': 'Few times a week',
      'value': 'pregnancy',
      'icon': '🤰',
    },
    {
      'title': 'Breastfeeding',
      'subtitle': 'Several per day',
      'value': 'breastfeeding',
      'icon': '🍼',
    },
  ];

  Future<void> _saveSelection() async {
    if (_selectedOption != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pregnancy_status', _selectedOption!);
    }
  }

  void _handleContinue() {
    _saveSelection().then((_) {
      context.read<OnboardingProvider>().nextPage();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const WeatherSelectionScreen()),
      );
    });
  }

  void _handlePreferNotToAnswer() {
    setState(() => _selectedOption = 'none');
    _handleContinue();
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pregnancy/Breast\nfeed', style: AppTypography.headline),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.separated(
                itemCount: _options.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return LargeSelectionBox(
                    title: option['title']!,
                    subtitle: option['subtitle']!,
                    icon: Text(
                      option['icon']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    isSelected: _selectedOption == option['value'],
                    onTap: () {
                      setState(() {
                        _selectedOption = option['value'];
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            PreferNotToAnswerButton(onPressed: _handlePreferNotToAnswer),
            const SizedBox(height: 16),
            ContinueButton(
              onPressed: _selectedOption != null ? _handleContinue : () {},
              isDisabled: _selectedOption == null,
            ),
          ],
        ),
      ),
    );
  }
}
