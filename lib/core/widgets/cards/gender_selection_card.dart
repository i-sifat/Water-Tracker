import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watertracker/core/utils/app_colors.dart';

class GenderSelectionCard extends StatelessWidget {
  const GenderSelectionCard({
    required this.title,
    required this.onTap,
    required this.isSelected,
    required this.gender,
    super.key,
  });

  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final String gender; // 'male' or 'female'

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.lightPurple : AppColors.unselectedBorder,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section with avatar
            Expanded(flex: 3, child: Center(child: _buildAvatar())),
            // Bottom section with text
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.lightPurple
                        : AppColors.genderUnselected,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSubtitle,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final assetPath =
        gender == 'male'
            ? 'assets/images/avatars/male.svg'
            : 'assets/images/avatars/female.svg';

    return SizedBox(
      width: 80,
      height: 80,
      child: SvgPicture.asset(assetPath, width: 80, height: 80),
    );
  }
}
