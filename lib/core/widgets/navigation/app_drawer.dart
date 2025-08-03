import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';

/// Navigation drawer for the hydration interface
/// Provides access to main app sections and user profile
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header section with user info
            _buildDrawerHeader(context),
            
            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () => _navigateToHome(context),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.water_drop_outlined,
                    title: 'Add Hydration',
                    onTap: () => _navigateToHydration(context),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'Statistics',
                    onTap: () => _navigateToStatistics(context),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.history_outlined,
                    title: 'History',
                    onTap: () => _navigateToHistory(context),
                  ),
                  const Divider(height: 32),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => _navigateToSettings(context),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => _showHelpDialog(context),
                  ),
                ],
              ),
            ),
            
            // Footer with app version
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  /// Build drawer header with user profile info
  Widget _buildDrawerHeader(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, hydrationProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6B73FF),
                Color(0xFF9546C4),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // User greeting
              Text(
                'Hello!',
                style: AppTypography.headline.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Daily progress summary
              Text(
                '${hydrationProvider.currentIntake} ml of ${hydrationProvider.dailyGoal} ml today',
                style: AppTypography.subtitle.copyWith(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build individual drawer item
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTypography.subtitle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  /// Build drawer footer
  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Water Tracker v1.0.0',
        style: AppTypography.subtitle.copyWith(
          fontSize: 12,
          color: AppColors.textSubtitle,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Navigation methods
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  void _navigateToHydration(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    // Already on hydration screen, no need to navigate
  }

  void _navigateToStatistics(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    // Navigate to statistics page within the swipeable interface
    // This would typically trigger a page change in the parent widget
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Swipe up to view statistics'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).pushNamed('/analytics/weekly');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).pushNamed(SettingsScreen.routeName);
  }

  void _showHelpDialog(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How to use Water Tracker:'),
              SizedBox(height: 12),
              Text('• Tap quick add buttons to log water intake'),
              Text('• Swipe up to view statistics and history'),
              Text('• Swipe down to see goal breakdown'),
              Text('• Change drink types to track different beverages'),
              SizedBox(height: 16),
              Text('Need more help? Contact us at support@watertracker.app'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}