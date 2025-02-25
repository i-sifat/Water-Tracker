import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/num_extension.dart';

class RemainingHydrationText extends StatelessWidget {
  const RemainingHydrationText(this.milliliters, {super.key});
  final int milliliters;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Remaining: ${milliliters.asMilliliters()}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
