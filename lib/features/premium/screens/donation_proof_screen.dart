import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/buttons/secondary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/inputs/app_text_field.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

/// Screen for submitting donation proof with image picker
class DonationProofScreen extends StatefulWidget {
  const DonationProofScreen({super.key});

  static const String routeName = '/donation-proof';

  @override
  State<DonationProofScreen> createState() => _DonationProofScreenState();
}

class _DonationProofScreenState extends State<DonationProofScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Donation Proof'),
        centerTitle: true,
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const _HeaderSection(),
                  const SizedBox(height: 24),

                  // Device Code Display
                  _DeviceCodeDisplay(deviceCode: premiumProvider.deviceCode),
                  const SizedBox(height: 24),

                  // Image Upload Section
                  _ImageUploadSection(
                    selectedImage: _selectedImage,
                    onImageSelected: _onImageSelected,
                  ),
                  const SizedBox(height: 24),

                  // Transaction Details Form
                  _TransactionDetailsForm(
                    amountController: _amountController,
                    transactionIdController: _transactionIdController,
                    notesController: _notesController,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  PrimaryButton(
                    text: 'Submit Proof',
                    onPressed:
                        _selectedImage != null && !_isSubmitting
                            ? () => _submitProof(context, premiumProvider)
                            : null,
                    isLoading: _isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  SecondaryButton(
                    text: 'Cancel',
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
                  ),

                  // Error Display
                  if (premiumProvider.lastError != null) ...[
                    const SizedBox(height: 16),
                    _ErrorDisplay(error: premiumProvider.lastError),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onImageSelected() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submitProof(
    BuildContext context,
    PremiumProvider premiumProvider,
  ) async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await premiumProvider.submitDonationProof(
        imageFile: _selectedImage!,
        amount:
            _amountController.text.isNotEmpty
                ? double.tryParse(_amountController.text)
                : null,
        transactionId:
            _transactionIdController.text.isNotEmpty
                ? _transactionIdController.text
                : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success && mounted) {
        // Show success dialog
        await _showSuccessDialog(context);

        // Navigate back to donation info screen
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 48,
          ),
          title: const Text('Proof Submitted Successfully'),
          content: const Text(
            'Your donation proof has been submitted. You will receive an unlock code via email within 24 hours.',
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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(Icons.upload_file, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Upload Transaction Screenshot',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Please upload a clear screenshot of your bKash transaction',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DeviceCodeDisplay extends StatelessWidget {
  const _DeviceCodeDisplay({required this.deviceCode});

  final String deviceCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Code (Auto-included)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              deviceCode,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageUploadSection extends StatelessWidget {
  const _ImageUploadSection({
    required this.selectedImage,
    required this.onImageSelected,
  });

  final File? selectedImage;
  final VoidCallback onImageSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Screenshot',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (selectedImage != null) ...[
            // Show selected image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Image selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onImageSelected,
                  child: const Text('Change'),
                ),
              ],
            ),
          ] else ...[
            // Show upload placeholder
            GestureDetector(
              onTap: onImageSelected,
              child: Container(
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
                      Icons.add_photo_alternate,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to select image',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            'Upload a clear screenshot showing the successful bKash transaction',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionDetailsForm extends StatelessWidget {
  const _TransactionDetailsForm({
    required this.amountController,
    required this.transactionIdController,
    required this.notesController,
  });

  final TextEditingController amountController;
  final TextEditingController transactionIdController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details (Optional)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Amount Field
          AppTextField(
            controller: amountController,
            labelText: 'Amount (BDT)',
            hintText: 'e.g., 100',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Transaction ID Field
          AppTextField(
            controller: transactionIdController,
            labelText: 'Transaction ID',
            hintText: 'bKash transaction ID',
          ),
          const SizedBox(height: 16),

          // Notes Field
          AppTextField(
            controller: notesController,
            labelText: 'Additional Notes',
            hintText: 'Any additional information...',
            maxLines: 3,
            maxLength: 500,
          ),
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  const _ErrorDisplay({required this.error});

  final dynamic error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
