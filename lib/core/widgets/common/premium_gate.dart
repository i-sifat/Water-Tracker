import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

class PremiumGate extends StatelessWidget {
  const PremiumGate({
    required this.feature,
    required this.child,
    super.key,
    this.lockedChild,
    this.onUnlockPressed,
    this.title,
    this.description,
  });

  final PremiumFeature feature;
  final Widget child;
  final Widget? lockedChild;
  final VoidCallback? onUnlockPressed;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premium, _) {
        if (premium.isFeatureUnlocked(feature)) {
          return child;
        }

        return lockedChild ??
            PremiumLockedWidget(
              feature: feature,
              onUnlockPressed: onUnlockPressed,
              title: title,
              description: description,
            );
      },
    );
  }
}

class PremiumLockedWidget extends StatelessWidget {
  const PremiumLockedWidget({
    required this.feature,
    super.key,
    this.onUnlockPressed,
    this.title,
    this.description,
  });

  final PremiumFeature feature;
  final VoidCallback? onUnlockPressed;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final premium = context.read<PremiumProvider>();
    final featureInfo = _getFeatureInfo(feature, premium);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title ?? featureInfo.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description ?? featureInfo.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Unlock button
            PrimaryButton(
              onPressed: onUnlockPressed ?? () => _navigateToPremium(context),
              text: 'Unlock Premium',
            ),
          ],
        ),
      ),
    );
  }

  _FeatureInfo _getFeatureInfo(
    PremiumFeature feature,
    PremiumProvider premium,
  ) {
    final name = premium.getFeatureName(feature);
    final description = premium.getFeatureDescription(feature);

    return _FeatureInfo(title: name, description: description);
  }

  void _navigateToPremium(BuildContext context) {
    // Navigate to donation info screen
    Navigator.pushNamed(context, '/premium/donation-info');
  }
}

class _FeatureInfo {
  const _FeatureInfo({required this.title, required this.description});

  final String title;
  final String description;
}
