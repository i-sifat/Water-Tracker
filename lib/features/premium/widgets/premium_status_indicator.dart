import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';
import 'package:watertracker/features/premium/screens/donation_info_screen.dart';

/// Widget that shows premium status indicator throughout the app
class PremiumStatusIndicator extends StatelessWidget {
  const PremiumStatusIndicator({
    super.key,
    this.showLabel = true,
    this.size = PremiumIndicatorSize.normal,
    this.onTap,
  });

  final bool showLabel;
  final PremiumIndicatorSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        if (!premiumProvider.isInitialized) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap ?? () => _handleTap(context, premiumProvider),
          child: _buildIndicator(context, premiumProvider),
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context, PremiumProvider premiumProvider) {
    final theme = Theme.of(context);
    final isPremium = premiumProvider.isPremium;
    
    final iconSize = _getIconSize();
    final textStyle = _getTextStyle(theme);
    
    if (showLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isPremium 
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPremium 
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPremium ? Icons.workspace_premium : Icons.lock_outline,
              size: iconSize,
              color: isPremium 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              isPremium ? 'Premium' : 'Free',
              style: textStyle?.copyWith(
                color: isPremium 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Icon(
        isPremium ? Icons.workspace_premium : Icons.lock_outline,
        size: iconSize,
        color: isPremium 
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      );
    }
  }

  double _getIconSize() {
    switch (size) {
      case PremiumIndicatorSize.small:
        return 16;
      case PremiumIndicatorSize.normal:
        return 20;
      case PremiumIndicatorSize.large:
        return 24;
    }
  }

  TextStyle? _getTextStyle(ThemeData theme) {
    switch (size) {
      case PremiumIndicatorSize.small:
        return theme.textTheme.bodySmall;
      case PremiumIndicatorSize.normal:
        return theme.textTheme.bodyMedium;
      case PremiumIndicatorSize.large:
        return theme.textTheme.bodyLarge;
    }
  }

  void _handleTap(BuildContext context, PremiumProvider premiumProvider) {
    if (!premiumProvider.isPremium) {
      // Navigate to donation info screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DonationInfoScreen(),
        ),
      );
    } else {
      // Show premium status dialog
      _showPremiumStatusDialog(context, premiumProvider);
    }
  }

  void _showPremiumStatusDialog(BuildContext context, PremiumProvider premiumProvider) {
    showDialog(
      context: context,
      builder: (context) => _PremiumStatusDialog(premiumProvider: premiumProvider),
    );
  }
}

enum PremiumIndicatorSize {
  small,
  normal,
  large,
}

class _PremiumStatusDialog extends StatelessWidget {
  const _PremiumStatusDialog({required this.premiumProvider});

  final PremiumProvider premiumProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      icon: Icon(
        Icons.workspace_premium,
        color: theme.colorScheme.primary,
        size: 32,
      ),
      title: const Text('Premium Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusRow(
            label: 'Status',
            value: premiumProvider.statusSummary,
          ),
          const SizedBox(height: 8),
          _StatusRow(
            label: 'Device Code',
            value: premiumProvider.deviceCode,
          ),
          if (premiumProvider.unlockedAt != null) ...[
            const SizedBox(height: 8),
            _StatusRow(
              label: 'Unlocked On',
              value: _formatDate(premiumProvider.unlockedAt!),
            ),
          ],
          if (premiumProvider.expiresAt != null) ...[
            const SizedBox(height: 8),
            _StatusRow(
              label: 'Expires On',
              value: _formatDate(premiumProvider.expiresAt!),
            ),
          ],
          if (premiumProvider.daysRemaining != null) ...[
            const SizedBox(height: 8),
            _StatusRow(
              label: 'Days Remaining',
              value: '${premiumProvider.daysRemaining} days',
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact premium badge for use in app bars or small spaces
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        if (!premiumProvider.isInitialized || !premiumProvider.isPremium) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'PRO',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget that shows premium features are locked
class PremiumLockedIndicator extends StatelessWidget {
  const PremiumLockedIndicator({
    super.key,
    this.message = 'Premium Feature',
    this.onUnlockTap,
  });

  final String message;
  final VoidCallback? onUnlockTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Unlock premium features to access this content',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onUnlockTap ?? () => _navigateToUnlock(context),
            icon: const Icon(Icons.workspace_premium, size: 16),
            label: const Text('Unlock Premium'),
          ),
        ],
      ),
    );
  }

  void _navigateToUnlock(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DonationInfoScreen(),
      ),
    );
  }
}