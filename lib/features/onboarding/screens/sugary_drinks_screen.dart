import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/features/onboarding/screens/pregnancy_status_screen.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/core/widgets/selection_box.dart';

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
      'icon': 'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame-1.svg',
      'value': 'almost_never',
      'iconBgColor': const Color(0xFFF2F2F2),
    },
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': 'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame-2.svg',
      'value': 'rarely',
      'iconBgColor': const Color(0xFFE9D9FF),
    },
    {
      'title': 'Regularly',
      'subtitle': 'Every day',
      'icon': 'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame-3.svg',
      'value': 'regularly',
      'iconBgColor': const Color(0xFFE4F0FF),
    },
    {
      'title': 'Often',
      'subtitle': 'Several per day',
      'icon': 'assets/images/icons/onboarding_elements/select_your_goal_icons/Frame-4.svg',
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sugary Beverages', style: AppTypography.headline),
            const SizedBox(height: 8),
            Text(
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
                  final isSelected = _selectedFrequency == frequency['value'];

                  return SelectionBox(
                    title: frequency['title'] as String,
                    subtitle: frequency['subtitle'] as String,
                    icon: Container(
                      width: 40,
                      height: 40,
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
                                ? AppColors.selectedBorder
                                : AppColors.unselectedBorder,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    isSelected: isSelected,
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
            // In the ContinueButton's onPressed callback
            ContinueButton(
              onPressed:
                  _selectedFrequency.isNotEmpty
                      ? () async {
                        await _saveFrequency();
                        if (mounted) {
                          // Removed: context.read<OnboardingProvider>().nextPage();
                          Navigator.of(context).push(
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
