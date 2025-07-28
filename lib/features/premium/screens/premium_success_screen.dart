import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

/// Screen showing premium success and feature overview
class PremiumSuccessScreen extends StatelessWidget {
  const PremiumSuccessScreen({super.key});

  static const String routeName = '/premium-success';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Unlocked'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success Header
                const _SuccessHeader(),
                const SizedBox(height: 24),
                
                // Premium Status Card
                _PremiumStatusCard(premiumProvider: premiumProvider),
                const SizedBox(height: 24),
                
                // Features Overview
                const _FeaturesOverview(),
                const SizedBox(height: 32),
                
                // Continue Button
                PrimaryButton(
                  text: 'Continue to App',
                  onPressed: () => _navigateToHome(context),
                ),
                const SizedBox(height: 16),
                
                // Thank You Message
                const _ThankYouMessage(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    // Navigate to home and clear the navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/', // Assuming home route is '/'
      (route) => false,
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Success Animation/Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 48,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 24),
        
        Text(
          'Premium Unlocked!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        
        Text(
          'Thank you for supporting Water Tracker development',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PremiumStatusCard extends StatelessWidget {
  const _PremiumStatusCard({required this.premiumProvider});

  final PremiumProvider premiumProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Premium Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Status Details
          _StatusRow(
            label: 'Status',
            value: premiumProvider.statusSummary,
            highlight: true,
          ),
          const SizedBox(height: 8),
          
          _StatusRow(
            label: 'Device Code',
            value: premiumProvider.deviceCode,
          ),
          const SizedBox(height: 8),
          
          if (premiumProvider.unlockedAt != null)
            _StatusRow(
              label: 'Unlocked On',
              value: _formatDate(premiumProvider.unlockedAt!),
            ),
          
          if (premiumProvider.expiresAt != null) ...[
            const SizedBox(height: 8),
            _StatusRow(
              label: 'Expires On',
              value: _formatDate(premiumProvider.expiresAt!),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const _StatusRow(
              label: 'Validity',
              value: 'Lifetime',
              highlight: true,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? theme.colorScheme.primary : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturesOverview extends StatelessWidget {
  const _FeaturesOverview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Premium Features Unlocked',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Feature List
          ...PremiumFeature.values.map((feature) => _FeatureItem(
            feature: feature,
          )),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PremiumFeatures.featureNames[feature] ?? feature.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  PremiumFeatures.featureDescriptions[feature] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThankYouMessage extends StatelessWidget {
  const _ThankYouMessage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Thank You for Your Support!',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Your donation helps us continue developing and improving Water Tracker. We truly appreciate your support!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
