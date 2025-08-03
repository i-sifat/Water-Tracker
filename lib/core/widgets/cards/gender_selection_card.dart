import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/utils/responsive_helper.dart';

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
        height: ResponsiveHelper.getResponsiveHeight(context, 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveBorderRadius(context, 16),
          ),
          border: Border.all(
            color:
                isSelected ? AppColors.lightPurple : AppColors.unselectedBorder,
            width: ResponsiveHelper.getResponsiveWidth(context, 2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: ResponsiveHelper.getResponsiveWidth(context, 8),
              offset: Offset(
                0,
                ResponsiveHelper.getResponsiveHeight(context, 2),
              ),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section with avatar
            Expanded(flex: 3, child: Center(child: _buildAvatar(context))),
            // Bottom section with text
            Container(
              width: double.infinity,
              height: ResponsiveHelper.getResponsiveHeight(context, 60),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.lightPurple
                        : AppColors.genderUnselected,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(context, 14),
                  ),
                  bottomRight: Radius.circular(
                    ResponsiveHelper.getResponsiveBorderRadius(context, 14),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      16,
                    ),
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

  Widget _buildAvatar(BuildContext context) {
    final assetPath =
        gender == 'male'
            ? 'assets/images/avatars/male.svg'
            : 'assets/images/avatars/female.svg';

    final avatarSize = ResponsiveHelper.getResponsiveWidth(context, 80);

    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: SvgPicture.asset(assetPath, width: avatarSize, height: avatarSize),
    );
  }
}
