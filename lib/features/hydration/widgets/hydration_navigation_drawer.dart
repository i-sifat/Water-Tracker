import 'package:flutter/material.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';

/// Navigation drawer for the hydration interface
/// Provides quick access to main app sections and settings
class HydrationNavigationDrawer extends StatelessWidget {
  const HydrationNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header section
            _buildDrawerHeader(context),
            
            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavigationItem(
                    context,
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () => _navigateToHome(context),
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.water_drop,
                    title: 'Hydration',
                    onTap: () => Navigator.of(context).pop(),
                    isSelected: true,
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.analytics,
                    title: 'Analytics',
                    onTap: () => _navigateToAnalytics(context),
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.history,
                    title: 'History',
                    onTap: () => _navigateToHistory(context),
                  ),
                  const Divider(height: 32),
                  _buildNavigationItem(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => _navigateToSettings(context),
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => _showHelpDialog(context),
                  ),
                ],
              ),
            ),
            
            // Footer section
            _buildDrawerFooter(context),
          ],
        ),
      ),
    );
  }

  /// Build drawer header with app branding
  Widget _buildDrawerHeader(BuildContext context) {
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
          // App icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          
          // App title
          Text(
            'Water Tracker',
            style: AppTypography.headline.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subtitle
          Text(
            'Stay hydrated, stay healthy',
            style: AppTypography.subtitle.copyWith(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual navigation item
  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6B73FF).withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF6B73FF) : Colors.grey[600],
          size: 22,
        ),
        title: Text(
          title,
          style: AppTypography.subtitle.copyWith(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF6B73FF) : Colors.grey[800],
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Build drawer footer
  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: AppTypography.subtitle.copyWith(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed('/analytics/weekly');
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.of(context).pop();
    // Navigate to history screen - would need to be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History screen navigation coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(SettingsScreen.routeName);
  }

  void _showHelpDialog(BuildContext context) {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Text(
            'For help and support, please contact us at:\n\n'
            'Email: support@watertracker.app\n'
            'Website: www.watertracker.app',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}