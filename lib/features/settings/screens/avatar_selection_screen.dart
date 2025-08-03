import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/core/utils/avatar_extensions.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/settings/providers/settings_provider.dart';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  AvatarOption? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    _selectedAvatar = settingsProvider.appPreferences.selectedAvatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Select Avatar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your avatar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will be displayed on your home screen',
              style: TextStyle(fontSize: 14, color: AppColors.textSubtitle),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: AvatarOption.values.length,
                itemBuilder: (context, index) {
                  final avatar = AvatarOption.values[index];
                  final isSelected = _selectedAvatar == avatar;

                  return _buildAvatarCard(avatar, isSelected);
                },
              ),
            ),

            const SizedBox(height: 24),

            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return PrimaryButton(
                  text: 'Save Avatar',
                  onPressed:
                      _selectedAvatar != null
                          ? () => _saveAvatar(settingsProvider)
                          : null,
                  isLoading: settingsProvider.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard(AvatarOption avatar, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = avatar;
        });
      },
      child: AppCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
                isSelected
                    ? Border.all(color: AppColors.waterFull, width: 2)
                    : null,
            color:
                isSelected ? AppColors.waterFull.withValues(alpha: 0.05) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: SvgPicture.asset(avatar.assetPath)),
              const SizedBox(height: 12),
              Text(
                avatar.displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? AppColors.waterFull : AppColors.textPrimary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.waterFull,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAvatar(SettingsProvider settingsProvider) async {
    if (_selectedAvatar == null) return;

    final success = await settingsProvider.updateAvatar(_selectedAvatar!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update avatar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
