import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/num_extension.dart';

class RemainingHydrationText extends StatelessWidget {
  final int milliliters;

  const RemainingHydrationText(this.milliliters, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Remaining: ${milliliters.asMilliliters()}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}