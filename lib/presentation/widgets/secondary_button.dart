import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(theme.primaryColor),
        overlayColor:
            MaterialStateProperty.all(theme.primaryColor.withOpacity(0.06)),
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
      child: Text(title),
    );
  }
}