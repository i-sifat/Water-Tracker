import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/screens/onboarding/training-frequency-screen.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:watertracker/widgets/primary_button.dart';

class SugaryBeveragesScreen extends StatefulWidget {
  const SugaryBeveragesScreen({Key? key}) : super(key: key);

  @override
  State<SugaryBeveragesScreen> createState() => _SugaryBeveragesScreenState();
}

class _SugaryBeveragesScreenState extends State<SugaryBeveragesScreen> {
  String _selectedFrequency = '';

  final List<Map<String, dynamic>> _frequencies = [
    {
      'title': 'Almost never',
      'subtitle': 'Never / several times a month',
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-1.svg',
      'value': 'almost_never',
      'iconBgColor': const Color(0xFFF2F2F2),
    },
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-2.svg',
      'value': 'rarely',
      'iconBgColor': const Color(0xFFE9D9FF),
    },
    {
      'title': 'Regularly',
      'subtitle': 'Every day',
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-3.svg',
      'value': 'regularly',
      'iconBgColor': const Color(0xFFE4F0FF),
    },
    {
      'title': 'Often',
      'subtitle': 'Several per day',
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-4.svg',
      'value': 'often',
      'iconBgColor': const Color(0xFFFFF8E5),
    },
  ];

  Future<void> _saveFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sugary_beverages_frequency', _selectedFrequency);
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
            fontFamily: 'Nunito',
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
                fontFamily: 'Nunito',
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
              'Sugary Beverages',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlue,
                height: 1.2,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select which whats your habit.',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSubtitle,
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
                  final isSelected = _selectedFrequency == frequency['value'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFrequency = frequency['value'] as String;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.lightBlue.withOpacity(0.25)
                                  : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: frequency['iconBgColor'] as Color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                frequency['icon'] as String,
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? AppColors.lightBlue
                                      : AppColors.darkBlue.withOpacity(0.5),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  frequency['title'] as String,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected
                                            ? AppColors.lightBlue
                                            : AppColors.darkBlue,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                Text(
                                  frequency['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSubtitle,
                                    fontFamily: 'Nunito',
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
                              builder: (context) => const FitnessLevelScreen(),
                            ),
                          );
                        }
                      }
                      : () {},
              isDisabled: _selectedFrequency.isEmpty,
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
