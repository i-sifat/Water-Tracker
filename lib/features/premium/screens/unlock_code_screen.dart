import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/buttons/secondary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/inputs/app_text_field.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';
import 'package:watertracker/features/premium/screens/premium_success_screen.dart';

/// Screen for entering unlock code with validation
class UnlockCodeScreen extends StatefulWidget {
  const UnlockCodeScreen({super.key});

  static const String routeName = '/unlock-code';

  @override
  State<UnlockCodeScreen> createState() => _UnlockCodeScreenState();
}

class _UnlockCodeScreenState extends State<UnlockCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unlockCodeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _unlockCodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Unlock Code'),
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
                  
                  // Unlock Code Input
                  _UnlockCodeInput(
                    controller: _unlockCodeController,
                    focusNode: _focusNode,
                  ),
                  const SizedBox(height: 24),
                  
                  // Instructions
                  const _InstructionsCard(),
                  const SizedBox(height: 32),
                  
                  // Unlock Button
                  PrimaryButton(
                    text: 'Unlock Premium',
                    onPressed: premiumProvider.isValidatingCode
                        ? null
                        : () => _unlockPremium(context, premiumProvider),
                    isLoading: premiumProvider.isValidatingCode,
                  ),
                  const SizedBox(height: 16),
                  
                  // Back Button
                  SecondaryButton(
                    text: 'Back to Donation Info',
                    onPressed: premiumProvider.isValidatingCode 
                        ? null 
                        : () => Navigator.pop(context),
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

  Future<void> _unlockPremium(BuildContext context, PremiumProvider premiumProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final unlockCode = _unlockCodeController.text.trim().toUpperCase();
    
    final success = await premiumProvider.unlockWithCode(unlockCode);
    
    if (success && mounted) {
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PremiumSuccessScreen(),
        ),
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        _unlockCodeController.text = clipboardData!.text!.trim().toUpperCase();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to paste from clipboard'),
          ),
        );
      }
    }
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
          Icons.vpn_key,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Enter Your Unlock Code',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the unlock code you received via email',
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
            'Your Device Code',
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
          const SizedBox(height: 8),
          Text(
            'Make sure this matches the device code you submitted',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockCodeInput extends StatelessWidget {
  const _UnlockCodeInput({
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unlock Code',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          AppTextField(
            controller: controller,
            focusNode: focusNode,
            labelText: 'Enter unlock code',
            hintText: 'XXXX-XXXX-XXXX-XXXX',
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Z0-9-]')),
              _UnlockCodeFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the unlock code';
              }
              
              // Remove dashes for validation
              final cleanCode = value.replaceAll('-', '');
              if (cleanCode.length != 16) {
                return 'Unlock code must be 16 characters long';
              }
              
              if (!RegExp(r'^[A-Z0-9]+$').hasMatch(cleanCode)) {
                return 'Unlock code can only contain letters and numbers';
              }
              
              return null;
            },
            suffixIcon: IconButton(
              onPressed: () => _pasteFromClipboard(context),
              icon: const Icon(Icons.paste),
              tooltip: 'Paste from clipboard',
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            'Format: XXXX-XXXX-XXXX-XXXX (dashes will be added automatically)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pasteFromClipboard(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        controller.text = clipboardData!.text!.trim().toUpperCase();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to paste from clipboard'),
          ),
        );
      }
    }
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
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Important Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ..._buildNotes(context),
        ],
      ),
    );
  }

  List<Widget> _buildNotes(BuildContext context) {
    final theme = Theme.of(context);
    
    final notes = [
      'The unlock code is tied to your specific device',
      'Codes are usually sent within 24 hours of donation proof submission',
      'Make sure your device code matches the one you submitted',
      "Contact support if you haven't received your code after 48 hours",
    ];

    return notes.asMap().entries.map((entry) {
      final index = entry.key;
      final note = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: index < notes.length - 1 ? 8 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                note,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }).toList();
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
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
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

/// Custom formatter for unlock codes (adds dashes automatically)
class _UnlockCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '').toUpperCase();
    
    if (text.length > 16) {
      return oldValue;
    }
    
    var formatted = '';
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += '-';
      }
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}