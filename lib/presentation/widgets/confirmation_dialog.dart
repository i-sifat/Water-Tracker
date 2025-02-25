import 'package:flutter/material.dart';
import 'package:watertracker/presentation/widgets/primary_button.dart';
import 'package:watertracker/presentation/widgets/secondary_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(onPressed: onConfirm, title: 'Confirm'),
          const SizedBox(height: 10),
          SecondaryButton(onPressed: onCancel, title: 'Cancel'),
        ],
      ),
    );
  }
}
