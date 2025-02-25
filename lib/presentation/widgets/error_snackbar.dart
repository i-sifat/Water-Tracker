import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String message) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onError),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: theme.colorScheme.onError),
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.error,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: theme.colorScheme.onError,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      animation: CurvedAnimation(
        parent: const AlwaysStoppedAnimation(1),
        curve: Curves.easeInOut,
      ),
    ),
  );
}
