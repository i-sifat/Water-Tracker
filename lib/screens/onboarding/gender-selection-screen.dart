import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/screens/onboarding/age-selection-screen.dart';
import 'package:watertracker/utils/app_colors.dart';
import 'package:watertracker/widgets/primary_button.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  Future<void> _saveGender() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'selected_gender',
      _selectedGender ?? 'not_specified',
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
            icon: const Icon(Icons.arrow_back, color: AppColors.textHeadline),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Assessment',
          style: TextStyle(
            color: AppColors.textHeadline,
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
              '2 of 17',
              style: TextStyle(
                color: AppColors.textHeadline,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select your Gender',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption(
                    'male',
                    'assets/onboarding_elements/onboarding_maleavater_icon.svg',
                    'I am Male',
                    Icons.male,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderOption(
                    'female',
                    'assets/onboarding_elements/onboarding_femaleavater_icon.svg',
                    'I am Female',
                    Icons.female,
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: _handlePreferNotToAnswer,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.preferNotToAnswer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Prefer not to answer',
                    style: TextStyle(
                      color: AppColors.genderSelected,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.close, size: 20, color: AppColors.genderSelected),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Continue',
              onPressed: _selectedGender != null ? _handleContinue : () {},
              isDisabled: _selectedGender == null,
              rightIcon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    String gender,
    String avatarAsset,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.genderSelected.withOpacity(0.25)
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              child: SvgPicture.asset(
                avatarAsset,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? AppColors.genderSelected
                      : AppColors.genderUnselected,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected
                          ? AppColors.genderSelected
                          : AppColors.textSubtitle,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected
                            ? AppColors.genderSelected
                            : AppColors.textSubtitle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
