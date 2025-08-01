import 'package:flutter/material.dart';
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
            color: isSelected ? AppColors.lightPurple : AppColors.unselectedBorder,
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
            Expanded(
              flex: 3,
              child: Center(
                child: _buildAvatar(),
              ),
            ),
            // Bottom section with text
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightPurple : AppColors.genderUnselected,
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
    if (gender == 'male') {
      return Container(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Yellow hair
            Positioned(
              top: 0,
              child: Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.maleHair,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            // Pink face
            Positioned(
              top: 20,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.maleFace,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Eyes
                    Positioned(
                      top: 15,
                      left: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.maleFace,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.maleFace,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Smile
                    Positioned(
                      bottom: 15,
                      child: Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dark gray shoulders
            Positioned(
              bottom: 0,
              child: Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.avatarShoulders,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Female avatar
      return Container(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gray hair
            Positioned(
              top: 0,
              child: Container(
                width: 60,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.femaleHair,
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
            ),
            // Gray face
            Positioned(
              top: 25,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.femaleFace,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Eyes
                    Positioned(
                      top: 15,
                      left: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.femaleFace,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.femaleFace,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Smile
                    Positioned(
                      bottom: 15,
                      child: Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.femaleFace,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dark gray shoulders
            Positioned(
              bottom: 0,
              child: Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.avatarShoulders,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
} 