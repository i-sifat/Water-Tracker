import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/screens/onboarding/weather-selection-screen.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:watertracker/widgets/primary_button.dart';

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
              'Pregnancy/Breast\nfeed',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlue,
                height: 1.2,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select which whats your habit.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: _options.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final isSelected = _selectedOption == option['value'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOption = option['value'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFFDAFFC7)
                                  : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFFDAFFC7)
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                option['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected
                                            ? const Color(0xFF7FB364)
                                            : AppColors.darkBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option['subtitle']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _handlePreferNotToAnswer,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF3F1FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Prefer not to answer',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.close, size: 20, color: Colors.grey[600]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Continue',
              onPressed: _selectedOption != null ? _handleContinue : () {},
              isDisabled: _selectedOption == null,
              rightIcon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
