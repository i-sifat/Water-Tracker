import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/buttons/secondary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';
import 'package:watertracker/features/premium/screens/donation_proof_screen.dart';

/// Screen showing bKash donation information and QR code
class DonationInfoScreen extends StatelessWidget {
  const DonationInfoScreen({super.key});

  static const String routeName = '/donation-info';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Premium'), centerTitle: true),
      body: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const _HeaderSection(),
                const SizedBox(height: 24),

                // Device Code Display
                _DeviceCodeCard(deviceCode: premiumProvider.deviceCode),
                const SizedBox(height: 24),

                // bKash Payment Info
                const _BkashPaymentCard(),
                const SizedBox(height: 24),

                // Instructions
                const _InstructionsCard(),
                const SizedBox(height: 32),

                // Action Buttons
                _ActionButtons(premiumProvider: premiumProvider),
                const SizedBox(height: 16),

                // Already have code button
                SecondaryButton(
                  text: 'Already have unlock code?',
                  onPressed: () => _navigateToUnlockCode(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToUnlockCode(BuildContext context) {
    Navigator.pushNamed(context, '/unlock-code');
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Unlock Premium Features',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Support the development and unlock advanced features',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DeviceCodeCard extends StatelessWidget {
  const _DeviceCodeCard({required this.deviceCode});

  final String deviceCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smartphone, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Your Device Code',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    deviceCode,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copyDeviceCode(context),
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy device code',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Include this code when submitting your donation proof',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _copyDeviceCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: deviceCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _BkashPaymentCard extends StatelessWidget {
  const _BkashPaymentCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2136E), // bKash pink
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.payment, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'bKash Payment Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Number
          const _PaymentDetailRow(
            label: 'bKash Number',
            value: '+8801XXXXXXXXX', // Replace with actual number
            canCopy: true,
          ),
          const SizedBox(height: 12),

          // Account Type
          const _PaymentDetailRow(label: 'Account Type', value: 'Personal'),
          const SizedBox(height: 12),

          // Account Name
          const _PaymentDetailRow(
            label: 'Account Name',
            value: 'Water Tracker Developer',
          ),
          const SizedBox(height: 12),

          // Suggested Amount
          const _PaymentDetailRow(
            label: 'Suggested Amount',
            value: '100 BDT',
            highlight: true,
          ),

          const SizedBox(height: 16),

          // QR Code placeholder
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'QR Code for bKash Payment',
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

class _PaymentDetailRow extends StatelessWidget {
  const _PaymentDetailRow({
    required this.label,
    required this.value,
    this.canCopy = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool canCopy;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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
        if (canCopy)
          IconButton(
            onPressed: () => _copyValue(context),
            icon: const Icon(Icons.copy, size: 16),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  void _copyValue(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'How to Unlock Premium',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ..._buildInstructionSteps(context),
        ],
      ),
    );
  }

  List<Widget> _buildInstructionSteps(BuildContext context) {
    final theme = Theme.of(context);

    final steps = [
      'Send money to the bKash number above',
      'Take a screenshot of the successful transaction',
      'Tap "Submit Donation Proof" below',
      'Upload your screenshot and include your device code',
      'Wait for email with your unlock code (usually within 24 hours)',
      'Enter the unlock code to activate premium features',
    ];

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;

      return Padding(
        padding: EdgeInsets.only(bottom: index < steps.length - 1 ? 12 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(step, style: theme.textTheme.bodyMedium)),
          ],
        ),
      );
    }).toList();
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.premiumProvider});

  final PremiumProvider premiumProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          text: 'Submit Donation Proof',
          onPressed:
              premiumProvider.isSubmittingProof
                  ? null
                  : () => _navigateToDonationProof(context),
          isLoading: premiumProvider.isSubmittingProof,
        ),
      ],
    );
  }

  void _navigateToDonationProof(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DonationProofScreen()),
    );
  }
}
