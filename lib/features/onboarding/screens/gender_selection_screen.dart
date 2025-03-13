import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/core/widgets/large_selection_box.dart';
import 'package:watertracker/core/widgets/prefer_not_to_answer_button.dart';
import 'package:watertracker/features/onboarding/screens/age_selection_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  final List<Map<String, String>> _genderOptions = [
    {
      'value': 'male',
      'title': 'I am Male',
      'subtitle': 'Select if you identify as male',
      'icon':
          'assets/images/icons/onboarding_elements/onboarding_maleavater_icon.svg',
    },
    {
      'value': 'female',
      'title': 'I am Female',
      'subtitle': 'Select if you identify as female',
      'icon':
          'assets/images/icons/onboarding_elements/onboarding_femaleavater_icon.svg',
    },
  ];

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
              '2 of 10',
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
            const Text('Select your Gender', style: AppTypography.headline),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.separated(
                itemCount: _genderOptions.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = _genderOptions[index];
                  return LargeSelectionBox(
                    title: option['title']!,
                    subtitle: option['subtitle']!,
                    icon: SvgPicture.asset(
                      option['icon']!,
                      width: 32,
                      height: 32,
                    ),
                    isSelected: _selectedGender == option['value'],
                    onTap: () {
                      setState(() {
                        _selectedGender = option['value'];
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
              onPressed: _selectedGender != null ? _handleContinue : () {},
              isDisabled: _selectedGender == null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedGender != null) {
      _saveGender().then((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AgeSelectionScreen()),
          );
        }
      });
    }
  }

  void _handlePreferNotToAnswer() {
    setState(() => _selectedGender = 'not_specified');
    _handleContinue();
  }

  Future<void> _saveGender() async {
    if (_selectedGender != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_gender', _selectedGender!);
    }
  }
}
